import AVFoundation
import Combine

/// Plays one gapless audio file at a time and reports playback position.
@MainActor
final class VersePlayer: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var elapsed: Double = 0
    @Published private(set) var duration: Double = 0
    @Published var volume: Float = 1 { didSet { player.volume = volume } }

    /// Called on the main actor when the current track reaches its end.
    var onFinish: (() -> Void)?

    private let player = AVPlayer()
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    init() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.elapsed = time.seconds
                self.duration = self.player.currentItem?.duration.seconds ?? 0
            }
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.onFinish?() }
        }
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    }

    /// Loads a track without starting it. A nil url clears the player.
    func load(_ url: URL?) {
        elapsed = 0
        duration = 0
        player.replaceCurrentItem(with: url.map(AVPlayerItem.init(url:)))
        player.volume = volume
        if url == nil { isPlaying = false }
    }

    func play() {
        guard player.currentItem != nil else { return }
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func toggle() { isPlaying ? pause() : play() }

    func seek(to seconds: Double) {
        let targetTime = CMTime(seconds: max(seconds, 0), preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func restart() { seek(to: 0) }

    func clear() {
        pause()
        load(nil)
    }
}
