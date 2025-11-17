import Foundation

struct RecommendResponse: Codable {
    let items: [RecommendBook]
}

struct RecommendBook: Codable, Identifiable {
    var id: String { isbn13 }
    let isbn13: String
    let title: String
    let author: String
    let publisher: String
    let cover: String
    let similarity: Double
}
