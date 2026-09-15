import Shared

@main
struct InteropSmoke {
    static func main() async throws {
        let library = QuranLibrary()
        let chapters = try await library.chapters()
        precondition(chapters.count == 114)
        let reciters = try await library.reciters()
        precondition(reciters.failure == nil && !reciters.reciters.isEmpty)
        let editions = try await library.editions(reciterId: 123)
        precondition(editions.failure == nil)
        precondition(editions.editions.contains { $0.id == 123 })
        let result = try await library.surah(chapterId: 1, editionId: 123)
        precondition(result.failure == nil)
        let track = result.track!
        precondition(track.verses.count == 7)
        if let timing = track.timing, let first = timing.first {
            precondition(library.verseAt(positionMs: first.startMs, timing: timing)?.int32Value == first.verseNumber)
        }
        let invalid = try await library.surah(chapterId: 115, editionId: 123)
        precondition(invalid.failure?.code == .surahUnavailable && invalid.failure?.retryable == false)
        print("SKIE catalog, models and structured failures passed (\(reciters.reciters.count) reciters, \(track.timing?.count ?? 0) timing segments).")
    }
}
