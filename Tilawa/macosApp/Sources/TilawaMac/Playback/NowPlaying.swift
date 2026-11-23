import AppKit
import Combine
import Shared
import SwiftUI

/// The queue the player works through and the surah it holds. Lives for the
/// whole app session, so playback survives every navigation.
@MainActor
final class NowPlaying: ObservableObject {
    let player: PlaybackController

    @Published private(set) var queue: [QueueItem] = []
    @Published private(set) var index: Int?
    @Published private(set) var timing: [VerseTiming]?
    /// The ayah at the media position; only a timed recording has one.
    @Published private(set) var ayah: Int32?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let library: QuranLibrary
    private let userLibrary: UserLibrary
    private var subscriptions: Set<AnyCancellable> = []
    private var loadGeneration = 0
    private var lastSaved = Date.distantPast

    init(library: QuranLibrary, player: PlaybackController, userLibrary: UserLibrary) {
        self.library = library
        self.player = player
        self.userLibrary = userLibrary

        player.$elapsed
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
        return queue[index]
    }

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
        guard items.indices.contains(start) else { return }
        Task { await open(at: start, in: items, positionMs: positionMs) }
    }

    func shuffle(_ items: [QueueItem]) {
        // ponytail: system shuffle; P0 still has to define the shuffle rule.
        play(items.shuffled())
    }

    func retry() {
        guard let index else { return }
        Task { await open(at: index) }
    }

    /// Saves where the current surah stopped, then loads `newIndex` of `items`.
    private func open(at newIndex: Int, in items: [QueueItem]? = nil, positionMs: Int64 = 0) async {
        let items = items ?? queue
        guard items.indices.contains(newIndex) else { return }
        saveSession()
        loadGeneration += 1
        let generation = loadGeneration
        player.clear()
        queue = items
        index = newIndex
        timing = nil
        ayah = nil
        errorMessage = nil
        isLoading = true

        let item = queue[newIndex]
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
        guard let index, index + 1 < queue.count else { return }
        Task { await open(at: index + 1) }
    }

    // MARK: - Transport

    func togglePlay() { player.toggle() }

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
            Task { await open(at: index - 1) }
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
        if let timing, !timing.isEmpty,
           let number = library.verseAt(positionMs: Int64(elapsed * 1000), timing: timing)?.int32Value, number > 0 {
            ayah = number
        } else {
            ayah = nil
        }
        if player.isPlaying, Date().timeIntervalSince(lastSaved) > 10 { saveSession() }
    }

    private func saveSession() {
        guard let item = current, player.duration > 0, player.elapsed > 1 else { return }
        lastSaved = Date()
        userLibrary.record(
            item.recording,
            positionMs: Int64(player.elapsed * 1000),
            durationMs: Int64(player.duration * 1000),
            ayah: ayah
        )
    }
}
