import Foundation

struct Reciter: Identifiable, Codable, Hashable {
    let id: Int
    let reciterName: String
    let style: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case reciterName = "reciter_name"
        case style
    }
}

struct RecitationsResponse: Codable {
    let recitations: [Reciter]
}
