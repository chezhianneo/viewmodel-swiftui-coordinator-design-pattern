import Foundation

protocol MovieDetailServicing {
    func fetchDetail(titleId: String) async throws -> Movie
}

struct TitleDetailRequest: Request {
    typealias HTTPBody = Never

    let headers = [String: String]()
    var queryItems: [URLQueryItem]? { nil }
    var httpBody: HTTPBody? { nil }

    var path: String { "/titles/\(titleId)" }

    private let titleId: String

    init(titleId: String) {
        self.titleId = titleId
    }
}

struct TitleDetailResponse: Response {
    typealias Response = Movie
}

struct MovieDetailService: MovieDetailServicing {
    private let client: NetworkingClient

    init(client: NetworkingClient = NetworkClient.shared) {
        self.client = client
    }

    func fetchDetail(titleId: String) async throws -> Movie {
        try await client.execute(TitleDetailRequest(titleId: titleId), TitleDetailResponse())
    }
}
