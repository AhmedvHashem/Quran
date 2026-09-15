import Combine
import CryptoKit
import Shared
import SwiftUI

/// Owns reader state; playback and downloads are app-owned services.
@MainActor
final class PlayerViewModel: ObservableObject {
    let reciter: Reciter
    let edition: RecitationEdition
    let player: PlaybackController
    let downloads: DownloadController

    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var chapter: Chapter?
    @Published private(set) var verses: [Verse] = []
    @Published private(set) var timing: [VerseTiming]?
    @Published private(set) var verseIndex: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var textAvailability: TextAvailability?

    private let library: QuranLibrary
    private var playbackTrack: PlaybackTrack?
    private var elapsedChanges: AnyCancellable?
    private var loadGeneration = 0

    init(
        library: QuranLibrary,
        reciter: Reciter,
        edition: RecitationEdition,
        player: PlaybackController,
        downloads: DownloadController
    ) {
        self.library = library
        self.reciter = reciter
        self.edition = edition
        self.player = player
        self.downloads = downloads

        elapsedChanges = player.$elapsed.sink { [weak self] elapsed in
            self?.updateVerseIndex(at: elapsed)
        }
        player.onFinish = { [weak self] in self?.nextChapter() }
        player.onNext = { [weak self] in self?.next() }
        player.onPrevious = { [weak self] in self?.previous() }
    }

    var hasTiming: Bool { !(timing?.isEmpty ?? true) }

    var verse: Verse? {
        guard let index = verseIndex, verses.indices.contains(index) else { return nil }
        return verses[index]
    }

    var volume: Float {
        get { player.volume }
        set { player.volume = newValue }
    }

    var progress: Double {
        player.duration > 0 ? min(max(player.elapsed / player.duration, 0), 1) : 0
    }

    var availableChapters: [Chapter] { chapters.filter(isAvailable) }

    func isAvailable(_ chapter: Chapter) -> Bool {
        edition.availableSurahs.contains(KotlinInt(int: chapter.id))
    }

    // MARK: - Loading

    func start() async {
        guard chapters.isEmpty else { return }
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true
        errorMessage = nil
        do {
            let loaded = try await library.chapters()
            guard generation == loadGeneration else { return }
            chapters = loaded
            reconcileDownloads()
            isLoading = false
            if let first = availableChapters.first {
                await open(first)
            } else {
                errorMessage = "This recording has no available surahs."
            }
        } catch {
            guard generation == loadGeneration else { return }
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func open(_ chapter: Chapter) async {
        guard isAvailable(chapter) else {
            errorMessage = "\(chapter.name) is unavailable in this recording."
            return
        }

        loadGeneration += 1
        let generation = loadGeneration
        player.clear()
        self.chapter = chapter
        verses = []
        timing = nil
        verseIndex = nil
        errorMessage = nil
        textAvailability = nil
        playbackTrack = nil
        isLoading = true

        do {
            let result = try await library.surah(chapterId: chapter.id, editionId: edition.id)
            guard generation == loadGeneration else { return }
            guard let track = result.track else {
                errorMessage = result.failure?.message
                isLoading = false
                return
            }
            playbackTrack = track
            verses = track.verses
            timing = track.timing
            textAvailability = track.textAvailability
            guard let url = URL(string: track.trackUrl) else {
                throw URLError(.badURL)
            }
            player.load(
                url,
                metadata: PlaybackMetadata(
                    title: chapter.name,
                    artist: reciter.name,
                    album: "\(edition.riwayah.name) · \(edition.style)"
                )
            )
            isLoading = false
        } catch {
            guard generation == loadGeneration else { return }
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func retry() async {
        if let chapter { await open(chapter) } else { await start() }
    }

    // MARK: - Downloads

    func downloadStatus(for chapter: Chapter) -> DownloadStatus {
        library.download(editionId: edition.id, chapterId: chapter.id).status
    }

    func downloadProgress(for chapter: Chapter) -> Double? {
        downloads.progress(for: DownloadKey(editionId: edition.id, chapterId: chapter.id))
    }

    func toggleCurrentDownload() async {
        guard let chapter else { return }
        if downloadStatus(for: chapter) == .downloaded {
            removeDownload(chapter)
        } else {
            await downloadChapter(chapter)
        }
    }

    private func downloadChapter(_ chapter: Chapter) async {
        guard chapter.id == self.chapter?.id, let playbackTrack,
              let remoteURL = URL(string: playbackTrack.trackUrl), !remoteURL.isFileURL else { return }

        let files = FileManager.default
        let directory = files.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Tilawa/downloads", isDirectory: true)
        let finalFile = directory.appendingPathComponent("edition_\(edition.id)_surah_\(chapter.id).mp3")
        let stagingFile = finalFile.appendingPathExtension("part")
        let key = DownloadKey(editionId: edition.id, chapterId: chapter.id)

        library.beginDownload(editionId: edition.id, chapterId: chapter.id)
        objectWillChange.send()
        do {
            try files.createDirectory(at: directory, withIntermediateDirectories: true)
            let result = try await downloads.download(from: remoteURL, to: stagingFile, key: key)
            guard let response = result.response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  response.mimeType?.lowercased() != "text/html" else {
                throw URLError(.badServerResponse)
            }

            let data = try Data(contentsOf: result.file, options: .mappedIfSafe)
            guard !data.isEmpty else { throw URLError(.zeroByteResource) }
            let checksum = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()

            if files.fileExists(atPath: finalFile.path) {
                _ = try files.replaceItemAt(finalFile, withItemAt: result.file)
            } else {
                try files.moveItem(at: result.file, to: finalFile)
            }
            library.completeDownload(
                chapterId: chapter.id,
                track: playbackTrack,
                localPath: finalFile.absoluteString,
                checksumSha256: checksum,
                byteCount: Int64(data.count)
            )
            objectWillChange.send()
        } catch {
            try? files.removeItem(at: stagingFile)
            library.failDownload(editionId: edition.id, chapterId: chapter.id, message: error.localizedDescription)
            objectWillChange.send()
        }
    }

    private func removeDownload(_ chapter: Chapter) {
        let record = library.download(editionId: edition.id, chapterId: chapter.id)
        if let path = record.localPath, let url = URL(string: path), url.isFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        library.removeDownload(editionId: edition.id, chapterId: chapter.id)
        objectWillChange.send()
    }

    private func reconcileDownloads() {
        // ponytail: synchronous mapped-file hashing is simplest for v1; move it off-main if a large library profiles poorly.
        let files = FileManager.default
        for chapter in availableChapters {
            let record = library.download(editionId: edition.id, chapterId: chapter.id)
            if record.status == .downloading {
                library.failDownload(
                    editionId: edition.id,
                    chapterId: chapter.id,
                    message: "The previous download was interrupted. Retry to continue."
                )
                continue
            }
            guard record.status == .downloaded,
                  let path = record.localPath,
                  let url = URL(string: path), url.isFileURL else { continue }
            let data = try? Data(contentsOf: url, options: .mappedIfSafe)
            let checksum = data.map { SHA256.hash(data: $0).map { String(format: "%02x", $0) }.joined() }
            let reconciled = library.reconcileDownload(
                editionId: edition.id,
                chapterId: chapter.id,
                fileExists: data != nil,
                actualChecksumSha256: checksum,
                actualByteCount: data.map { KotlinLong(longLong: Int64($0.count)) }
            )
            if reconciled.status != .downloaded, files.fileExists(atPath: url.path) {
                try? files.removeItem(at: url)
            }
        }
        objectWillChange.send()
    }

    // MARK: - Transport

    func togglePlay() { player.toggle() }

    func next() {
        let elapsedMs = Int64(player.elapsed * 1000)
        if let next = timing?.first(where: { $0.startMs > elapsedMs + 50 }) {
            player.seek(to: Double(next.startMs) / 1000)
        } else {
            nextChapter()
        }
    }

    func previous() {
        let elapsedMs = Int64(player.elapsed * 1000)
        if player.elapsed > 2,
           let current = timing?.last(where: { $0.startMs <= elapsedMs }) {
            player.seek(to: Double(current.startMs) / 1000)
        } else if let previous = adjacentChapter(offset: -1) {
            Task { await open(previous) }
        } else {
            player.restart()
        }
    }

    func seek(toFraction fraction: Double) {
        guard player.duration > 0 else { return }
        player.seek(to: fraction * player.duration)
    }

    private func updateVerseIndex(at elapsed: Double) {
        guard let timing, !timing.isEmpty,
              let number = library.verseAt(positionMs: Int64(elapsed * 1000), timing: timing)?.int32Value else {
            verseIndex = nil
            return
        }
        verseIndex = verses.firstIndex(where: { $0.number == number })
    }

    private func nextChapter() {
        guard let next = adjacentChapter(offset: 1) else {
            player.pause()
            return
        }
        Task { await open(next) }
    }

    private func adjacentChapter(offset: Int) -> Chapter? {
        guard let current = chapter,
              let index = availableChapters.firstIndex(of: current) else { return nil }
        let target = index + offset
        return availableChapters.indices.contains(target) ? availableChapters[target] : nil
    }
}
