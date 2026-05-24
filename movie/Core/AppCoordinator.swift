import Foundation
import SwiftUI
import Combine


enum AppAction {}

struct AppCoordinator: Coordinator {
    private let navigationStream: NavigationStream<AppDestination>

    init(_ navigationStream: NavigationStream<AppDestination> = NavigationStream<AppDestination>(nil)) {
        self.navigationStream = navigationStream
        initMovieListCoordinator()
    }

    func initMovieListCoordinator() {
        var coordinator = MovieListCoordinator()
        add(&coordinator)
        navigationStream.send(.movieList(coordinator.make()))
    }

    func buildDispatcher() -> ActionDispatcher<AppAction> {
        return ActionDispatcher<AppAction> {_ in }
    }
}

extension AppCoordinator {
    func make() -> some View {
        return AppView(navigation: navigationStream)
    }
}
