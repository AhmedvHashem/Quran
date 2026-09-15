import Shared
import SwiftUI

struct ChapterSidebar: View {
    @ObservedObject var viewModel: PlayerViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Returns to the reciter's edition/riwayah detail screen
                IconButton(symbol: "chevron.left", size: 13) {
                    router.backToDetail(viewModel.reciter)
                }
                .help("Back to recordings")

                Spacer()
            }
            .padding(.leading, 74)
            .frame(height: Theme.titleBarHeight)

            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(viewModel.chapters, id: \.self) { chapter in
                        let available = viewModel.isAvailable(chapter)
                        Button {
                            Task { await viewModel.open(chapter) }
                        } label: {
                            ChapterRow(
                                chapter: chapter,
                                isSelected: chapter.id == viewModel.chapter?.id,
                                isAvailable: available,
                                downloadStatus: viewModel.downloadStatus(for: chapter)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!available)
                        .help(available ? "Open \(chapter.name)" : "Unavailable in this recording")
                        .accessibilityLabel("\(chapter.name), \(chapter.arabicName)")
                        .accessibilityHint(available ? "Open surah" : "Unavailable in this recording")
                    }
                }
                .padding(.horizontal, 9)
            }
        }
        .background(Theme.sidebarSurface)
    }
}

private struct ChapterRow: View {
    let chapter: Chapter
    let isSelected: Bool
    let isAvailable: Bool
    let downloadStatus: DownloadStatus

    var body: some View {
        HStack(spacing: 9) {
            Text("\(chapter.id)")
                .font(.system(size: 11))
                .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Theme.labelSecondary)
                .frame(width: 18, alignment: .trailing)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Text(chapter.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : (isAvailable ? .primary : Theme.labelSecondary))

                    if downloadStatus == .downloaded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(isSelected ? .white : Theme.accent)
                    } else if downloadStatus == .downloading {
                        ProgressView()
                            .controlSize(.mini)
                    } else if downloadStatus == .failed {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 9))
                            .foregroundStyle(isSelected ? .white : .red)
                    }

                    if !isAvailable {
                        Text("Unavailable")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.labelSecondary.opacity(0.8))
                    }
                }

                Text(chapter.translatedName)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Theme.labelSecondary)
            }

            Spacer(minLength: 10)

            Text(chapter.arabicName)
                .font(Theme.arabic(15))
                .foregroundStyle(isSelected ? Color.white.opacity(0.95) : (isAvailable ? Color.black.opacity(0.7) : Color.black.opacity(0.35)))
        }
        .lineLimit(1)
        .padding(.horizontal, 9)
        .frame(height: 46)
        .background(isSelected ? Theme.accent : .clear, in: RoundedRectangle(cornerRadius: 6))
        .contentShape(.rect)
    }
}
