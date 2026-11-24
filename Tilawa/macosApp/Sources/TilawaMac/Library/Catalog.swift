import Shared
import SwiftUI

/// One surah in one edition, ready to play.
struct QueueItem: Equatable {
    let reciter: Reciter
    let edition: RecitationEdition
    let chapter: Chapter

    var recording: SurahRecording {
        SurahRecording(
            editionId: edition.id,
            chapterId: chapter.id,
            reciterId: reciter.id,
            reciterName: reciter.name,
            style: edition.style,
            riwayah: edition.riwayah.name
        )
    }
}

/// The reciter catalog, loaded once for the whole app: every screen and the
/// library destinations resolve reciters, editions and surahs through it.
@MainActor
final class Catalog: ObservableObject {
    @Published private(set) var reciters: [Reciter] = []
    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var isLoading = false
    @Published private(set) var failure: String?

    private(set) var editionsByReciter: [Int32: [RecitationEdition]] = [:]
    private var recitersById: [Int32: Reciter] = [:]
    private var editionsById: [Int32: RecitationEdition] = [:]
    private let library: QuranLibrary

    init(library: QuranLibrary) { self.library = library }

    var isLoaded: Bool { !reciters.isEmpty }

    func load() async {
        guard !isLoaded, !isLoading else { return }
        isLoading = true
        failure = nil
        defer { isLoading = false }
        do {
            if chapters.isEmpty { chapters = try await library.chapters() }
            let reciters = try await library.reciters()
            if let failure = reciters.failure { return self.failure = failure.message }
            let editions = try await library.allEditions()
            if let failure = editions.failure { return self.failure = failure.message }

            editionsByReciter = Dictionary(grouping: editions.editions, by: \.reciterId)
            editionsById = Dictionary(editions.editions.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            recitersById = Dictionary(reciters.reciters.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            self.reciters = reciters.reciters
        } catch {
            failure = error.localizedDescription
        }
    }

    func editions(of reciter: Reciter) -> [RecitationEdition] { editionsByReciter[reciter.id] ?? [] }

    /// The catalog's current name for a saved recording's reciter, else the saved snapshot.
    func reciterName(of recording: SurahRecording) -> String {
        reciter(recording.reciterId)?.name ?? recording.reciterName
    }

    func reciter(_ id: Int32) -> Reciter? { recitersById[id] }

    func edition(_ id: Int32) -> RecitationEdition? { editionsById[id] }

    func chapter(_ id: Int32) -> Chapter? {
        chapters.indices.contains(Int(id) - 1) ? chapters[Int(id) - 1] : nil
    }

    /// The edition a reciter's shortcuts play: the curated one, else the most complete.
    func preferredEdition(of reciter: Reciter) -> RecitationEdition? {
        editions(of: reciter).max { lhs, rhs in
            (lhs.isFeatured ? 1 : 0, lhs.availableSurahs.count) < (rhs.isFeatured ? 1 : 0, rhs.availableSurahs.count)
        }
    }

    /// The edition's surahs in muṣḥaf order. Unavailable surahs are never listed.
    func chapters(in edition: RecitationEdition) -> [Chapter] {
        // Bridged from Kotlin once: each access copies the whole set.
        let available = edition.availableSurahs
        return chapters.filter { available.contains(KotlinInt(int: $0.id)) }
    }

    /// Every available surah of an edition, as a queue.
    func queue(_ edition: RecitationEdition) -> [QueueItem] {
        guard let reciter = reciter(edition.reciterId) else { return [] }
        return chapters(in: edition).map { QueueItem(reciter: reciter, edition: edition, chapter: $0) }
    }

    /// A saved recording, or nil when it has left the catalog.
    func item(for recording: SurahRecording) -> QueueItem? {
        guard let edition = editionsById[recording.editionId],
              edition.availableSurahs.contains(KotlinInt(int: recording.chapterId)),
              let reciter = reciter(edition.reciterId),
              let chapter = chapter(recording.chapterId) else { return nil }
        return QueueItem(reciter: reciter, edition: edition, chapter: chapter)
    }
}

extension RecitationEdition {
    /// The short riwayah name, for chips and narrow columns.
    var riwayahShortName: String { riwayah.shortName }
}

extension Riwayah {
    var shortName: String { shortRiwayah(name) }
}

extension SurahRecording {
    var riwayahShortName: String { shortRiwayah(riwayah) }
}

/// `Ḥafṣ` from `Ḥafṣ ʿan ʿĀṣim`; also reads names saved before the formal spelling (`Hafs A'n Assem`).
private func shortRiwayah(_ name: String) -> String {
    name.components(separatedBy: " ʿan ")[0].components(separatedBy: " A'n ")[0]
}
