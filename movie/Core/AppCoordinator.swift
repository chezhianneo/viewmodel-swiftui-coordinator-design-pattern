import Foundation
import SwiftUI
import Combine

struct AppClient {}

struct DummyClient {
    func log(_ message: String) {
        print("[DummyClient] \(message)")
    }
}

enum AppAction {}

struct AppCoordinator: Coordinator {
    private let navigationStream: NavigationStream<AppDestination>
    @Dependency var dummyClient: DummyClient

    init(_ navigationStream: NavigationStream<AppDestination> = NavigationStream<AppDestination>(nil)) {
        self.navigationStream = navigationStream
        self.dummyClient = DummyClient()
        initMovieListCoordinator()
    }

    func initMovieListCoordinator() {
        var coordinator = MovieListCoordinator()
        add(&coordinator)
        navigationStream.send(.movieList(coordinator.make()))
    }

    func buildDispatcher() -> ActionDispatcher<AppAction> {
        return ActionDispatcher<AppAction> { _ in }
    }
}

extension AppCoordinator {
    func make() -> some View {
        return AppView(navigation: navigationStream)
    }
}
