import Foundation

struct Movie: Identifiable, Decodable {
    let id: String?
    let type: String?
    let isAdult: Bool?
    let primaryTitle: String?
    let originalTitle: String?
    let primaryImage: DetailImage?
    let startYear: Int?
    let endYear: Int?
    let runtimeSeconds: Int?
    let genres: [String]?
    let rating: MovieRating?
    let metacritic: Metacritic?
    let plot: String?
    let directors: [Person]?
    let writers: [Person]?
    let stars: [Person]?
    let originCountries: [Country]?
    let spokenLanguages: [Language]?
    let interests: [Interest]?
}

struct MovieRating: Decodable {
    let aggregateRating: Double?
    let voteCount: Int?
}

struct Metacritic: Decodable {
    let url: String?
    let score: Int?
    let reviewCount: Int?
}

struct Person: Identifiable, Decodable {
    let id: String?
    let displayName: String?
    let alternativeNames: [String]?
    let primaryImage: DetailImage?
    let primaryProfessions: [String]?
    let biography: String?
    let heightCm: Int?
    let birthName: String?
    let birthDate: DateComponents?
    let birthLocation: String?
    let deathDate: DateComponents?
    let deathLocation: String?
    let deathReason: String?
    let meterRanking: MeterRanking?

    struct DateComponents: Decodable {
        let year: Int?
        let month: Int?
        let day: Int?
    }

    struct MeterRanking: Decodable {
        let currentRank: Int?
        let changeDirection: String?
        let difference: Int?
    }
}

struct Country: Decodable {
    let code: String?
    let name: String?
}

struct Language: Decodable {
    let code: String?
    let name: String?
}

struct Interest: Identifiable, Decodable {
    let id: String?
    let name: String?
    let primaryImage: DetailImage?
    let description: String?
    let isSubgenre: Bool?
}

struct DetailImage: Decodable {
    let url: String?
    let width: Int?
    let height: Int?
    let type: String?
}

