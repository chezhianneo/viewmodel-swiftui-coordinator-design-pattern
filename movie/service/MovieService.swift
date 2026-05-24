import Foundation

protocol MovieServicing {
    func search(query: String) async throws -> [Title]
}

enum MovieAPIError: Error {
    case invalidURL
}

struct SearchRequest: Request {
    typealias HTTPBody = Never

    let headers = [String: String]()

    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "query", value: query)]
    }

    var httpBody: HTTPBody? { nil }

    var path: String { "/search/titles" }

    private let query: String

    init(query: String) {
        self.query = query
    }
}

struct SearchResponse: Response {
    typealias Response = Titles
}

struct MovieService: MovieServicing {
    private let client: NetworkingClient

    init(client: NetworkingClient = NetworkClient.shared) {
        self.client = client
    }

    func search(query: String) async throws -> [Title] {
        let titles = try await client.execute(SearchRequest(query: query), SearchResponse())
        return titles.titles ?? []
    }
}
