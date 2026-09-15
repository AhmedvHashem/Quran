import Shared
import SwiftUI

/// Figma `7:2` — macOS — SwiftUI / AppKit: sidebar + mushaf reading pane + player bar.
struct PlayerScreen: View {
    @StateObject private var viewModel: PlayerViewModel

    init(
        library: QuranLibrary,
        reciter: Reciter,
        edition: RecitationEdition,
        player: PlaybackController,
        downloads: DownloadController
    ) {
        _viewModel = StateObject(
            wrappedValue: PlayerViewModel(
                library: library,
                reciter: reciter,
                edition: edition,
                player: player,
                downloads: downloads
            )
        )
    }

    var body: some View {
        HStack(spacing: 0) {
            ChapterSidebar(viewModel: viewModel)
                .frame(width: 258)
            VStack(spacing: 0) {
                ReadingPane(viewModel: viewModel)
                PlayerBar(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .task { await viewModel.start() }
    }
}
