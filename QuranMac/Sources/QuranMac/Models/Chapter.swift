import Foundation

struct Chapter: Identifiable, Codable, Hashable {
    let id: Int
    let nameSimple: String
    let nameArabic: String
    let versesCount: Int
    let translatedName: TranslatedName?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameSimple = "name_simple"
        case nameArabic = "name_arabic"
        case versesCount = "verses_count"
        case translatedName = "translated_name"
    }
}

struct TranslatedName: Codable, Hashable {
    let name: String
    let languageName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case languageName = "language_name"
    }
}

struct ChaptersResponse: Codable {
    let chapters: [Chapter]
}
