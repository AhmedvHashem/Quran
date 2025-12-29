import Foundation

struct AudioFile: Codable {
    let id: Int
    let audioUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case audioUrl = "audio_url"
    }
}

struct ChapterRecitationResponse: Codable {
    let audioFile: AudioFile
    
    enum CodingKeys: String, CodingKey {
        case audioFile = "audio_file"
    }
}
