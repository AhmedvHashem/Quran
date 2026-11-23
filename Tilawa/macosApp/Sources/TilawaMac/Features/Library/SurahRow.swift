import Shared
import SwiftUI

/// One surah in a list card: edition, collection and Favorites lists share it.
/// A click selects the row and a double-click plays it; the play button, ⋯
/// and the context menu act on it directly.
struct SurahRow<Detail: View, Actions: View>: View {
    let recording: SurahRecording
    /// A user collection's grip, which says the rows can be dragged.
    var showsDragHandle = false
    /// Outside its own edition, the surah name links to that recording.
    var linksToRecording = false
    let chapter: Chapter
    let isCurrent: Bool
    var isSelected = false
    var isAvailable = true
    let select: () -> Void
    let play: () -> Void
    @ViewBuilder let detail: Detail
    @ViewBuilder let actions: Actions

    @EnvironmentObject private var nowPlaying: NowPlaying
    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var router: AppRouter
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Grip, favorite, play, then the surah.
            if showsDragHandle { DragHandle() }
            FavoriteButton(recording: recording, name: chapter.name)
            RowPlayButton(player: nowPlaying.player, isCurrent: isCurrent, name: chapter.name) {
                isCurrent ? nowPlaying.togglePlay() : play()
            }
            .disabled(!isAvailable)
            NumberTile(number: chapter.id)
            HStack(spacing: 8) {
                if linksToRecording, let edition = catalog.edition(recording.editionId) {
                    NameLink(title: chapter.name) { router.open(.edition(edition)) }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isCurrent ? Theme.accent : .primary)
                } else {
                    Text(chapter.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isCurrent ? Theme.accent : .primary)
                }
                Text(chapter.arabicName)
                    .arabic(14)
                    .foregroundStyle(Theme.labelSecondary)
            }
            .lineLimit(1)
            .frame(width: 250, alignment: .leading)
            detail.frame(maxWidth: .infinity, alignment: .leading)
            if isCurrent { PlayingBars() }

            Menu { actions } label: {
                Image(systemName: "ellipsis").foregroundStyle(Theme.labelSecondary)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .tint(Theme.labelSecondary)
            .frame(width: 28, height: 28)
            .help("More actions")
            .accessibilityLabel("More actions for \(chapter.name)")
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(rowBackground)
        .overlay(alignment: .bottom) { Theme.hairline.frame(height: 0.5) }
        .opacity(isAvailable ? 1 : 0.5)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { if isAvailable { play() } }
        .simultaneousGesture(TapGesture().onEnded(select))
        .onHover { isHovered = $0 }
        .contextMenu { actions }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(chapter.name), \(chapter.arabicName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAction(named: "Play") { if isAvailable { play() } }
    }

    private var rowBackground: Color {
        if isSelected { return Theme.accent.opacity(0.2) }
        if isCurrent { return Theme.accentWash }
        return isHovered ? Theme.segment : .clear
    }
}

/// The play/pause button where a surah list used to show its number.
struct RowPlayButton: View {
    @ObservedObject var player: PlaybackController
    let isCurrent: Bool
    let name: String
    let action: () -> Void

    var body: some View {
        let isPlaying = isCurrent && player.isPlaying
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 10))
                .foregroundStyle(isCurrent ? Theme.accent : Theme.labelSecondary)
                .frame(width: 26, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isPlaying ? "Pause" : "Play")
        .accessibilityLabel(isPlaying ? "Pause \(name)" : "Play \(name)")
    }
}

/// A name that opens its page when clicked and underlines on hover, like the
/// artist and album names in Music.
struct NameLink: View {
    let title: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(title).underline(isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .linkPointer()
        .accessibilityAddTraits(.isLink)
    }
}

/// "Reciter · Style", each linking to its page: the reciter, and the recording.
struct RecordingByline: View {
    let recording: SurahRecording
    var showsRiwayah = false

    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        HStack(spacing: 0) {
            if let reciter = catalog.reciter(recording.reciterId) {
                NameLink(title: reciter.name) { router.open(.reciter(reciter)) }
            } else {
                Text(recording.reciterName)
            }
            Text(" · ")
            if let edition = catalog.edition(recording.editionId) {
                NameLink(title: recording.style) { router.open(.edition(edition)) }
            } else {
                Text(recording.style)
            }
            if showsRiwayah { Text(" · \(recording.riwayahShortName)") }
        }
        .lineLimit(1)
    }
}

extension View {
    /// The pointing-hand cursor over a link, where macOS offers it.
    @ViewBuilder
    func linkPointer() -> some View {
        if #available(macOS 15, *) { pointerStyle(.link) } else { self }
    }
}

/// The heart at the start of every surah row: filled when the recording is a
/// favorite, and a click adds or removes it.
struct FavoriteButton: View {
    let recording: SurahRecording
    let name: String

    @EnvironmentObject private var userLibrary: UserLibrary

    var body: some View {
        let isFavorite = userLibrary.isFavorite(recording)
        Button {
            withAnimation(.snappy(duration: 0.25)) { userLibrary.toggleFavorite(recording) }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 11))
                .foregroundStyle(isFavorite ? Theme.accent : Theme.labelTertiary)
                .frame(width: 14, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isFavorite ? "Remove from Favorites" : "Add to Favorites")
        .accessibilityLabel(isFavorite ? "Remove \(name) from Favorites" : "Add \(name) to Favorites")
    }
}

/// The grip that says a row can be dragged to reorder it.
struct DragHandle: View {
    var body: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 10))
            .foregroundStyle(Theme.labelTertiary)
            .frame(width: 14)
            .accessibilityHidden(true)
    }
}

/// Live reordering: rows make way as a dragged row passes over them, and the
/// order is saved as it changes.
struct RowReorder<ID: Equatable>: DropDelegate {
    let target: ID
    @Binding var dragging: ID?
    let move: (_ from: ID, _ to: ID) -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != target else { return }
        withAnimation(.snappy(duration: 0.25)) { move(dragging, target) }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }
}

/// The column titles above a list card.
struct ColumnHeader<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 12) { content }
            .font(.system(size: 10.5, weight: .semibold))
            .textCase(.uppercase)
            .foregroundStyle(Theme.labelSecondary)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .overlay(alignment: .bottom) { Theme.hairline.frame(height: 0.5) }
            .accessibilityHidden(true)
    }
}

/// What can be done with one recording, wherever it is listed.
struct RecordingActions: View {
    let recording: SurahRecording
    /// The collection this row belongs to, which offers removal from it.
    var collectionId: String? = nil
    /// Off on the recording's own page, where it would lead back to itself.
    var showsGoToRecording = true
    let play: (() -> Void)?

    @EnvironmentObject private var userLibrary: UserLibrary
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var catalog: Catalog

    var body: some View {
        Button("Play") { play?() }.disabled(play == nil)
        Divider()
        if let reciter = catalog.reciter(recording.reciterId) {
            Button("Go to Reciter") { router.open(.reciter(reciter)) }
        }
        if showsGoToRecording, let edition = catalog.edition(recording.editionId) {
            Button("Go to Recording") { router.open(.edition(edition)) }
        }
        Divider()
        Button(userLibrary.isFavorite(recording) ? "Remove from Favorites" : "Add to Favorites") {
            userLibrary.toggleFavorite(recording)
        }
        Menu("Add to Collection") {
            ForEach(userLibrary.userCollections, id: \.id) { collection in
                Button(collection.name) { userLibrary.add(recording, to: collection.id) }
                    .disabled(userLibrary.contains(recording, in: collection.id))
            }
            if !userLibrary.userCollections.isEmpty { Divider() }
            Button("New Collection…") { router.newCollection(adding: recording) }
        }
        if let collectionId, collectionId != userLibrary.favorites.id {
            Divider()
            Button("Remove from Collection") { userLibrary.remove(recording, from: collectionId) }
        }
    }
}
