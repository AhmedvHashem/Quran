import AppKit
import Shared
import SwiftUI

@main
struct TilawaMacApp: App {
    // Owned, not observed: an App that observes these re-runs its body on every
    // change, which rebuilt the whole window five times a second during playback.
    // Each view observes only what it shows.
    @State private var router = AppRouter()
    @State private var catalog: Catalog
    @State private var userLibrary: UserLibrary
    @State private var history: ListeningHistory
    @State private var nowPlaying: NowPlaying

    init() {
        // One shared-core instance for the whole app; features never build their own.
        let library = QuranLibrary()
        let userLibrary = UserLibrary(library: library)
        _catalog = State(initialValue: Catalog(library: library))
        let history = ListeningHistory(library: library)
        _userLibrary = State(initialValue: userLibrary)
        _history = State(initialValue: history)
        let nowPlaying = NowPlaying(library: library, player: PlaybackController(), history: history)
        _nowPlaying = State(initialValue: nowPlaying)

        // Space plays and pauses, except while typing. A bare-Space menu
        // shortcut would take the space out of every search and name field.
        _ = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 49,
                  event.modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty,
                  !(NSApp.keyWindow?.firstResponder is NSText),
                  NSApp.keyWindow?.attachedSheet == nil else { return event }
            MainActor.assumeIsolated { nowPlaying.togglePlay() }
            return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(catalog: catalog, userLibrary: userLibrary, nowPlaying: nowPlaying)
                .environmentObject(router)
                .environmentObject(catalog)
                .environmentObject(userLibrary)
                .environmentObject(history)
                .environmentObject(nowPlaying)
                // A constant minimum: one that grew with the queue open made the
                // split view squeeze the queue and overflow the toolbar while the
                // sidebar animated open.
                .frame(minWidth: 960, minHeight: 600)
        }
        .defaultSize(width: 1280, height: 800)

        Settings {
            SettingsView()
        }
        .commands {
            TilawaCommands(router: router, nowPlaying: nowPlaying, player: nowPlaying.player)
        }
    }
}

/// The menu bar's commands. They observe the router and player themselves, so
/// a change re-evaluates only the menus.
private struct TilawaCommands: Commands {
    @ObservedObject var router: AppRouter
    @ObservedObject var nowPlaying: NowPlaying
    @ObservedObject var player: PlaybackController

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Collection…") { router.newCollection() }
                .keyboardShortcut("n", modifiers: .command)
        }
        CommandGroup(after: .textEditing) {
            Button("Find…") { focusToolbarSearch() }
                .keyboardShortcut("f", modifiers: .command)
        }
        CommandMenu("Playback") {
            Button(player.isActive ? "Pause" : "Play", action: nowPlaying.togglePlay)
                .disabled(!nowPlaying.canPlay)
            Button("Previous", action: player.previous)
                .keyboardShortcut(.leftArrow, modifiers: [.command])
            Button("Next", action: player.next)
                .keyboardShortcut(.rightArrow, modifiers: [.command])
            Button(router.showsQueue ? "Hide Queue" : "Show Queue") { router.showsQueue.toggle() }
            Divider()
            Button("Go to Reciter") {
                if let item = nowPlaying.current { router.open(.reciter(item.reciter)) }
            }
            .disabled(nowPlaying.current == nil)
            Button("Go to Recording") {
                if let item = nowPlaying.current { router.openRecording(item.edition, chapterId: item.chapter.id) }
            }
            .disabled(nowPlaying.current == nil)
        }
    }
}

private struct RootView: View {
    // Held, not observed: the root rebuilds the navigation stack, so it
    // re-renders only for navigation.
    let catalog: Catalog
    let userLibrary: UserLibrary
    let nowPlaying: NowPlaying
    @EnvironmentObject private var router: AppRouter
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(AppearanceChoice.key) private var appearance = AppearanceChoice.system
    @AppStorage(AccentChoice.key) private var accent = AccentChoice.system

    var body: some View {
        shell
            .tint(accent.color)
            .environment(\.tilawaAccent, accent.color)
            .preferredColorScheme(appearance.colorScheme)
            .task { await catalog.load() }
            .alert(namingTitle, isPresented: isNaming) {
                TextField("Name", text: namingText)
                Button(router.naming?.collectionId == nil ? "Create" : "Rename", action: commitNaming)
                Button("Cancel", role: .cancel) { router.naming = nil }
            }
    }

    /// On macOS 26 the player bar floats over the window and content scrolls
    /// under its glass; below that there is no glass, so it sits under the content.
    @ViewBuilder
    private var shell: some View {
        if #available(macOS 26, *) {
            split
                .playerBarClearance()
                .background(FloatingPlayerBar(content: playerBar))
        } else {
            VStack(spacing: 0) {
                split
                playerBar
            }
        }
    }

    /// The bar carries its own environment: as the floating bar it is hosted
    /// outside this view tree.
    private var playerBar: some View {
        PlayerBar(nowPlaying: nowPlaying)
            .environmentObject(router)
            .environmentObject(catalog)
            .environmentObject(userLibrary)
            .environmentObject(nowPlaying)
            .tint(accent.color)
            .environment(\.tilawaAccent, accent.color)
            .environment(\.colorScheme, appearance.colorScheme ?? colorScheme)
    }

    @ViewBuilder
    private var split: some View {
        if #available(macOS 14, *) {
            navigationSplit
                .inspector(isPresented: $router.showsQueue) {
                    PlaylistQueueView()
                        .inspectorColumnWidth(min: 270, ideal: 310, max: 420)
                        .toolbar {
                            if #available(macOS 26, *) {
                                ToolbarSpacer(.flexible)
                            }
                            ToolbarItem(placement: .primaryAction) {
                                queueToggleButton
                            }
                        }
                }
        } else {
            HStack(spacing: 0) {
                navigationSplit
                if router.showsQueue {
                    Divider()
                    PlaylistQueueView()
                        .frame(width: 290)
                        .background(.regularMaterial)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    queueToggleButton
                }
            }
        }
    }

    private var queueToggleButton: some View {
        let title = router.showsQueue ? "Hide Queue" : "Show Queue"
        return Button { router.showsQueue.toggle() } label: {
            Label(title, systemImage: "sidebar.right")
        }
        .help(title)
    }

    private var navigationSplit: some View {
        NavigationSplitView {
            Sidebar()
                .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 300)
        } detail: {
            NavigationStack(path: router.path) {
                root(router.current)
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        Group {
                            switch route {
                            case .reciter(let reciter): ReciterDetailView(reciter: reciter)
                            case .edition(let edition): EditionView(edition: edition)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Resizing the inspector can leave earlier pages visible behind the destination.
                        .background(Theme.content)
                    }
            }
            .id(router.current)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.content)
        }
    }

    @ViewBuilder
    private func root(_ destination: AppRouter.Destination) -> some View {
        switch destination {
        case .home: HomeView()
        case .reciters: ReciterGridView()
        case .recentlyPlayed: RecentlyPlayedView()
        case .collection(let id): CollectionView(collectionId: id)
        }
    }

    private var namingTitle: String { router.naming?.collectionId == nil ? "New Collection" : "Rename Collection" }

    private var isNaming: Binding<Bool> {
        Binding(get: { router.naming != nil }, set: { if !$0 { router.naming = nil } })
    }

    private var namingText: Binding<String> {
        Binding(get: { router.naming?.name ?? "" }, set: { router.naming?.name = $0 })
    }

    private func commitNaming() {
        guard let naming = router.naming else { return }
        router.naming = nil
        if let id = naming.collectionId {
            userLibrary.rename(id, to: naming.name)
        } else if let created = userLibrary.create(named: naming.name) {
            // Adding from a row's menu keeps you where you are.
            if let recording = naming.adding {
                userLibrary.add(recording, to: created.id)
            } else {
                router.destination = .collection(created.id)
            }
        }
    }
}

/// Focuses the visible toolbar search field in the key window on ⌘F.
@MainActor
private func focusToolbarSearch() {
    guard let window = NSApp.keyWindow, let root = window.contentView?.superview else { return }
    func findSearchField(in view: NSView) -> NSSearchField? {
        if let field = view as? NSSearchField, !field.isHiddenOrHasHiddenAncestor { return field }
        for subview in view.subviews {
            if let field = findSearchField(in: subview) { return field }
        }
        return nil
    }
    if let field = findSearchField(in: root) { window.makeFirstResponder(field) }
}

/// Floats the player bar in its own AppKit view, added to the window above the
/// content view. The split view's columns are AppKit views stacked over anything
/// SwiftUI draws on top of them, so a bar floated by SwiftUI let clicks through
/// to the rows beneath and was covered by pushed pages. As a later sibling of
/// the content view, this one is on top for drawing and for clicks alike.
private struct FloatingPlayerBar<Content: View>: NSViewRepresentable {
    let content: Content

    final class Coordinator {
        var bar: NSHostingView<Content>?
        var content: Content

        init(content: Content) { self.content = content }
    }

    func makeCoordinator() -> Coordinator { Coordinator(content: content) }

    func makeNSView(context: Context) -> NSView {
        let anchor = WindowAnchor()
        anchor.onWindow = { [coordinator = context.coordinator] window in
            guard coordinator.bar == nil,
                  let page = window.contentView,
                  let frame = page.superview else { return }
            let bar = NSHostingView(rootView: coordinator.content)
            bar.translatesAutoresizingMaskIntoConstraints = false
            frame.addSubview(bar, positioned: .above, relativeTo: page)
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: page.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: page.trailingAnchor),
                bar.bottomAnchor.constraint(equalTo: page.bottomAnchor),
                bar.heightAnchor.constraint(equalToConstant: PlayerBar.height),
            ])
            coordinator.bar = bar
        }
        return anchor
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.content = content
        context.coordinator.bar?.rootView = content
    }

    static func dismantleNSView(_ view: NSView, coordinator: Coordinator) {
        coordinator.bar?.removeFromSuperview()
    }
}

/// Reports the window it lands in.
private final class WindowAnchor: NSView {
    var onWindow: ((NSWindow) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window { onWindow?(window) }
    }
}
