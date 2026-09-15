import AVFoundation
import Combine
import MediaPlayer

enum PlaybackState: Equatable {
    case idle
    case preparing
    case buffering
    case playing
    case paused
    case ended
    case failed(String)
}

struct PlaybackMetadata {
    let title: String
    let artist: String
    let album: String
}

/// The app-owned player. Its observed AVFoundation state is the only playback truth.
@MainActor
final class PlaybackController: ObservableObject {
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var elapsed: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var buffered: Double = 0
    @Published var volume: Float = 1 { didSet { player.volume = volume } }

    var isPlaying: Bool { state == .playing }
    private var isActive: Bool { state == .playing || state == .buffering }
    var onFinish: (() -> Void)?
    var onNext: (() -> Void)?
    var onPrevious: (() -> Void)?

    private let player = AVPlayer()
    private var metadata: PlaybackMetadata?
    private var timeObserver: Any?
    private var playerStateObserver: NSKeyValueObservation?
    private var itemObservers: [NSKeyValueObservation] = []
    private var notificationObservers: [NSObjectProtocol] = []
    private var remoteTargets: [(MPRemoteCommand, Any)] = []

    init() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.elapsed = time.seconds.isFinite ? max(time.seconds, 0) : 0
                self.refreshDuration()
                self.updateNowPlaying()
            }
        }
        playerStateObserver = player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.refreshState() }
        }
        configureRemoteCommands()
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        itemObservers.forEach { $0.invalidate() }
        notificationObservers.forEach(NotificationCenter.default.removeObserver)
        remoteTargets.forEach { command, target in command.removeTarget(target) }
    }

    func load(_ url: URL?, metadata: PlaybackMetadata? = nil) {
        clearItemObservers()
        self.metadata = metadata
        elapsed = 0
        duration = 0
        buffered = 0

        guard let url else {
            player.replaceCurrentItem(with: nil)
            state = .idle
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.volume = volume
        state = .preparing
        observe(item)
        updateNowPlaying()
    }

    func play() {
        guard player.currentItem != nil else { return }
        if state == .ended { seek(to: 0) }
        player.play()
    }

    func pause() { player.pause() }

    func toggle() { isActive ? pause() : play() }

    func next() { onNext?() }

    func previous() { onPrevious?() }

    func seek(to seconds: Double) {
        player.seek(
            to: CMTime(seconds: max(seconds, 0), preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    func restart() { seek(to: 0) }

    func clear() { load(nil) }

    private func observe(_ item: AVPlayerItem) {
        itemObservers = [
            item.observe(\.status, options: [.initial, .new]) { [weak self, weak item] _, _ in
                DispatchQueue.main.async {
                    guard let self, let item, self.player.currentItem === item else { return }
                    self.refreshState()
                }
            },
            item.observe(\.duration, options: [.initial, .new]) { [weak self, weak item] _, _ in
                DispatchQueue.main.async {
                    guard let self, let item, self.player.currentItem === item else { return }
                    self.refreshDuration()
                }
            },
            item.observe(\.loadedTimeRanges, options: [.initial, .new]) { [weak self, weak item] _, _ in
                DispatchQueue.main.async {
                    guard let self, let item, self.player.currentItem === item else { return }
                    let end = item.loadedTimeRanges
                        .map(\.timeRangeValue)
                        .map { $0.start.seconds + $0.duration.seconds }
                        .filter(\.isFinite)
                        .max() ?? 0
                    self.buffered = max(end, 0)
                }
            },
        ]

        notificationObservers = [
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.elapsed = self.duration
                    self.state = .ended
                    self.updateNowPlaying()
                    self.onFinish?()
                }
            },
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main
            ) { [weak self] notification in
                MainActor.assumeIsolated {
                    let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
                    self?.state = .failed(error?.localizedDescription ?? "Playback failed")
                }
            },
        ]
    }

    private func clearItemObservers() {
        itemObservers.forEach { $0.invalidate() }
        itemObservers.removeAll()
        notificationObservers.forEach(NotificationCenter.default.removeObserver)
        notificationObservers.removeAll()
    }

    private func refreshDuration() {
        let seconds = player.currentItem?.duration.seconds ?? 0
        duration = seconds.isFinite && seconds > 0 ? seconds : 0
    }

    private func refreshState() {
        guard let item = player.currentItem else {
            state = .idle
            return
        }
        if item.status == .failed {
            state = .failed(item.error?.localizedDescription ?? player.error?.localizedDescription ?? "Playback failed")
            return
        }
        if item.status == .unknown {
            state = .preparing
            return
        }
        switch player.timeControlStatus {
        case .playing: state = .playing
        case .waitingToPlayAtSpecifiedRate: state = .buffering
        case .paused where state != .ended: state = .paused
        default: break
        }
        updateNowPlaying()
    }

    private func configureRemoteCommands() {
        let commands = MPRemoteCommandCenter.shared()
        remoteTargets = [
            (commands.playCommand, commands.playCommand.addTarget { [weak self] _ in
                DispatchQueue.main.async { self?.play() }
                return .success
            }),
            (commands.pauseCommand, commands.pauseCommand.addTarget { [weak self] _ in
                DispatchQueue.main.async { self?.pause() }
                return .success
            }),
            (commands.togglePlayPauseCommand, commands.togglePlayPauseCommand.addTarget { [weak self] _ in
                DispatchQueue.main.async { self?.toggle() }
                return .success
            }),
            (commands.nextTrackCommand, commands.nextTrackCommand.addTarget { [weak self] _ in
                DispatchQueue.main.async { self?.next() }
                return .success
            }),
            (commands.previousTrackCommand, commands.previousTrackCommand.addTarget { [weak self] _ in
                DispatchQueue.main.async { self?.previous() }
                return .success
            }),
            (commands.changePlaybackPositionCommand, commands.changePlaybackPositionCommand.addTarget { [weak self] event in
                guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                DispatchQueue.main.async { self?.seek(to: event.positionTime) }
                return .success
            }),
        ]
    }

    private func updateNowPlaying() {
        guard let metadata else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: metadata.title,
            MPMediaItemPropertyArtist: metadata.artist,
            MPMediaItemPropertyAlbumTitle: metadata.album,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1 : 0,
        ]
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
    }
}
