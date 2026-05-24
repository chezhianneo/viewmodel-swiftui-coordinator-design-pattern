import Foundation
import SwiftUI
import Combine

enum MovieListAction {
    case showMovieDetail(Title)
}

enum MovieListDestination: NavigationDestination {
    case movieDetail(any View)

    static func == (lhs: MovieListDestination, rhs: MovieListDestination) -> Bool {
        switch (lhs, rhs) {
        case (.movieDetail, .movieDetail): return true
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .movieDetail: hasher.combine("movieDetail")
        }
    }

    var view: some View {
        switch self {
        case .movieDetail(let view): return AnyView(view)
        }
    }
}

struct MovieListCoordinator: Coordinator {
    private let navigationStream: NavigationStream<MovieListDestination>
    @Dependency var networkClient: NetworkingClient
    @Dependency var dummyClient: DummyClient

    init(_ navigationStream: NavigationStream<MovieListDestination> = NavigationStream<MovieListDestination>(nil),
         _ networkClient: NetworkingClient = NetworkClient()) {
        self.navigationStream = navigationStream
        self.networkClient = networkClient
    }

    func buildDispatcher() -> ActionDispatcher<MovieListAction> {
        let stream = navigationStream
        return ActionDispatcher<MovieListAction> { action in
            switch action {
            case .showMovieDetail(let title):
                var movieDetailCoordinator = MovieDetailCoordinator()
                self.add(&movieDetailCoordinator)
                let view = movieDetailCoordinator.make(title: title)
                stream.send(.movieDetail(AnyView(view)))
            }
        }
    }
}

extension MovieListCoordinator {
    mutating func make() -> any View {
        let dispatcher = buildDispatcher()
        let viewModel = MovieListViewModel(
            actionDispatcher: dispatcher,
            movieService: MovieService(client: networkClient)
        )
        return MovieListView(viewModel: viewModel, navigationStream: navigationStream)
    }
}
