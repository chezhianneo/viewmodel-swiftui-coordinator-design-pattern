import Foundation
import Combine

@Observable
final class MovieListViewModel {
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
