import Foundation
import SwiftUI
import Combine

enum MovieDetailAction {}
enum MovieDetailNavigation: NavigationDestination {
    var view: some View {
        switch self {default:
            AnyView(EmptyView())
        }
    }
}

struct MovieDetailCoordinator: Coordinator {

    //Dependency
    @Dependency var networkClient: NetworkingClient
    private let navigationStream = NavigationStream<MovieDetailNavigation>(nil)
    init() {}

    func buildDispatcher() -> ActionDispatcher<MovieDetailAction> {
        return ActionDispatcher<MovieDetailAction>{_ in }
    }
}

extension MovieDetailCoordinator {
    mutating func make(title: Title) -> any View {
        let viewModel = MovieDetailViewModel(title: title, detailService: MovieDetailService(client: networkClient))
        let view = AnyView(MovieDetailView(viewModel: viewModel))
        return view
    }
}
