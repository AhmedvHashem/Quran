import Shared
import SwiftUI

struct PlayerBar: View {
    @ObservedObject var viewModel: PlayerViewModel
    @ObservedObject private var player: PlaybackController
    @ObservedObject private var downloads: DownloadController

    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        self._player = ObservedObject(wrappedValue: viewModel.player)
        self._downloads = ObservedObject(wrappedValue: viewModel.downloads)
    }

    var body: some View {
        HStack(spacing: 8) {
            nowPlaying.frame(width: 260)
            Spacer(minLength: 0)
            VStack(spacing: 6) {
                transport
                seekRow
            }
            .frame(width: 440)
            Spacer(minLength: 0)
            trailing.frame(width: 240)
        }
        .padding(.horizontal, 16)
        .frame(height: 100)
        .surface(.plain, in: .rect, fallback: Theme.playerSurface)
        .overlay(alignment: .top) { Theme.hairline.frame(height: 1) }
    }

    private var nowPlaying: some View {
        HStack(spacing: 11) {
            Artwork(size: 52, iconSize: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.chapter?.name ?? "—")
                    .font(.system(size: 13, weight: .semibold))
                Text("\(viewModel.reciter.name)  ·  \(viewModel.edition.style)")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.labelSecondary)
            }
            .lineLimit(1)

            Spacer(minLength: 0)

            if let current = viewModel.chapter {
                let status = viewModel.downloadStatus(for: current)
                Button(action: { Task { await viewModel.toggleCurrentDownload() } }) {
                    Group {
                        switch status {
                        case .notDownloaded:
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.labelSecondary)
                        case .downloading:
                            Group {
                                if let progress = viewModel.downloadProgress(for: current) {
                                    ProgressView(value: progress)
                                } else {
                                    ProgressView()
                                }
                            }
                            .controlSize(.small)
                            .frame(width: 18)
                        case .downloaded:
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.accent)
                        case .failed:
                            Image(systemName: "exclamationmark.arrow.circlepath")
                                .font(.system(size: 15))
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help(status == .downloaded ? "Remove offline download" : "Download surah for offline playback")
                .accessibilityLabel(status == .downloaded ? "Remove offline download" : "Download surah")
            }
        }
    }

    private var transport: some View {
        SurfaceGroup(spacing: 14) {
            HStack(spacing: 12) {
                IconButton(symbol: "backward.end.fill", size: 15, action: viewModel.previous)
                    .help("Previous verse or surah")
                    .accessibilityLabel("Previous verse or surah")

                Button(action: viewModel.togglePlay) {
                    ZStack {
                        Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 17))
                            .opacity(viewModel.player.state == .buffering ? 0 : 1)
                        if viewModel.player.state == .buffering {
                            ProgressView().controlSize(.small)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .surface(.tinted(Theme.accent), in: .circle, fallback: Theme.accent)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.verses.isEmpty)
                .help(viewModel.player.isPlaying ? "Pause" : "Play")
                .accessibilityLabel(viewModel.player.isPlaying ? "Pause" : "Play")

                IconButton(symbol: "forward.end.fill", size: 15, action: viewModel.next)
                    .help("Next verse or surah")
                    .accessibilityLabel("Next verse or surah")
            }
        }
    }

    private var seekRow: some View {
        HStack(spacing: 10) {
            Text(viewModel.player.elapsed.clockTime)
                .font(.system(size: 10))
                .foregroundStyle(Theme.labelSecondary)
                .frame(width: 32, alignment: .trailing)

            if viewModel.hasTiming, let timings = viewModel.timing, !timings.isEmpty {
                VerseSeekBar(
                    count: viewModel.verses.count,
                    current: viewModel.verseIndex ?? 0,
                    progress: viewModel.progress,
                    timing: timings,
                    durationMs: Int64(viewModel.player.duration * 1000),
                    onScrub: { viewModel.seek(toFraction: $0) }
                )
                .frame(height: 26)
            } else {
                ContinuousSeekBar(
                    progress: viewModel.progress,
                    onScrub: { viewModel.seek(toFraction: $0) }
                )
                .frame(height: 26)
            }

            Text(viewModel.player.duration.clockTime)
                .font(.system(size: 10))
                .foregroundStyle(Theme.labelSecondary)
                .frame(width: 32, alignment: .leading)
        }
    }

    private var trailing: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)
            if viewModel.hasTiming, let verseIndex = viewModel.verseIndex {
                HStack(spacing: 5) {
                    Image(systemName: "list.bullet").font(.system(size: 10))
                    Text("Verse \(verseIndex + 1) / \(max(viewModel.verses.count, 1))")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Theme.accent)
                .padding(.leading, 8)
                .padding(.trailing, 9)
                .frame(height: 26)
                .surface(.tinted(Theme.accent), in: .capsule, fallback: Theme.accent.opacity(0.1))
            } else {
                HStack(spacing: 5) {
                    Image(systemName: "book").font(.system(size: 10))
                    Text("\(max(viewModel.verses.count, 1)) Verses")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Theme.labelSecondary)
                .padding(.leading, 8)
                .padding(.trailing, 9)
                .frame(height: 26)
                .surface(.plain, in: .capsule, fallback: Color.gray.opacity(0.1))
            }

            Image(systemName: "speaker.wave.2.fill").font(.system(size: 11))
            Slider(value: $viewModel.volume, in: 0...1)
                .controlSize(.mini)
                .frame(width: 80)
                .accessibilityLabel("Volume")
        }
    }
}

/// The surah timeline for timed recitations, with ticks at verse boundaries.
private struct VerseSeekBar: View {
    let count: Int
    let current: Int
    let progress: Double
    let timing: [VerseTiming]
    let durationMs: Int64
    let onScrub: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                track(width: geo.size.width)
                ticks(width: geo.size.width)
                knob(width: geo.size.width)
                numbers(width: geo.size.width)
            }
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0).onEnded { value in
                    onScrub(min(max(value.location.x / geo.size.width, 0), 0.999))
                }
            )
        }
    }

    private func track(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule().fill(Theme.hairline).frame(height: 4)
            Capsule().fill(Theme.accent).frame(width: width * progress, height: 4)
        }
        .offset(y: 5)
    }

    private func ticks(width: CGFloat) -> some View {
        Path { path in
            for t in timing {
                let fraction: Double
                if durationMs > 0 {
                    fraction = Double(t.startMs) / Double(durationMs)
                } else {
                    fraction = Double(t.verseNumber - 1) / Double(max(count, 1))
                }
                if fraction > 0 && fraction < 1 {
                    path.addRoundedRect(
                        in: CGRect(x: width * fraction, y: 2, width: 1.5, height: 10),
                        cornerSize: CGSize(width: 0.75, height: 0.75)
                    )
                }
            }
        }
        .fill(Color.black.opacity(0.3))
    }

    private func knob(width: CGFloat) -> some View {
        Circle()
            .fill(.white)
            .overlay { Circle().strokeBorder(Color.black.opacity(0.15), lineWidth: 0.5) }
            .frame(width: 11, height: 11)
            .shadow(color: .black.opacity(0.2), radius: 1, y: 0.5)
            .offset(x: width * progress - 5.5, y: 1.5)
    }

    @ViewBuilder
    private func numbers(width: CGFloat) -> some View {
        if count <= 20 {
            ForEach(0..<count, id: \.self) { index in
                Text("\(index + 1)")
                    .font(.system(size: 8, weight: index == current ? .semibold : .regular))
                    .foregroundStyle(index == current ? Theme.accent : Theme.labelSecondary)
                    .frame(width: 14)
                    .offset(x: width * (Double(index) + 0.5) / Double(count) - 7, y: 16)
            }
        }
    }
}

/// Plain continuous seek bar for recitations without verse timing.
private struct ContinuousSeekBar: View {
    let progress: Double
    let onScrub: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                track(width: geo.size.width)
                knob(width: geo.size.width)
            }
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0).onEnded { value in
                    onScrub(min(max(value.location.x / geo.size.width, 0), 0.999))
                }
            )
        }
    }

    private func track(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule().fill(Theme.hairline).frame(height: 4)
            Capsule().fill(Theme.accent).frame(width: width * progress, height: 4)
        }
        .offset(y: 5)
    }

    private func knob(width: CGFloat) -> some View {
        Circle()
            .fill(.white)
            .overlay { Circle().strokeBorder(Color.black.opacity(0.15), lineWidth: 0.5) }
            .frame(width: 11, height: 11)
            .shadow(color: .black.opacity(0.2), radius: 1, y: 0.5)
            .offset(x: width * progress - 5.5, y: 1.5)
    }
}
