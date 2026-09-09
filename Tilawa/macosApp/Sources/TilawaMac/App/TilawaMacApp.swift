import Shared
import SwiftUI

@main
struct TilawaMacApp: App {
    /// One shared-core instance for the whole app; features receive it, they
    /// never build their own.
    private let library = QuranLibrary()
    @StateObject private var router = AppRouter()

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
                    PlayerScreen(library: library, reciter: reciter, edition: edition)
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
    }
}
