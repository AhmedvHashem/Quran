import Shared
import SwiftUI

/// The mushaf: surah ornament, a caption line, and the Uthmani text with the
/// playing ayah tinted only when timing is available.
struct ReadingPane: View {
    @ObservedObject var viewModel: PlayerViewModel
    @ObservedObject private var player: PlaybackController

    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        _player = ObservedObject(wrappedValue: viewModel.player)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let chapter = viewModel.chapter {
                        SurahOrnament(chapter: chapter)
                        Text("\(chapter.name)  ·  \(chapter.translatedName)  ·  \(chapter.versesCount) Verses")
                            .font(.caption)
                            .foregroundStyle(Theme.labelSecondary)
                    }
                    if !viewModel.verses.isEmpty {
                        Text(mushaf)
                            .font(Theme.arabic(33))
                            .lineSpacing(30)
                            .multilineTextAlignment(.center)
                            .environment(\.layoutDirection, .rightToLeft)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel(viewModel.verses.map(\.text).joined(separator: " "))
                    }
                }
                .padding(.top, 26)
                .padding(.bottom, 10)
                .padding(.horizontal, 52)
            }

            if viewModel.isLoading {
                ReaderStatus(title: "Preparing surah", symbol: "waveform", showsProgress: true)
            } else if let error = viewModel.errorMessage {
                ReaderStatus(title: "Unable to open surah", message: error, symbol: "exclamationmark.triangle") {
                    Task { await viewModel.retry() }
                }
            } else if viewModel.textAvailability == .audioOnly {
                ReaderStatus(
                    title: "Audio only",
                    message: "Compatible Quran text is unavailable for this riwayah. Audio playback remains available.",
                    symbol: "speaker.wave.2"
                )
            }

            if case .failed(let message) = player.state {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(.regularMaterial, in: Capsule())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.mushafSurface)
    }

    /// One flowing block of script.
    /// When timing exists, the current verse is tinted with Theme.accent;
    /// otherwise, all verses remain unhighlighted.
    private var mushaf: AttributedString {
        var attributed = AttributedString()
        for (index, verse) in viewModel.verses.enumerated() {
            var run = AttributedString("\(verse.text) \u{06DD}\(arabicIndic(verse.number)) ")
            let shouldHighlight = viewModel.hasTiming && viewModel.verseIndex == index
            run.foregroundColor = shouldHighlight ? Theme.accent : Theme.mushafText
            attributed.append(run)
        }
        return attributed
    }
}

private struct ReaderStatus: View {
    let title: String
    var message: String?
    let symbol: String
    var showsProgress = false
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            if showsProgress { ProgressView() } else { Image(systemName: symbol).font(.title) }
            Text(title).font(.headline)
            if let message {
                Text(message)
                    .font(.body)
                    .foregroundStyle(Theme.labelSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }
            if let retry { Button("Retry", action: retry) }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct SurahOrnament: View {
    let chapter: Chapter

    var body: some View {
        VStack(spacing: 2) {
            Text("سُورَةُ \(chapter.arabicName)")
                .font(Theme.arabic(29))
                .foregroundStyle(Theme.ornamentTitle)
            Text("\(revelation)  ·  \(arabicIndic(chapter.versesCount)) آيات")
                .font(Theme.arabic(14))
                .foregroundStyle(Theme.ornamentSubtitle)
        }
        .frame(width: 510)
        .padding(.vertical, 11)
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Theme.ornamentBorder.opacity(0.45), lineWidth: 1)
        }
        .padding(5)
        .background(Theme.ornamentSurface, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.ornamentBorder, lineWidth: 2)
        }
    }

    private var revelation: String {
        chapter.revelationPlace == .madinah ? "مدنية" : "مكية"
    }
}
