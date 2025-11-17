import Foundation

struct Book: Identifiable, Codable {
    var id: String { isbn13 }
    let title: String
    let author: String
    let description: String
    let cover: String
    let isbn13: String
    let publisher: String
    let categoryName: String
    let emotion: String
    let link: String
    var similarity: Double = 0.0
    
    var isBookmarked: Bool = false
}

