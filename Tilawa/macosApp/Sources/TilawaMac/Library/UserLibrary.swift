import Shared
import SwiftUI

/// Listening history and collections. The shared core owns the documents and
/// their rules; this republishes them for SwiftUI after every change.
@MainActor
final class UserLibrary: ObservableObject {
    @Published private(set) var sessions: [ListeningSession] = []
    @Published private(set) var collections: [RecitationCollection] = []

    private let library: QuranLibrary

    init(library: QuranLibrary) {
        self.library = library
        sessions = library.sessions()
        collections = library.collections()
    }

    private var nowMs: Int64 { Int64(Date().timeIntervalSince1970 * 1000) }

    // MARK: History

    func record(_ recording: SurahRecording, positionMs: Int64, durationMs: Int64, ayah: Int32?) {
        library.recordSession(
            recording: recording,
            positionMs: positionMs,
            durationMs: durationMs,
            ayah: ayah.map { KotlinInt(int: $0) },
            playedAtMs: nowMs
        )
        sessions = library.sessions()
    }

    func remove(_ session: ListeningSession) {
        library.removeSession(editionId: session.recording.editionId, chapterId: session.recording.chapterId)
        sessions = library.sessions()
    }

    func clearHistory() {
        library.clearHistory()
        sessions = []
    }

    // MARK: Collections

    var favorites: RecitationCollection { collections[0] }
    var userCollections: ArraySlice<RecitationCollection> { collections.dropFirst() }

    func collection(_ id: String) -> RecitationCollection? { collections.first { $0.id == id } }

    func contains(_ recording: SurahRecording, in collectionId: String) -> Bool {
        collection(collectionId)?.items.contains {
            $0.recording.editionId == recording.editionId && $0.recording.chapterId == recording.chapterId
        } ?? false
    }

    func isFavorite(_ recording: SurahRecording) -> Bool { contains(recording, in: favorites.id) }

    func toggleFavorite(_ recording: SurahRecording) {
        isFavorite(recording) ? remove(recording, from: favorites.id) : add(recording, to: favorites.id)
    }

    @discardableResult
    func create(named name: String) -> RecitationCollection? {
        defer { collections = library.collections() }
        return library.createCollection(name: name, nowMs: nowMs)
    }

    func rename(_ id: String, to name: String) {
        library.renameCollection(id: id, name: name, nowMs: nowMs)
        collections = library.collections()
    }

    func delete(_ id: String) {
        library.deleteCollection(id: id)
        collections = library.collections()
    }

    func move(_ id: String, toIndex index: Int) {
        library.moveCollection(id: id, toIndex: Int32(index))
        collections = library.collections()
    }

    func add(_ recording: SurahRecording, to id: String) {
        library.addToCollection(id: id, recording: recording, nowMs: nowMs)
        collections = library.collections()
    }

    func remove(_ recording: SurahRecording, from id: String) {
        library.removeFromCollection(id: id, editionId: recording.editionId, chapterId: recording.chapterId, nowMs: nowMs)
        collections = library.collections()
    }

    func moveItem(in id: String, from: Int, to: Int) {
        library.moveCollectionItem(id: id, fromIndex: Int32(from), toIndex: Int32(to), nowMs: nowMs)
        collections = library.collections()
    }
}
