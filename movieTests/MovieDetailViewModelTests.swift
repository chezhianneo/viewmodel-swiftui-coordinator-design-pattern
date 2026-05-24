import Testing
import Foundation
@testable import movie

@Suite("MovieDetailViewModel")
@MainActor
struct MovieDetailViewModelTests {

    // MARK: - Initial state

    @Test func initialState() {
        let title = Title.stub()
        let vm = MovieDetailViewModel(title: title, detailService: MockMovieDetailServicing())

        #expect(vm.title == title)
        #expect(vm.movie == nil)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    // MARK: - onLoad success

    @Test func onLoadFetchesDetailForTitle() async {
        let service = MockMovieDetailServicing()
        service.result = .success(.stub(id: "tt999"))
        let vm = MovieDetailViewModel(title: Title.stub(id: "tt999"), detailService: service)

        await vm.onLoad()

        #expect(vm.movie?.id == "tt999")
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        #expect(service.callCount == 1)
        #expect(service.lastTitleId == "tt999")
    }

    // MARK: - onLoad error

    @Test func onLoadSetsErrorMessageOnFailure() async {
        let service = MockMovieDetailServicing()
        service.result = .failure(URLError(.notConnectedToInternet))
        let vm = MovieDetailViewModel(title: Title.stub(), detailService: service)

        await vm.onLoad()

        #expect(vm.errorMessage != nil)
        #expect(vm.movie == nil)
        #expect(vm.isLoading == false)
    }

    // MARK: - hasLoaded guard

    @Test func onLoadCalledTwiceOnlyFetchesOnce() async {
        let service = MockMovieDetailServicing()
        service.result = .success(.stub())
        let vm = MovieDetailViewModel(title: Title.stub(), detailService: service)

        await vm.onLoad()
        await vm.onLoad()

        #expect(service.callCount == 1)
    }

    // MARK: - nil id guard

    @Test func onLoadWithNilIdSkipsFetch() async {
        let service = MockMovieDetailServicing()
        let vm = MovieDetailViewModel(title: Title.stub(id: nil), detailService: service)

        await vm.onLoad()

        #expect(service.callCount == 0)
        #expect(vm.movie == nil)
        #expect(vm.isLoading == false)
    }
}
