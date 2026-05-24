# Screen Architecture Skill

When this skill is invoked, implement or scaffold the coordinator pattern described below for the feature the user specifies. If no feature name is given, ask for one before proceeding.

## What to do when invoked

1. Ask the user: **what feature/screen are you building?** (e.g. "Profile", "Settings", "Checkout")
2. Use the feature name to generate all file names and type names (e.g. "Profile" → `ProfileCoordinator`, `ProfileViewModel`, `ProfileView`, `ProfileAction`, `ProfileDestination`)
3. Create the files listed in **Files to generate** below
4. Wire them together exactly as described in the pattern rules

---

## Pattern Overview

Every screen is composed of:
```
Coordinator (struct) → make() → ViewModel (class) + View (struct)
```

Dependencies flow **down** the Coordinator tree via `@Dependency` — never back up, never sideways.  
Navigation flows via `NavigationStream` — never via `@State` booleans or direct coordinator references.  
Coordinators are **one-shot wiring structs** — they live only long enough to call `make()`, then are released.

---

## Core Types (already exist in the project — do not recreate)

```swift
// NavigationStream — CurrentValueSubject, starts nil
typealias NavigationStream<D: NavigationDestination> = CurrentValueSubject<D?, Never>

// NavigationDestination — each screen's destination enum conforms to this
protocol NavigationDestination: Hashable {
    associatedtype Content: View
    @ViewBuilder var view: Content { get }
}

// ActionDispatcher — passed to ViewModel, callAsFunction sugar
struct ActionDispatcher<Action> {
    let send: (Action) -> Void
    init(_ send: @escaping (Action) -> Void) { self.send = send }
    func callAsFunction(_ action: Action) { send(action) }
}

// @Dependency — non-mutating because Storage is a class
@propertyWrapper
struct Dependency<Value> {
    private let storage = Storage()
    var wrappedValue: Value {
        get { storage.value! }
        nonmutating set { storage.value = newValue }
    }
    final class Storage { var value: Value? }
}

// Coordinator protocol
protocol Coordinator {
    associatedtype ActionType
    func buildDispatcher() -> ActionDispatcher<ActionType>
}

// add(_:) — propagates @Dependency values from parent to child by name
extension Coordinator {
    func add(_ child: inout some Coordinator) { /* Mirror-based propagation */ }
}
```

---

## Files to Generate

For a feature named **{Feature}**, create these files:

### 1. `{Feature}/{Feature}Coordinator.swift`

```swift
import Foundation
import SwiftUI
import Combine

// Actions the ViewModel can dispatch
enum {Feature}Action {
    // TODO: add cases e.g. case showDetail(Item)
}

// Destinations this screen can navigate to
enum {Feature}Destination: NavigationDestination {
    // TODO: add cases e.g. case detail(any View)

    static func == (lhs: {Feature}Destination, rhs: {Feature}Destination) -> Bool {
        // implement per case
    }

    func hash(into hasher: inout Hasher) {
        // implement per case
    }

    var view: some View {
        // return destination.view per case
    }
}

struct {Feature}Coordinator: Coordinator {
    typealias ActionType = {Feature}Action

    @Dependency var networkClient: NetworkingClient
    private let navigationStream = NavigationStream<{Feature}Destination>(nil)

    func buildDispatcher() -> ActionDispatcher<{Feature}Action> {
        let stream = navigationStream           // capture stream, not self
        return ActionDispatcher<{Feature}Action> { action in
            switch action {
            // TODO: handle each action, send destination to stream
            // case .showDetail(let item):
            //     var child = ChildCoordinator()
            //     self.add(&child)
            //     stream.send(.detail(AnyView(child.make(item: item))))
            }
        }
    }
}

extension {Feature}Coordinator {
    func make() -> any View {
        let dispatcher = buildDispatcher()
        let viewModel = {Feature}ViewModel(
            actionDispatcher: dispatcher,
            service: {Feature}Service(client: networkClient)
        )
        return {Feature}View(viewModel: viewModel, navigationStream: navigationStream)
    }
}
```

### 2. `{Feature}/{Feature}ViewModel.swift`

```swift
import Foundation
import Combine

@Observable
final class {Feature}ViewModel {
    // Published state — value types only
    var items: [Item] = []
    var isLoading = false
    var error: Error?

    let dispatch: ActionDispatcher<{Feature}Action>

    @ObservationIgnored private let service: {Feature}Servicing
    @ObservationIgnored private var loadTask: Task<Void, Never>?

    private var hasLoaded = false

    init(actionDispatcher: ActionDispatcher<{Feature}Action>, service: {Feature}Servicing) {
        self.dispatch = actionDispatcher
        self.service = service
    }

    func onLoad() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await service.fetch()
        } catch {
            self.error = error
        }
    }

    // Forward user interactions as actions
    func onItemTapped(_ item: Item) {
        dispatch(.showDetail(item))
    }
}
```

### 3. `{Feature}/{Feature}View.swift`

```swift
import SwiftUI
import Combine

@MainActor
struct {Feature}View: View {
    @State var viewModel: {Feature}ViewModel
    @State private var path = NavigationPath()

    let navigationStream: NavigationStream<{Feature}Destination>

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: {Feature}Destination.self) { destination in
                    destination.view
                }
                .navigationTitle("{Feature}")
        }
        .onReceive(navigationStream.compactMap { $0 }) { destination in
            path.append(destination)
        }
        .task { await viewModel.onLoad() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            List(viewModel.items) { item in
                // TODO: render item row
            }
        }
    }
}
```

---

## Rules to enforce when generating or reviewing code

**Coordinator**
- Always a `struct`, never a `class`
- Declare all external dependencies with `@Dependency`
- `buildDispatcher()` closure must capture `let stream = navigationStream` — never `self`
- `make()` is an extension, not part of the struct body
- No generic type parameters that shadow the `ActionType` enum
- No stored `AnyCancellable` or mutable state — those belong in a `CoordinatorState` class
- Released immediately after `make()` — do not store or pass around coordinators

**ViewModel**
- Always `class` with `@Observable`
- Receives `ActionDispatcher` and services via `init` — never `@Dependency` directly
- All observable state is value types
- Mark services and tasks `@ObservationIgnored`
- Use `hasLoaded` guard in `onLoad()` — call via `.task`, not `.onAppear`
- Dispatches actions → coordinator decides navigation; ViewModel never holds `NavigationStream`
- `[weak self]` only inside `Task` closures — never on struct captures

**View**
- Always `struct` with `@MainActor`
- Owns `NavigationPath` — ViewModel does not
- Observes stream via `.onReceive(navigationStream.compactMap { $0 })`
- Use `.task` for data loading, never `.onAppear`
- No business logic, no service calls

**NavigationStream**
- Created by the Coordinator, passed to ViewModel and View
- Views use `.compactMap { $0 }` because stream starts as `nil`
- Never replaced to change behavior — send a different destination instead

**@Dependency**
- Set by parent Coordinator via `add(&child)` before `make()` is called
- `nonmutating set` because `Storage` is a class — safe to copy the struct
- Accessing before injection triggers `fatalError`

---

## When reviewing existing code for this pattern

Flag and fix:
- Coordinator is a `class` → convert to `struct`
- Generic type parameter on Coordinator shadows Action enum → remove generic
- `buildDispatcher` captures `self` instead of stream → fix capture
- ViewModel holds `NavigationStream` directly → replace with `ActionDispatcher`
- View calls services directly → move to ViewModel
- `.onAppear` used for data loading → replace with `.task` + `hasLoaded`
- `AnyCancellable` stored in Coordinator struct → move to `CoordinatorState` class
- Navigation uses `@State` booleans → replace with `NavigationStream` destinations
- `AnyView` stored in destination enum → prefer `any View` with `AnyView` only at the call site
