import Combine
import CryptoKit
import Shared
import SwiftUI

/// Owns the surah being read, the gapless track playback, and verse synchronisation.
@MainActor
final class PlayerViewModel: ObservableObject {
    let reciter: Reciter
    let edition: RecitationEdition
    let player = VersePlayer()

    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var chapter: Chapter?
    @Published private(set) var verses: [Verse] = []
    @Published private(set) var timing: [VerseTiming]?
    @Published private(set) var trackUrl: String?
    @Published private(set) var verseIndex: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    @Published var repeatsSurah = false
    @Published var isShuffling = false
    @Published var isFavourite = false

    private let library: QuranLibrary
    private var playbackTrack: PlaybackTrack?
    private var playerChanges: AnyCancellable?

    init(library: QuranLibrary, reciter: Reciter, edition: RecitationEdition) {
        self.library = library
        self.reciter = reciter
        self.edition = edition

        playerChanges = player.objectWillChange.sink { [weak self] in
            guard let self else { return }
            self.updateVerseIndex()
        }
        player.onFinish = { [weak self] in self?.handleFinish() }
    }

    var hasTiming: Bool {
        edition.hasTiming && timing != nil && !(timing?.isEmpty ?? true)
    }

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

    // MARK: - Loading

    func start() async {
        guard chapters.isEmpty else { return }
        isLoading = true
        do {
            chapters = try await library.chapters()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false

        // Open first chapter available in this edition
        if let first = chapters.first(where: { edition.availableSurahs.contains(KotlinInt(int: $0.id)) }) ?? chapters.first {
            await open(first)
        }
    }

    func open(_ chapter: Chapter) async {
        player.clear()
        self.chapter = chapter
        self.verses = []
        self.timing = nil
        self.verseIndex = nil
        self.errorMessage = nil
        self.playbackTrack = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let track = try await library.surah(chapterId: chapter.id, editionId: edition.id)
            self.playbackTrack = track
            self.verses = track.verses
            self.timing = track.timing
            self.trackUrl = track.trackUrl
            if let url = URL(string: track.trackUrl) {
                player.load(url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Downloads

    func downloadStatus(for chapter: Chapter) -> DownloadStatus {
        library.download(editionId: edition.id, chapterId: chapter.id).status
    }

    func downloadCurrentChapter() async {
        guard let current = chapter else { return }
        await downloadChapter(current)
    }

    func downloadChapter(_ chapter: Chapter) async {
        guard chapter.id == self.chapter?.id, let playbackTrack else { return }
        library.beginDownload(editionId: edition.id, chapterId: chapter.id)
        objectWillChange.send()

        do {
            let padded = String(format: "%03d", chapter.id)
            let server = edition.serverBaseUrl.hasSuffix("/") ? edition.serverBaseUrl : "\(edition.serverBaseUrl)/"
            guard let remoteUrl = URL(string: "\(server)\(padded).mp3") else {
                library.failDownload(editionId: edition.id, chapterId: chapter.id, message: "Invalid audio URL")
                objectWillChange.send()
                return
            }

            let (tempUrl, response) = try await URLSession.shared.download(from: remoteUrl)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                library.failDownload(editionId: edition.id, chapterId: chapter.id, message: "Download failed")
                objectWillChange.send()
                return
            }

            let fileManager = FileManager.default
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let downloadsDir = appSupport.appendingPathComponent("Tilawa/downloads", isDirectory: true)
            try fileManager.createDirectory(at: downloadsDir, withIntermediateDirectories: true)

            let destFile = downloadsDir.appendingPathComponent("edition_\(edition.id)_surah_\(chapter.id).mp3")
            if fileManager.fileExists(atPath: destFile.path) {
                try fileManager.removeItem(at: destFile)
            }
            try fileManager.moveItem(at: tempUrl, to: destFile)

            let data = try Data(contentsOf: destFile, options: .mappedIfSafe)
            let checksum = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            library.completeDownload(
                chapterId: chapter.id,
                track: playbackTrack,
                localPath: destFile.absoluteString,
                checksumSha256: checksum,
                byteCount: Int64(data.count)
            )
            objectWillChange.send()
        } catch {
            library.failDownload(editionId: edition.id, chapterId: chapter.id, message: error.localizedDescription)
            objectWillChange.send()
        }
    }

    // MARK: - Transport

    func togglePlay() { player.toggle() }

    func next() {
        if hasTiming, let index = verseIndex, let timings = timing, index + 1 < timings.count {
            let nextTiming = timings[index + 1]
            player.seek(to: Double(nextTiming.startMs) / 1000.0)
        } else {
            nextChapter()
        }
    }

    func previous() {
        if player.elapsed > 2.0 {
            if hasTiming, let index = verseIndex, let timings = timing, index < timings.count {
                player.seek(to: Double(timings[index].startMs) / 1000.0)
            } else {
                player.restart()
            }
        } else {
            if hasTiming, let index = verseIndex, let timings = timing, index > 0 {
                player.seek(to: Double(timings[index - 1].startMs) / 1000.0)
            } else {
                previousChapter()
            }
        }
    }

    func seek(toFraction fraction: Double) {
        guard player.duration > 0 else { return }
        player.seek(to: fraction * player.duration)
    }

    func seekToVerse(number: Int) {
        guard let timings = timing, let match = timings.first(where: { $0.verseNumber == number }) else { return }
        player.seek(to: Double(match.startMs) / 1000.0)
    }

    private func updateVerseIndex() {
        guard hasTiming, let timingList = timing, !timingList.isEmpty else {
            if verseIndex != nil {
                verseIndex = nil
            }
            return
        }
        let elapsedMs = Int64(player.elapsed * 1000)
        let newIndex: Int?
        if let match = timingList.first(where: { elapsedMs >= $0.startMs && elapsedMs < $0.endMs }) {
            let direct = Int(match.verseNumber - 1)
            if verses.indices.contains(direct) && verses[direct].number == match.verseNumber {
                newIndex = direct
            } else {
                let index = verses.firstIndex(where: { $0.number == match.verseNumber }) ?? direct
                newIndex = verses.indices.contains(index) ? index : nil
            }
        } else if let first = timingList.first, elapsedMs < first.startMs {
            newIndex = 0
        } else if let last = timingList.last, elapsedMs >= last.endMs {
            newIndex = verses.count - 1
        } else {
            newIndex = nil
        }
        if verseIndex != newIndex {
            verseIndex = newIndex
        }
    }

    private func handleFinish() {
        if repeatsSurah {
            player.restart()
            player.play()
        } else {
            nextChapter()
        }
    }

    private func nextChapter() {
        guard let current = chapter, let currentIndex = chapters.firstIndex(of: current) else { return }
        let nextIndex = currentIndex + 1
        if chapters.indices.contains(nextIndex) {
            Task { await open(chapters[nextIndex]) }
        } else {
            player.pause()
        }
    }

    private func previousChapter() {
        guard let current = chapter, let currentIndex = chapters.firstIndex(of: current) else { return }
        let prevIndex = currentIndex - 1
        if chapters.indices.contains(prevIndex) {
            Task { await open(chapters[prevIndex]) }
        } else {
            player.restart()
        }
    }
}
