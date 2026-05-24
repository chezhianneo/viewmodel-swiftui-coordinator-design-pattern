import Foundation
import SwiftUI
import Combine

enum MovieDetailAction {}

enum MovieDetailNavigation: NavigationDestination {
    var view: some View {
        switch self { default: AnyView(EmptyView()) }
    }
}

protocol MovieDetailCoordinating: Coordinator {
    /// Wires the ViewModel and View together for the given title and returns the detail view.
    mutating func make(title: Title) -> any View
}

struct MovieDetailCoordinator: MovieDetailCoordinating {
    @Dependency var networkClient: NetworkingClient
    @Dependency var dummyClient: DummyClient
    private let navigationStream = NavigationStream<MovieDetailNavigation>(nil)

    init() {}

    func buildDispatcher() -> ActionDispatcher<MovieDetailAction> {
        return ActionDispatcher<MovieDetailAction> { _ in }
    }
}

extension MovieDetailCoordinator {
    mutating func make(title: Title) -> any View {
        dummyClient.log("MovieDetailCoordinator.make — dependency wired ✓")
        let viewModel = MovieDetailViewModel(
            title: title,
            detailService: MovieDetailService(client: networkClient)
        )
        return AnyView(MovieDetailView(viewModel: viewModel))
    }
}
