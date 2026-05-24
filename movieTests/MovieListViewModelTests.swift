import Testing
import Foundation
@testable import movie

@Suite("MovieListViewModel")
@MainActor
struct MovieListViewModelTests {

    // MARK: - Initial state

    @Test func initialStateIsEmpty() {
        let vm = MovieListViewModel(
            actionDispatcher: ActionDispatcher { _ in },
            movieService: MockMovieServicing()
        )
        #expect(vm.items.isEmpty)
        #expect(vm.error == nil)
        #expect(vm.searchText.isEmpty)
    }

    // MARK: - onMovieTapped

    @Test func onMovieTappedDispatchesShowMovieDetail() {
        var dispatchedTitle: Title?
        let dispatcher = ActionDispatcher<MovieListAction> { action in
            if case .showMovieDetail(let t) = action { dispatchedTitle = t }
        }
        let vm = MovieListViewModel(actionDispatcher: dispatcher, movieService: MockMovieServicing())
        let title = Title.stub()

        vm.onMovieTapped(title)

        #expect(dispatchedTitle == title)
    }

    // MARK: - Search threshold

    @Test func searchTextEmptyClearsItems() {
        let vm = makeViewModel()
        vm.items = [.stub()]

        vm.searchText = ""

        #expect(vm.items.isEmpty)
    }

    @Test func searchTextExactlyThreeCharsClearsItems() {
        let vm = makeViewModel()
        vm.items = [.stub()]

        vm.searchText = "abc"

        #expect(vm.items.isEmpty)
    }

    @Test func searchTextBelowThresholdNeverCallsService() async throws {
        let service = MockMovieServicing()
        let vm = makeViewModel(service: service)

        vm.searchText = "ab"
        try await Task.sleep(for: .milliseconds(400))

        #expect(service.callCount == 0)
    }

    // MARK: - Search success

    @Test func searchTextFourCharsTriggersSearch() async throws {
        let service = MockMovieServicing()
        let expected = [Title.stub()]
        service.result = .success(expected)
        let vm = makeViewModel(service: service)

        vm.searchText = "abcd"
        try await Task.sleep(for: .milliseconds(400))

        #expect(vm.items == expected)
        #expect(service.callCount == 1)
        #expect(service.lastQuery == "abcd")
    }

    @Test func searchResultsReplaceItems() async throws {
        let service = MockMovieServicing()
        let results = [Title.stub(id: "tt1"), Title.stub(id: "tt2")]
        service.result = .success(results)
        let vm = makeViewModel(service: service)

        vm.searchText = "query"
        try await Task.sleep(for: .milliseconds(400))

        #expect(vm.items.count == 2)
    }

    // MARK: - Search error

    @Test func searchErrorSetsErrorProperty() async throws {
        let service = MockMovieServicing()
        service.result = .failure(URLError(.notConnectedToInternet))
        let vm = makeViewModel(service: service)

        vm.searchText = "abcd"
        try await Task.sleep(for: .milliseconds(400))

        #expect(vm.error != nil)
        #expect(vm.items.isEmpty)
    }

    // MARK: - Debounce / cancellation

    @Test func rapidTypingOnlyCallsServiceOnce() async throws {
        let service = MockMovieServicing()
        service.result = .success([.stub()])
        let vm = makeViewModel(service: service)

        vm.searchText = "abcd"
        vm.searchText = "abcde"
        vm.searchText = "abcdef"
        try await Task.sleep(for: .milliseconds(400))

        #expect(service.callCount == 1)
        #expect(service.lastQuery == "abcdef")
    }

    @Test func searchFollowedByShortTextCancelsAndClearsItems() async throws {
        let service = MockMovieServicing()
        service.result = .success([.stub()])
        let vm = makeViewModel(service: service)

        vm.searchText = "abcd"
        vm.searchText = "ab"
        try await Task.sleep(for: .milliseconds(400))

        #expect(vm.items.isEmpty)
        #expect(service.callCount == 0)
    }

    // MARK: - Helpers

    private func makeViewModel(service: MockMovieServicing? = nil) -> MovieListViewModel {
        MovieListViewModel(actionDispatcher: ActionDispatcher { _ in }, movieService: service ?? MockMovieServicing())
    }
}
