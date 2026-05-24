import Foundation
import SwiftUI
import Combine

typealias NavigationStream<D: NavigationDestination> = CurrentValueSubject<D?, Never>

protocol NavigationDestination: Hashable {
    associatedtype Content: View
    
    @ViewBuilder
    var view: Content { get }
}

// MARK: - Action Dispatcher
struct ActionDispatcher<Action> {
    let send: (Action) -> Void

    init(_ send: @escaping (Action) -> Void) {
        self.send = send
    }
    
    func callAsFunction(_ action: Action) {
        send(action)
    }
}


// MARK: - @Dependency Property Wrapper
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

// MARK: - DependencySettable

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

// MARK: - CoordinatorNode

protocol Coordinator {
    associatedtype ActionType
    func buildDispatcher() -> ActionDispatcher<ActionType>
}

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
