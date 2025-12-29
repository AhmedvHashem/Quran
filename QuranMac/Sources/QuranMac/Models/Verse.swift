import Foundation

struct Verse: Identifiable, Codable, Hashable {
    let id: Int
    let verseNumber: Int
    let verseKey: String
    let textUthmani: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case verseNumber = "verse_number"
        case verseKey = "verse_key"
        case textUthmani = "text_uthmani"
    }
}

struct VersesResponse: Codable {
    let verses: [Verse]
    let pagination: Pagination
}

struct Pagination: Codable {
    let totalRecords: Int
    
    enum CodingKeys: String, CodingKey {
        case totalRecords = "total_records"
    }
}
