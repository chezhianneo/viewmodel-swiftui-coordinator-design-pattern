import Foundation
import SwiftUI
import Combine

enum MovieDetailAction {}

enum MovieDetailNavigation: NavigationDestination {
    var view: some View {
        switch self { default: AnyView(EmptyView()) }
    }
}

struct MovieDetailCoordinator: Coordinator {
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
