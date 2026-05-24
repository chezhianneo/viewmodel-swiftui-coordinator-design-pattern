//
//  Service.swift
//  movie
//
//  Created by Elan Arulraj on 6/25/25.
//

import Foundation

protocol Request {
    associatedtype HTTPBody: Encodable
    
    var path: String { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var httpBody: HTTPBody? { get }
}


protocol Response {
    associatedtype Response: Decodable
}


extension Request {
    var urlRequest : URLRequest? {
        get async throws {
            guard let url = URL(string: "https://api.imdbapi.dev" + self.path) else { return nil }
            var request = URLRequest(url: url)
            if let items = self.queryItems {
                request.url?.append(queryItems: items)
            }
            if let body = self.httpBody {
                request.httpBody = try JSONEncoder().encode(body)
            }
            return request
        }
    }
}

protocol NetworkingClient  {
    func execute<T:Request, R:Response>(_ request: T, _ response: R) async throws -> R.Response
}

public final class NetworkClient:NetworkingClient {
    
    public static let shared = NetworkClient()
    private let session: URLSession
    
    init(session: URLSession = .shared)  {
        self.session = session
    }
    
    func execute<T:Request, R:Response>(_ request: T,_ response:R) async throws -> R.Response  {
        guard let request = try await request.urlRequest else { throw URLError(.badURL)}
        let (data, response) = try await session.data(for: request)

        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpURLResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}
