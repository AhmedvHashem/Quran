import AppKit
import Shared
import SwiftUI

/// Library destinations and collections, with live counts.
struct Sidebar: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var userLibrary: UserLibrary
    @Environment(\.tilawaAccent) private var accent
    @State private var deleting: RecitationCollection?

    var body: some View {
        let favorites = AppRouter.Destination.collection(userLibrary.favorites.id)
        List(selection: $router.destination) {
            Section {
                row("Home", "house", .home)
                row("Reciters", "person", .reciters)
                row("Recently Played", "clock", .recentlyPlayed)
            }

            Section {
                row("Favorites", "star.fill", favorites, count: userLibrary.favorites.items.count)

                if !userLibrary.userCollections.isEmpty {
                    // Favorites is pinned above the collections you order yourself.
                    Divider()
                }

                ForEach(userLibrary.userCollections, id: \.id) { collection in
                    row(collection.name, "line.3.horizontal", .collection(collection.id), count: collection.items.count) {
                        Button("Rename…") { router.rename(collection) }
                        Button("Delete…", role: .destructive) { deleting = collection }
                    }
                }
                .onMove { source, destination in
                    guard let from = source.first else { return }
                    let id = userLibrary.userCollections[userLibrary.userCollections.startIndex + from].id
                    userLibrary.move(id, toIndex: destination > from ? destination - 1 : destination)
                }
            } header: {
                HStack {
                    Text("Collections")
                    Spacer()
                    Button { router.newCollection() } label: {
                        Image(systemName: "plus").font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    // Lines the + up with the count column below it.
                    .padding(.trailing, 10)
                    .help("New collection")
                    .accessibilityLabel("New collection")
                }
            }
        }
        .listStyle(.sidebar)
        .confirmationDialog(
            "Delete “\(deleting?.name ?? "")”?",
            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
            presenting: deleting
        ) { collection in
            Button("Delete Collection", role: .destructive) {
                if router.destination == .collection(collection.id) { router.destination = .home }
                userLibrary.delete(collection.id)
            }
        } message: { _ in
            Text("The collection is removed. The recitations in it stay in the catalog.")
        }
    }

    /// The tag must be the row's last modifier: a badge or menu applied after
    /// it hides the tag from the list's selection, and the row stops opening.
    private func row(
        _ title: String,
        _ symbol: String,
        _ destination: AppRouter.Destination,
        count: Int? = nil,
        @ViewBuilder menu: () -> some View = { EmptyView() }
    ) -> some View {
        let isSelected = router.destination == destination
        return SidebarLabel(title: title, symbol: symbol, isSelected: isSelected)
            .badge(count ?? 0)
            .contextMenu { menu() }
            .listRowBackground(SidebarSelection(isSelected: isSelected))
            .tag(destination)
    }
}

/// The selected row's fill in the chosen accent. macOS draws its own row
/// selection only in the system accent, so that drawing is switched off
/// (`RowHighlightOff`) and this takes its place: accent while the window is
/// active, a quiet gray when it is not, like the system's own.
private struct SidebarSelection: View {
    let isSelected: Bool

    @Environment(\.tilawaAccent) private var accent
    @Environment(\.controlActiveState) private var activeState

    var body: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8)
                .fill(activeState == .inactive ? Theme.segment : accent)
                .padding(.horizontal, 10)
        }
    }
}

/// A sidebar row whose icon takes the chosen accent, and whose text and icon
/// turn white on the accent fill of a selected row in the active window.
private struct SidebarLabel: View {
    let title: String
    let symbol: String
    let isSelected: Bool

    @Environment(\.tilawaAccent) private var accent
    @Environment(\.controlActiveState) private var activeState

    var body: some View {
        let onFill = isSelected && activeState != .inactive
        Label {
            Text(title).foregroundStyle(onFill ? Color.white : .primary)
        } icon: {
            Image(systemName: symbol).foregroundStyle(onFill ? .white : isSelected ? .primary : accent)
        }
        .background(RowHighlightOff())
    }
}

/// Switches off the row's own selection drawing, which macOS paints in the
/// system accent whatever the app chooses; `SidebarSelection` draws it instead.
private struct RowHighlightOff: NSViewRepresentable {
    func makeNSView(context: Context) -> Probe { Probe() }

    func updateNSView(_ probe: Probe, context: Context) { probe.apply() }

    final class Probe: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }

        func apply() {
            var view = superview
            while let current = view, !(current is NSTableRowView) { view = current.superview }
            (view as? NSTableRowView)?.selectionHighlightStyle = .none
        }
    }
}
