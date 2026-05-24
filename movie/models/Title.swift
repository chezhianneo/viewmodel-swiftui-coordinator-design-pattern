//
//  Title.swift
//  movie
//
//  Created by Elan Arulraj on 6/25/25.
//

import Foundation

public struct Title: Decodable, Equatable, Identifiable, Hashable {
    public let id: String?
    public let type : String
    public let primaryTitle: String?
    public let originalTitle: String?
    let primaryImage: MovieImage?
    let rating: Rating?
    let startYear: Int?
    
    public static func ==(lhs: Title, rhs: Title) -> Bool {
        return lhs.id == rhs.id && lhs.primaryTitle == rhs.primaryTitle && lhs.originalTitle == rhs.originalTitle && lhs.startYear == rhs.startYear
        && lhs.primaryImage?.url == rhs.primaryImage?.url && lhs.rating?.aggregateRating == rhs.rating?.aggregateRating
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct MovieImage: Codable {
    let url: String?
    let height: CGFloat?
    let width: CGFloat?
}

public struct Rating: Codable {
    let aggregateRating: Double?
    let votesCount: Int?
}
