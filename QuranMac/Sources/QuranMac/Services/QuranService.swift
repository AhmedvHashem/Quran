import Foundation

class QuranService {
    static let shared = QuranService()
    private let baseURL = "https://api.quran.com/api/v4"
    
    private init() {}
    
    func fetchChapters() async throws -> [Chapter] {
        let url = URL(string: "\(baseURL)/chapters?language=en")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ChaptersResponse.self, from: data)
        return response.chapters
    }
    
    func fetchVerses(chapterId: Int) async throws -> [Verse] {
        // Fetching all verses for a chapter. Using per_page=300 to likely get all in one go for most chapters.
        // ideally we should handle pagination, but for simplicity we start with a large limit.
        let url = URL(string: "\(baseURL)/verses/by_chapter/\(chapterId)?language=en&fields=text_uthmani&per_page=300")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(VersesResponse.self, from: data)
        return response.verses
    }
    
    func fetchReciters() async throws -> [Reciter] {
        let url = URL(string: "\(baseURL)/resources/recitations?language=en")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(RecitationsResponse.self, from: data)
        return response.recitations
    }
    
    func fetchChapterAudio(reciterId: Int, chapterId: Int) async throws -> String {
        let url = URL(string: "\(baseURL)/chapter_recitations/\(reciterId)/\(chapterId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ChapterRecitationResponse.self, from: data)
        return response.audioFile.audioUrl
    }
}
