import Shared
import SwiftUI

@main
struct TilawaMacApp: App {
    /// One shared-core instance for the whole app; features receive it, they
    /// never build their own.
    private let library = QuranLibrary()
    @StateObject private var router = AppRouter()
    @StateObject private var playback = PlaybackController()
    @StateObject private var downloads = DownloadController()

    var body: some Scene {
        WindowGroup {
            Group {
                switch router.route {
                case .reciters:
                    ReciterGridView(library: library)
                case .reciterDetail(let reciter):
                    ReciterDetailView(library: library, reciter: reciter)
                        .id("detail-\(reciter.id)")
                case .player(let reciter, let edition):
                    PlayerScreen(
                        library: library,
                        reciter: reciter,
                        edition: edition,
                        player: playback,
                        downloads: downloads
                    )
                        .id("player-\(reciter.id)-\(edition.id)")
                }
            }
            .environmentObject(router)
            .frame(minWidth: 1000, minHeight: 640)
            // Every surface in the design is a fixed light value; without this
            // the system's dark appearance turns `.primary` text white on them.
            .preferredColorScheme(.light)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .defaultSize(width: 1280, height: 800)
        .commands {
            CommandMenu("Playback") {
                Button(playback.isPlaying ? "Pause" : "Play", action: playback.toggle)
                    .keyboardShortcut(.space, modifiers: [])
                Button("Previous", action: playback.previous)
                    .keyboardShortcut(.leftArrow, modifiers: [.command])
                Button("Next", action: playback.next)
                    .keyboardShortcut(.rightArrow, modifiers: [.command])
            }
        }
    }
}
