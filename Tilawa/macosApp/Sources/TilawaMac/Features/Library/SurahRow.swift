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
    @Environment(\.tilawaAccent) private var accent
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Grip, favorite, play, then the surah.
            if showsDragHandle { DragHandle() }
            FavoriteButton(recording: recording, name: chapter.name)
            RowPlayButton(player: nowPlaying.player, isCurrent: isCurrent, name: chapter.name) {
                select()
                isCurrent ? nowPlaying.togglePlay() : play()
            }
            .disabled(!isAvailable)
            SurahTitle(title: chapter.name, arabic: chapter.arabicName, recording: linksToRecording ? recording : nil)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isCurrent ? accent : .primary)
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
        .surahRowClicks(select: select, play: isAvailable ? play : nil)
        .onHover { isHovered = $0 }
        .contextMenu { actions }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(chapter.name), \(chapter.arabicName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAction(named: "Play") {
            guard isAvailable else { return }
            select()
            play()
        }
    }

    private var rowBackground: Color {
        if isSelected { return accent.opacity(0.2) }
        if isCurrent { return accent.opacity(0.10) }
        return isHovered ? Theme.segment : .clear
    }
}

/// The play/pause button where a surah list used to show its number. Only the
/// current row watches the player, whose position ticks five times a second.
struct RowPlayButton: View {
    let player: PlaybackController
    @Environment(\.tilawaAccent) private var accent
    let isCurrent: Bool
    let name: String
    let action: () -> Void

    var body: some View {
        if isCurrent {
            Watching(player) { button(canPause: $0.isActive) }
        } else {
            button(canPause: false)
        }
    }

    private func button(canPause: Bool) -> some View {
        Button(action: action) {
            Image(systemName: canPause ? "pause.fill" : "play.fill")
                .font(.system(size: 10))
                .foregroundStyle(isCurrent ? accent : Theme.labelSecondary)
                .frame(width: 26, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(canPause ? "Pause" : "Play")
        .accessibilityLabel(canPause ? "Pause \(name)" : "Play \(name)")
    }
}

/// Re-renders its content as `object` changes, keeping those updates out of
/// the views around it.
struct Watching<Object: ObservableObject, Content: View>: View {
    @ObservedObject var object: Object
    let content: (Object) -> Content

    init(_ object: Object, @ViewBuilder content: @escaping (Object) -> Content) {
        self.object = object
        self.content = content
    }

    var body: some View { content(object) }
}

/// A name that opens its page when clicked and underlines on hover, like the
/// artist and album names in Music.
struct NameLink<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: (Bool) -> Label

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            label(isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .linkPointer()
        .accessibilityAddTraits(.isLink)
    }
}

extension NameLink where Label == Text {
    init(title: String, action: @escaping () -> Void) {
        self.init(action: action) { Text(title).underline($0) }
    }
}

struct SurahTitle: View {
    let title: String
    var arabic: String? = nil
    var recording: SurahRecording? = nil
    var arabicSize: CGFloat = 14

    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            if let recording, let edition = catalog.edition(recording.editionId) {
                NameLink(action: { router.openRecording(edition, chapterId: recording.chapterId) }) { label(underlined: $0) }
                    .accessibilityLabel(title)
                    .accessibilityHint("Show this surah in its recording")
            } else {
                label(underlined: false)
            }
        }
        .lineLimit(1)
    }

    /// One underline under both names. Each font draws its own at a different
    /// depth (Amiri's sits lower), so the line is drawn here, 2pt under the
    /// English baseline, across the English and Arabic names alike.
    private func label(underlined: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
            if let arabic {
                Text(arabic).arabic(arabicSize).foregroundStyle(Theme.labelSecondary)
            }
        }
        .overlay(alignment: Alignment(horizontal: .leading, vertical: .firstTextBaseline)) {
            if underlined {
                Rectangle()
                    .fill(.foreground)
                    .frame(height: 1)
                    .alignmentGuide(.firstTextBaseline) { $0[.top] - 2 }
            }
        }
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
                NameLink(title: edition.style) { router.openRecording(edition) }
                    .layoutPriority(1)
            } else {
                Text(recording.style)
            }
            if showsRiwayah { Text(" · \(recording.riwayahShortName)") }
        }
        .lineLimit(1)
    }
}

extension View {
    func surahRowClicks(select: @escaping () -> Void, play: (() -> Void)?) -> some View {
        contentShape(Rectangle())
            .onTapGesture(count: 2) {
                select()
                play?()
            }
            .simultaneousGesture(TapGesture().onEnded(select))
    }

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
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        let isFavorite = userLibrary.isFavorite(recording)
        Button {
            withAnimation(.snappy(duration: 0.25)) { userLibrary.toggleFavorite(recording) }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 11))
                .foregroundStyle(isFavorite ? accent : Theme.labelTertiary)
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
    let play: (() -> Void)?
    var showsQueueInsertion = true

    @EnvironmentObject private var userLibrary: UserLibrary
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var nowPlaying: NowPlaying

    var body: some View {
        let reciter = catalog.reciter(recording.reciterId)
        let edition = catalog.edition(recording.editionId)
        Button("Play") { play?() }.disabled(play == nil)
        if showsQueueInsertion {
            let item = catalog.item(for: recording)
            Button("Play Next") {
                if let item { nowPlaying.enqueue(item, next: true) }
            }
            .disabled(item == nil)
            Button("Add to Queue") {
                if let item { nowPlaying.enqueue(item) }
            }
            .disabled(item == nil)
        }
        Divider()
        Button("Go to Reciter") {
            if let reciter { router.open(.reciter(reciter)) }
        }
        .disabled(reciter == nil)
        Button("Go to Recording") {
            if let edition { router.openRecording(edition, chapterId: recording.chapterId) }
        }
        .disabled(edition == nil)
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
