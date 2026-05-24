import Testing
import Foundation
import Combine
@testable import movie

@Suite("MovieListCoordinator")
@MainActor
struct MovieListCoordinatorTests {

    @Test func buildDispatcherSendsMovieDetailToStream() {
        let stream = NavigationStream<MovieListDestination>(nil)
        let coordinator = MovieListCoordinator(stream, MockNetworkingClient())

        var received: MovieListDestination?
        let cancellable = stream.compactMap { $0 }.sink { received = $0 }

        let dispatcher = coordinator.buildDispatcher()
        dispatcher(MovieListAction.showMovieDetail(.stub()))

        #expect(received != nil)
        _ = cancellable
    }

    @Test func makeReturnsViewWithoutCrash() {
        let stream = NavigationStream<MovieListDestination>(nil)
        var coordinator = MovieListCoordinator(stream, MockNetworkingClient())
        _ = coordinator.make()
    }
}

@Suite("MovieDetailCoordinator")
@MainActor
struct MovieDetailCoordinatorTests {

    @Test func buildDispatcherReturnsWithoutCrash() {
        let coordinator = MovieDetailCoordinator()
        coordinator.networkClient = MockNetworkingClient()
        coordinator.dummyClient = DummyClient()
        _ = coordinator.buildDispatcher()
    }

    @Test func makeReturnsViewWithoutCrash() {
        var coordinator = MovieDetailCoordinator()
        coordinator.networkClient = MockNetworkingClient()
        coordinator.dummyClient = DummyClient()
        _ = coordinator.make(title: .stub())
    }
}
