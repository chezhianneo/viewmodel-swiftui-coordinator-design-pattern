import Foundation
import SwiftUI
@testable import movie

// MARK: - Mock Services

@MainActor
final class MockMovieServicing: MovieServicing {
    var result: Result<[Title], Error> = .success([])
    var callCount = 0
    var lastQuery: String?

    func search(query: String) async throws -> [Title] {
        callCount += 1
        lastQuery = query
        return try result.get()
    }
}

@MainActor
final class MockMovieDetailServicing: MovieDetailServicing {
    var result: Result<Movie, Error> = .success(.stub())
    var callCount = 0
    var lastTitleId: String?

    func fetchDetail(titleId: String) async throws -> Movie {
        callCount += 1
        lastTitleId = titleId
        return try result.get()
    }
}

@MainActor
final class MockNetworkingClient: NetworkingClient {
    func execute<T: Request, R: Response>(_ request: T, _ response: R) async throws -> R.Response {
        fatalError("not used in unit tests")
    }
}

// MARK: - Mock ViewModels

@MainActor
final class MockMovieListViewModel: MovieListViewModeling {
    var items: [Title] = []
    var searchText: String = ""
    var error: Error?
    var onMovieTappedCalled = false
    var lastTappedTitle: Title?

    func onMovieTapped(_ title: Title) {
        onMovieTappedCalled = true
        lastTappedTitle = title
    }
}

@MainActor
final class MockMovieDetailViewModel: MovieDetailViewModeling {
    var title: Title
    var movie: Movie?
    var isLoading = false
    var errorMessage: String?
    var onLoadCalled = false

    init(title: Title = .stub()) {
        self.title = title
    }

    func onLoad() async {
        onLoadCalled = true
    }
}

// MARK: - Mock Coordinators

struct MockMovieListCoordinator: MovieListCoordinating {
    typealias ActionType = MovieListAction
    var makeCalled = false

    func buildDispatcher() -> ActionDispatcher<MovieListAction> {
        ActionDispatcher { _ in }
    }

    mutating func make() -> any View {
        makeCalled = true
        return EmptyView()
    }
}

struct MockMovieDetailCoordinator: MovieDetailCoordinating {
    typealias ActionType = MovieDetailAction
    var makeCalled = false
    var lastTitle: Title?

    func buildDispatcher() -> ActionDispatcher<MovieDetailAction> {
        ActionDispatcher { _ in }
    }

    mutating func make(title: Title) -> any View {
        makeCalled = true
        lastTitle = title
        return EmptyView()
    }
}

// MARK: - Stubs

extension Title {
    static func stub(id: String? = "tt123", primaryTitle: String = "Test Movie") -> Title {
        Title(id: id, type: "movie", primaryTitle: primaryTitle,
              originalTitle: nil, primaryImage: nil, rating: nil, startYear: 2024)
    }
}

extension Movie {
    static func stub(id: String = "tt123") -> Movie {
        Movie(id: id, type: "movie", isAdult: false, primaryTitle: "Test Movie",
              originalTitle: nil, primaryImage: nil, startYear: 2024, endYear: nil,
              runtimeSeconds: nil, genres: nil, rating: nil, metacritic: nil,
              plot: nil, directors: nil, writers: nil, stars: nil,
              originCountries: nil, spokenLanguages: nil, interests: nil)
    }
}
