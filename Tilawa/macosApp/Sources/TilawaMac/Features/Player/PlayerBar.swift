import Shared
import SwiftUI

/// Present on every screen. It shows the observed player state, never the
/// last button pressed.
struct PlayerBar: View {
    @ObservedObject var nowPlaying: NowPlaying
    @ObservedObject private var player: PlaybackController
    @Environment(\.tilawaAccent) private var accent

    init(nowPlaying: NowPlaying) {
        self.nowPlaying = nowPlaying
        self._player = ObservedObject(wrappedValue: nowPlaying.player)
    }

    static let height: CGFloat = 88

    private var isEmpty: Bool { nowPlaying.current == nil }

    var body: some View {
        HStack(spacing: 16) {
            trackInfo.frame(width: 250, alignment: .leading)
            VStack(spacing: 7) {
                transport
                seekRow.frame(maxWidth: 460)
            }
            .frame(maxWidth: .infinity)
            trailing.frame(width: 250, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: Self.height)
        .surface(.plain, in: Rectangle(), fallback: Theme.playerSurface)
        .overlay(alignment: .top) { Theme.hairline.frame(height: 0.5) }
    }

    private var trackInfo: some View {
        HStack(spacing: 11) {
            ZStack {
                if let chapter = nowPlaying.current?.chapter {
                    ArabicGlyph(text: arabicIndic(chapter.id), size: 22)
                        .foregroundStyle(Theme.ornamentBorder)
                } else {
                    Image(systemName: "music.note").foregroundStyle(Theme.labelTertiary)
                }
            }
            .frame(width: 52, height: 52)
            .background(Theme.mushafSurface, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.hairline, lineWidth: 0.5))
            .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                if let item = nowPlaying.current {
                    SurahTitle(title: item.chapter.name, recording: item.recording)
                        .font(.system(size: 13, weight: .semibold))
                    RecordingByline(recording: item.recording)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.labelSecondary)
                } else {
                    Text("Not Playing")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.labelSecondary)
                }
                if let error = nowPlaying.errorMessage {
                    Text(error).font(.system(size: 11)).foregroundStyle(.red)
                } else if isEmpty {
                    Text("Choose a reciter to start listening")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.labelSecondary)
                }
            }
            .lineLimit(1)
        }
        .contextMenu {
            if let item = nowPlaying.current {
                RecordingActions(recording: item.recording, play: player.play)
            }
        }
    }

    private var transport: some View {
        HStack(spacing: 8) {
            transportButton("backward.end.fill", label: "Previous ayah or surah", action: nowPlaying.previous)

            playButton
                .help(player.isActive ? "Pause" : "Play")
                .accessibilityLabel(player.isActive ? "Pause" : "Play")

            transportButton("forward.end.fill", label: "Next ayah or surah", action: nowPlaying.next)
        }
        .disabled(isEmpty)
        .opacity(isEmpty ? 0.45 : 1)
    }

    /// The accent circle: prominent Liquid Glass on macOS 26, a flat fill below.
    @ViewBuilder
    private var playButton: some View {
        let glyph = ZStack {
            if player.state == .buffering || player.state == .preparing || nowPlaying.isLoading {
                ProgressView().controlSize(.small).tint(.white)
            } else {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 16))
            }
        }
        .foregroundStyle(.white)
        if #available(macOS 26, *) {
            Button(action: nowPlaying.togglePlay) { glyph.frame(width: 26, height: 26) }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
        } else {
            Button(action: nowPlaying.togglePlay) {
                glyph
                    .frame(width: 40, height: 40)
                    .background(accent, in: Circle())
                    .shadow(color: accent.opacity(0.35), radius: 4, y: 2)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private func transportButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14))
                .frame(width: 30, height: 30)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
    }

    private var seekRow: some View {
        HStack(spacing: 10) {
            Text(isEmpty ? "" : player.elapsed.clockTime)
                .frame(width: 44, alignment: .trailing)
            SeekBar(
                progress: nowPlaying.progress,
                markers: markers,
                onScrub: nowPlaying.seek(toFraction:)
            )
            .frame(height: 14)
            .disabled(isEmpty)
            Text(isEmpty || player.duration == 0 ? "" : player.duration.clockTime)
                .frame(width: 44, alignment: .leading)
        }
        .font(.system(size: 10).monospacedDigit())
        .foregroundStyle(Theme.labelSecondary)
    }

    /// Ayah boundaries as fractions of the surah; none for an untimed recording.
    private var markers: [Double] {
        guard nowPlaying.hasTiming, let timing = nowPlaying.timing, player.duration > 0 else { return [] }
        let durationMs = player.duration * 1000
        return timing.map { Double($0.startMs) / durationMs }.filter { $0 > 0 && $0 < 1 }
    }

    private var trailing: some View {
        HStack(spacing: 12) {
            if nowPlaying.errorMessage != nil {
                Button("Retry", action: nowPlaying.retry).glassPill().controlSize(.small)
            } else if let ayah = nowPlaying.ayah, let chapter = nowPlaying.current?.chapter {
                CapsuleTag(title: "Āyah \(ayah) of \(chapter.versesCount)", symbol: "waveform")
                    .accessibilityLabel("Ayah \(ayah) of \(chapter.versesCount)")
            }

            HStack(spacing: 7) {
                Image(systemName: "speaker.wave.1.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.labelSecondary)
                    .accessibilityHidden(true)
                Slider(value: $nowPlaying.volume, in: 0...1)
                    .controlSize(.mini)
                    .frame(width: 72)
                    .accessibilityLabel("Volume")
            }
        }
    }
}

/// The surah timeline. Timed recordings carry a tick at every ayah boundary.
private struct SeekBar: View {
    let progress: Double
    let markers: [Double]
    let onScrub: (Double) -> Void
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.segment).frame(height: 4)
                Capsule().fill(accent).frame(width: width * progress, height: 4)
                if markers.count < 120 {
                    ForEach(markers, id: \.self) { marker in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Theme.labelTertiary)
                            .frame(width: 1.5, height: 6)
                            .offset(x: width * marker)
                    }
                }
                Circle()
                    .fill(.white)
                    .overlay(Circle().strokeBorder(Color.black.opacity(0.12), lineWidth: 0.5))
                    .frame(width: 11, height: 11)
                    .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                    .offset(x: width * progress - 5.5)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onEnded { value in
                    onScrub(min(max(value.location.x / width, 0), 0.999))
                }
            )
        }
        .accessibilityElement()
        .accessibilityLabel("Position")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .accessibilityAdjustableAction { direction in
            onScrub(min(max(progress + (direction == .increment ? 0.05 : -0.05), 0), 0.999))
        }
    }
}
