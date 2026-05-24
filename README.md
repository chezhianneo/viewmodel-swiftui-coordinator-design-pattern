# Screen Architecture Pattern

## Overview

Every feature is a **Screen** composed of 4 types:
```
Coordinator → (via make()) → ViewModel + View
```

Dependencies flow down the **Coordinator tree** via `@Dependency` property wrappers — mirroring how SwiftUI passes `@Environment` down the view tree. No global container. No `DependencyKey`. Runtime variation flows through streams, never through dependency overrides.

---

## NavigationStream

A `CurrentValueSubject` created per screen scope. The **only** mechanism for navigation and runtime variation — not dependency swapping.

```swift
typealias NavigationStream<D: NavigationDestination> = CurrentValueSubject<D?, Never>
```

- Starts as `nil` — views use `.compactMap { $0 }` to ignore the initial value
- **Coordinator** creates it and passes it to child Coordinators and ViewModels
- **ViewModel** writes destinations via `navigationStream.send(.someDestination(view))`
- **View** observes via `.onReceive(navigationStream.compactMap { $0 })` and appends to `NavigationPath`

```swift
// Coordinator creates it
private let navigationStream = NavigationStream<FeatureDestination>(nil)

// ViewModel sends a destination
navigationStream.send(.detail(AnyView(detailView)))

// View receives it
.onReceive(navigationStream.compactMap { $0 }) { destination in
    path.append(destination)
}
```

**Never replace a stream to change behavior — send different destinations instead.**

---

## NavigationDestination

Each screen defines its own destination enum conforming to `NavigationDestination`:

```swift
protocol NavigationDestination: Hashable {
    var view: AnyView { get }
}
```

```swift
enum FeatureDestination: NavigationDestination {
    case detail(any View)

    static func == (lhs: FeatureDestination, rhs: FeatureDestination) -> Bool {
        switch (lhs, rhs) {
        case (.detail, .detail): return true
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail: hasher.combine("detail")
        }
    }

    var view: some View {
        switch self {
        case .detail(let view): return AnyView(view)
        }
    }
}
```

---

## @Dependency Property Wrapper

Declared on Coordinators. Holds a value set by the parent Coordinator via `add(_:)` before the child is used. Uses an internal `Storage` class so the set is `nonmutating` — copying the Coordinator struct copies the reference, not the value.

```swift
@propertyWrapper
struct Dependency<Value> {
    private let storage = Storage()

    init() {}

    var wrappedValue: Value {
        get {
            guard let value = storage.value else {
                fatalError("\(Value.self) not injected — parent Coordinator must set this before use")
            }
            return value
        }
        nonmutating set { storage.value = newValue }
    }

    final class Storage {
        var value: Value?
    }
}
```

`@Dependency` conforms to `DependencySettable` so `add(_:)` can write through it:

```swift
protocol DependencySettable {
    func set(_ value: Any)
    var storedValue: Any? { get }
}

extension Dependency: DependencySettable {
    func set(_ value: Any) {
        guard let typed = value as? Value else {
            fatalError("Type mismatch: expected \(Value.self), got \(type(of: value))")
        }
        storage.value = typed
    }

    var storedValue: Any? { storage.value }
}
```

---

## Coordinator Protocol

```swift
protocol Coordinator {
    associatedtype ActionType
    func buildDispatcher() -> ActionDispatcher<ActionType>
}
```

- `ActionType` is the screen's action enum (e.g. `FeatureAction`)
- `buildDispatcher()` constructs an `ActionDispatcher` whose closure contains the action-handling switch — mirroring TCA's `reduce(into:action:)`. All navigation logic lives here.

---

## Coordinator

- **Type:** `struct`
- **Role:** Declares dependencies via `@Dependency`. Receives them from parent via `add(_:)`. Spawns child Coordinators. Builds the screen via `make()`.
- **Why struct is safe:** `@Dependency` stores values in a `Storage` class reference — copying the struct copies the reference, not the value. Every copy points to the same injected instances.
- **Rules:**
  - Declare all dependencies with `@Dependency`
  - Never override a dependency received from parent — runtime variation goes through streams
  - Spawns child Coordinators and calls `add(&child)` to propagate dependencies
  - Provides a `make()` extension that creates the ViewModel and View
  - No cancellables, no mutable state — move those to CoordinatorState (see below)
  - No generic type parameters that shadow the `ActionType` enum

```swift
struct AppCoordinator: Coordinator {
    typealias ActionType = AppAction

    private let navigationStream = NavigationStream<AppDestination>(nil)

    func buildDispatcher() -> ActionDispatcher<AppAction> {
        ActionDispatcher<AppAction> { _ in }
    }

    func initFeatureCoordinator() {
        var coordinator = FeatureCoordinator()
        add(&coordinator)
        navigationStream.send(.feature(coordinator.make()))
    }
}

struct FeatureCoordinator: Coordinator {
    typealias ActionType = FeatureAction

    @Dependency var networkClient: NetworkingClient
    private let navigationStream = NavigationStream<FeatureDestination>(nil)

    func buildDispatcher() -> ActionDispatcher<FeatureAction> {
        let stream = navigationStream                         // capture stream, not self
        return ActionDispatcher<FeatureAction> { action in
            switch action {
            case .showDetail(let item):
                var child = ChildCoordinator()
                // propagate dependencies to child
                let view = child.make(item: item)
                stream.send(.detail(AnyView(view)))
            }
        }
    }
}
```

**`add(_:)` helper** — propagates all `@Dependency` values from parent to child by name, using `Mirror` to read and `DependencySettable` to write:

```swift
extension Coordinator {
    func add(_ child: inout some Coordinator) {
        let parentDict = Dictionary(uniqueKeysWithValues:
            Mirror(reflecting: self).children.compactMap { c -> (String, Any)? in
                guard let label = c.label,
                      let settable = c.value as? any DependencySettable,
                      let value = settable.storedValue else { return nil }
                let key = label.hasPrefix("_") ? String(label.dropFirst()) : label
                return (key, value)
            }
        )
        for c in Mirror(reflecting: child).children {
            guard let label = c.label else { continue }
            let key = label.hasPrefix("_") ? String(label.dropFirst()) : label
            guard let value = parentDict[key] else { continue }
            (c.value as? any DependencySettable)?.set(value)
        }
    }
}
```

---

## CoordinatorState

- **Type:** `class`
- **Role:** Backing store for any mutable runtime state that must outlive the Coordinator struct — cancellables, child coordinator references, and dependencies that need deallocation.
- **Rules:**
  - Always a `class`, never a struct
  - Coordinator holds a `let state: CoordinatorState` reference
  - No weak self needed when a struct captures a CoordinatorState — capture the class reference directly

```swift
final class FeatureCoordinatorState {
    var cancellables = Set<AnyCancellable>()
    var children: [any Coordinator] = []
}
```

---

## ActionDispatcher

```swift
struct ActionDispatcher<Action> {
    let send: (Action) -> Void

    init(_ send: @escaping (Action) -> Void) {
        self.send = send
    }

    func callAsFunction(_ action: Action) {
        send(action)
    }
}
```

- Always captures the `NavigationStream` reference directly — never captures `self` of a struct
- Created in `buildDispatcher()` and passed to the ViewModel via `init`

---

## make() — Screen Factory

Each Coordinator provides a `make()` extension that creates the ViewModel and View. This is the screen's entry point.

```swift
extension FeatureCoordinator {
    func make() -> any View {
        let dispatcher = buildDispatcher()
        let viewModel = FeatureViewModel(
            actionDispatcher: dispatcher,
            service: FeatureService(client: networkClient)
        )
        return FeatureView(viewModel: viewModel, navigationStream: navigationStream)
    }
}

extension ChildCoordinator {
    mutating func make(item: Item) -> any View {
        let viewModel = ChildViewModel(
            item: item,
            service: ChildService(client: networkClient)
        )
        return ChildView(viewModel: viewModel)
    }
}
```

---

## ViewModel

- **Type:** `class` with `@Observable`
- **Role:** Pure state container. Handles user actions via `ActionDispatcher`. Never navigates directly — dispatches actions and lets the Coordinator's dispatcher handle navigation.
- **Rules:**
  - Never holds a View reference
  - Receives `ActionDispatcher` and services via `init` — not from `@Dependency` directly
  - All published state is value types
  - Use `@ObservationIgnored` on services and tasks
  - Navigation via `dispatch(.someAction)` — coordinator decides the destination
  - No UIKit imports

```swift
@Observable
final class FeatureViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?

    let dispatch: ActionDispatcher<FeatureAction>

    @ObservationIgnored private let service: FeatureServicing
    @ObservationIgnored private var loadTask: Task<Void, Never>?

    init(actionDispatcher: ActionDispatcher<FeatureAction>, service: FeatureServicing) {
        self.dispatch = actionDispatcher
        self.service = service
    }

    func onItemTapped(_ item: Item) {
        dispatch(.showDetail(item))
    }

    func onLoad() async {
        isLoading = true
        defer { isLoading = false }
        do { items = try await service.fetch() }
        catch { self.error = error }
    }
}
```

---

## View

- **Type:** `struct` with `@MainActor`
- **Role:** Pure rendering. Owns `NavigationPath` and observes `NavigationStream`. Forwards all interactions to ViewModel.
- **Rules:**
  - No business logic
  - No direct service calls
  - Subscribes to `NavigationStream` via `.onReceive(navigationStream.compactMap { $0 })`
  - Use `.task` not `.onAppear` for data loading
  - `NavigationPath` lives here, not in ViewModel

```swift
@MainActor
struct FeatureView: View {
    @State var viewModel: FeatureViewModel
    @State private var path = NavigationPath()

    let navigationStream: NavigationStream<FeatureDestination>

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: FeatureDestination.self) { destination in
                    destination.view
                }
        }
        .onReceive(navigationStream.compactMap { $0 }) { destination in
            path.append(destination)
        }
        .task { await viewModel.onLoad() }
    }
}
```

---

## Dependency Flow

```
AppCoordinator
  @Dependency var networkClient: NetworkingClient   ← set at app root
       │
       │ add(&child)
       ▼
FeatureCoordinator
  @Dependency var networkClient: NetworkingClient   ← inherited
       │
       │ make() → buildDispatcher() + FeatureService(client: networkClient)
       ▼
FeatureViewModel              FeatureView
  dispatch: ActionDispatcher    navigationStream: NavigationStream<FeatureDestination>
       │                               │
       │ dispatch(.showDetail)         │ .onReceive(...)
       ▼                               ▼
  FeatureCoordinator.buildDispatcher closure → ChildCoordinator.make(item:)
```

Runtime changes (search results, load state) → ViewModel `@Observable` properties  
Navigation → `NavigationStream` destinations sent from `buildDispatcher` closure  
Dependency values → static after `add(_:)`, never swapped at runtime

---

## Rules Summary

| Layer | Type | Has @Dependency | Owns Stream | Mutates Nav |
|---|---|---|---|---|
| Coordinator | struct | yes | yes (creates) | yes (via buildDispatcher) |
| CoordinatorState | class | no | no | no |
| ViewModel | class (@Observable) | no (receives via init) | no | no (dispatches actions) |
| View | struct | no | yes (observes) | yes (owns NavigationPath) |

**No weak self on structs** — when a struct's closure needs to mutate state, capture the `CoordinatorState` class reference directly.

---

## When Fixing Existing Code

- Generic parameter on Coordinator struct shadows the Action enum → remove the generic parameter
- `@Dependency` field or `AnyCancellable` set in Coordinator struct → move to `CoordinatorState` class
- ViewModel navigates directly (holds `NavigationStream`) → replace with `ActionDispatcher`; let Coordinator's `buildDispatcher` send the destination
- `buildDispatcher` uses `self` in closure → capture only the stream (`let stream = navigationStream`)
- `coordinator.view` is `AnyView?` and used without unwrapping → use `guard let` before wrapping in `AnyView`
- Coordinator is a `class` → convert to `struct`, move cancellables/children to `CoordinatorState`
- View calls services directly → move to ViewModel
- Navigation uses `@State` booleans → replace with `NavigationStream` + destination enum
- Factory is a class → convert to struct extension on Coordinator (`make()`)
- `.onAppear` used for data loading → replace with `.task` + `hasLoaded` guard in ViewModel
- `PassthroughSubject` used as NavigationStream → replace with `CurrentValueSubject<D?, Never>(nil)`
