import Foundation
import Combine

protocol MovieListViewModeling {
    /// The current list of titles matching the search query.
    var items: [Title] { get set }
    /// The current search input; triggers a debounced search when changed.
    var searchText: String { get set }
    /// Set when a search request fails.
    var error: Error? { get set }
    /// Called when the user taps a title row; dispatches navigation to the coordinator.
    func onMovieTapped(_ title: Title)
}

@Observable
final class MovieListViewModel: MovieListViewModeling {
    var items: [Title] = []
    var searchText: String = "" {
        didSet { onSearchTextChanged() }
    }
    var error: Error?

    let dispatch: ActionDispatcher<MovieListAction>

    @ObservationIgnored private let movieService: MovieServicing
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(actionDispatcher: ActionDispatcher<MovieListAction>,
         movieService: MovieServicing) {
        self.dispatch = actionDispatcher
        self.movieService = movieService
    }

    func onMovieTapped(_ title: Title) {
        dispatch.send(.showMovieDetail(title))
    }

    private func onSearchTextChanged() {
        searchTask?.cancel()

        guard searchText.count > 3 else {
            items = []
            return
        }

        let query = searchText
        searchTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            do {
                self.items = try await self.movieService.search(query: query)
            } catch {
                self.error = error
            }
        }
    }
}
