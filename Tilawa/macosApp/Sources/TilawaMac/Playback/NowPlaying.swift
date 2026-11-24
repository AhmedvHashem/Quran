import AppKit
import Combine
import Shared
import SwiftUI

struct QueueEntry: Identifiable {
    let id = UUID()
    let item: QueueItem
}

/// The queue the player works through and the surah it holds. Lives for the
/// whole app session, so playback survives every navigation.
@MainActor
final class NowPlaying: ObservableObject {
    let player: PlaybackController

    @Published private var queue: [QueueEntry] = []
    @Published private var index: Int?
    @Published private(set) var timing: [VerseTiming]?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let library: QuranLibrary
    private let history: ListeningHistory
    private var subscriptions: Set<AnyCancellable> = []
    private var loadGeneration = 0
    private var lastSaved = Date.distantPast

    init(library: QuranLibrary, player: PlaybackController, history: ListeningHistory) {
        self.library = library
        self.player = player
        self.history = history

        player.clock.$elapsed
            .sink { [weak self] elapsed in self?.elapsedChanged(elapsed) }
            .store(in: &subscriptions)
        // A pause and the end of a surah are natural resume points.
        player.$state
            .filter { $0 == .paused || $0 == .ended }
            .sink { [weak self] _ in self?.saveSession() }
            .store(in: &subscriptions)
        NotificationCenter.default
            .publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in self?.saveSession() }
            .store(in: &subscriptions)

        player.onFinish = { [weak self] in self?.advance() }
        player.onNext = { [weak self] in self?.next() }
        player.onPrevious = { [weak self] in self?.previous() }
    }

    var current: QueueItem? {
        guard let index, queue.indices.contains(index) else { return nil }
        return queue[index].item
    }

    var upcoming: ArraySlice<QueueEntry> { queue.dropFirst((index ?? -1) + 1) }

    var canPlay: Bool { !queue.isEmpty }

    /// The ayah at the media position; only a timed recording has one.
    var ayah: Int32? { player.clock.ayah }

    var hasTiming: Bool { !(timing?.isEmpty ?? true) }

    var volume: Float {
        get { player.volume }
        set { player.volume = newValue }
    }

    var progress: Double {
        player.duration > 0 ? min(max(player.elapsed / player.duration, 0), 1) : 0
    }

    func isCurrent(_ recording: SurahRecording) -> Bool {
        current.map { $0.edition.id == recording.editionId && $0.chapter.id == recording.chapterId } ?? false
    }

    // MARK: - Queue

    /// Plays `items` from `start`, resuming at `positionMs` when given.
    func play(_ items: [QueueItem], startingAt start: Int = 0, positionMs: Int64 = 0) {
        open(at: start, in: items.map(QueueEntry.init), positionMs: positionMs)
    }

    func shuffle(_ items: [QueueItem]) {
        // ponytail: system shuffle; P0 still has to define the shuffle rule.
        play(items.shuffled())
    }

    func retry() {
        guard let index else { return }
        open(at: index)
    }

    func enqueue(_ item: QueueItem, next: Bool = false) {
        let insertion = next ? upcoming.startIndex : queue.endIndex
        queue.insert(QueueEntry(item: item), at: insertion)
    }

    func playQueued(_ id: QueueEntry.ID) {
        guard let position = upcoming.firstIndex(where: { $0.id == id }) else { return }
        open(at: position)
    }

    func moveQueued(_ id: QueueEntry.ID, to target: QueueEntry.ID) {
        guard id != target,
              let source = upcoming.firstIndex(where: { $0.id == id }),
              let destination = upcoming.firstIndex(where: { $0.id == target }) else { return }
        queue.move(fromOffsets: IndexSet(integer: source), toOffset: destination + (source < destination ? 1 : 0))
    }

    func removeQueued(_ id: QueueEntry.ID) {
        guard let position = upcoming.firstIndex(where: { $0.id == id }) else { return }
        queue.remove(at: position)
    }

    func clearUpcoming() {
        queue.removeSubrange(upcoming.indices)
    }

    /// Saves where the current surah stopped, then loads `newIndex` of `items`.
    private func open(at newIndex: Int, in items: [QueueEntry]? = nil, positionMs: Int64 = 0) {
        guard (items ?? queue).indices.contains(newIndex) else { return }
        saveSession()
        loadGeneration += 1
        let generation = loadGeneration
        player.clear()
        if let items { queue = items }
        index = newIndex
        timing = nil
        player.clock.ayah = nil
        errorMessage = nil
        isLoading = true

        let item = queue[newIndex].item
        Task { await load(item, generation: generation, positionMs: positionMs) }
    }

    private func load(_ item: QueueItem, generation: Int, positionMs: Int64) async {
        guard generation == loadGeneration else { return }
        do {
            let result = try await library.surah(chapterId: item.chapter.id, editionId: item.edition.id)
            guard generation == loadGeneration else { return }
            isLoading = false
            guard let track = result.track, let url = URL(string: track.trackUrl) else {
                errorMessage = result.failure?.message ?? "This surah can't be played right now."
                return
            }
            timing = track.timing
            player.load(
                url,
                metadata: PlaybackMetadata(
                    title: item.chapter.name,
                    artist: item.reciter.name,
                    album: "\(item.edition.riwayah.name) · \(item.edition.style)"
                ),
                startAt: Double(positionMs) / 1000,
                autoplay: true
            )
        } catch {
            guard generation == loadGeneration else { return }
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    /// Continues to the next queued surah, or stops at the end of the queue.
    private func advance() {
        guard !upcoming.isEmpty else { return }
        open(at: upcoming.startIndex)
    }

    // MARK: - Transport

    func togglePlay() {
        if current == nil { advance() } else { player.toggle() }
    }

    /// The next ayah in a timed surah, otherwise the next surah.
    func next() {
        let elapsedMs = Int64(player.elapsed * 1000)
        if let next = timing?.first(where: { $0.startMs > elapsedMs + 50 }) {
            player.seek(to: Double(next.startMs) / 1000)
        } else {
            advance()
        }
    }

    /// The start of this ayah, otherwise the previous surah.
    func previous() {
        let elapsedMs = Int64(player.elapsed * 1000)
        if player.elapsed > 2, let current = timing?.last(where: { $0.startMs <= elapsedMs }) {
            player.seek(to: Double(current.startMs) / 1000)
        } else if let index, index > 0 {
            open(at: index - 1)
        } else {
            player.restart()
        }
    }

    func seek(toFraction fraction: Double) {
        guard player.duration > 0 else { return }
        player.seek(to: fraction * player.duration)
    }

    // MARK: - History

    private func elapsedChanged(_ elapsed: Double) {
        var number: Int32?
        if let timing, !timing.isEmpty,
           let verse = library.verseAt(positionMs: Int64(elapsed * 1000), timing: timing)?.int32Value, verse > 0 {
            number = verse
        }
        if player.clock.ayah != number { player.clock.ayah = number }
        if player.isPlaying, Date().timeIntervalSince(lastSaved) > 10 { saveSession() }
    }

    private func saveSession() {
        guard let item = current, player.duration > 0, player.elapsed > 1 else { return }
        lastSaved = Date()
        history.record(
            item.recording,
            positionMs: Int64(player.elapsed * 1000),
            durationMs: Int64(player.duration * 1000),
            ayah: ayah
        )
    }
}
