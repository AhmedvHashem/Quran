import AVFoundation
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
    /// The audio file the row's length is read from.
    var audio: URL? = nil
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
            SurahLength(url: audio).frame(width: 52, alignment: .trailing)

            RowMenu(label: "More actions for \(chapter.name)") { actions }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .environment(\.isRowHovered, isHovered)
        .background(rowBackground)
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

/// A surah's length, shown once its audio file has been read.
struct SurahLength: View {
    let url: URL?
    @State private var seconds: Double?

    var body: some View {
        Text(seconds?.clockTime ?? "")
            .font(.system(size: 11.5).monospacedDigit())
            .foregroundStyle(Theme.labelSecondary)
            .task(id: url) {
                guard let url else { return }
                seconds = await SurahLengths.shared.seconds(for: url)
            }
    }
}

/// Surah lengths read from the audio files, since the provider lists none.
/// AVFoundation's reading is the same length the player bar shows. It matched
/// a full frame count on constant-bitrate files; a file that changes bitrate
/// part-way can be off by a few seconds.
actor SurahLengths {
    static let shared = SurahLengths()
    // ponytail: kept for the session only; persist it if re-reading on launch shows up.
    private var known: [URL: Double] = [:]

    func seconds(for url: URL) async -> Double? {
        if let seconds = known[url] { return seconds }
        guard let time = try? await AVURLAsset(url: url).load(.duration), time.isNumeric else { return nil }
        known[url] = time.seconds
        return time.seconds
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

/// The heart that keeps a reciter in Favorites, in a glass circle: filled in
/// the accent while the reciter is a favorite.
struct ReciterFavoriteButton: View {
    let reciter: Reciter
    var controlSize: ControlSize = .large

    @EnvironmentObject private var userLibrary: UserLibrary
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        let isFavorite = userLibrary.isFavorite(reciter)
        let label = isFavorite ? "Remove from Favorites" : "Add to Favorites"
        let heart = Image(systemName: isFavorite ? "heart.fill" : "heart")
            .font(.system(size: controlSize == .large ? 13 : 11, weight: .semibold))
            .foregroundStyle(isFavorite ? accent : .primary)
        let button = Button {
            withAnimation(.snappy(duration: 0.25)) { userLibrary.toggleFavorite(reciter) }
        } label: {
            heart
        }
        .help(label)
        .accessibilityLabel(label)
        .accessibilityValue(reciter.name)
        if #available(macOS 26, *) {
            button
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(controlSize)
                .tint(nil)
        } else {
            let side: CGFloat = controlSize == .large ? 32 : 26
            button
                .buttonStyle(.plain)
                .frame(width: side, height: side)
                .background(Theme.card, in: Circle())
                .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 0.5))
                .contentShape(Circle())
        }
    }
}

/// A row's ⋯ menu. The dots take the accent while the pointer is over the
/// row, which says so through `isRowHovered`.
struct RowMenu<Actions: View>: View {
    let label: String
    var width: CGFloat = 28
    @ViewBuilder let actions: Actions

    @Environment(\.tilawaAccent) private var accent
    @Environment(\.isRowHovered) private var isRowHovered

    var body: some View {
        // AppKit draws a borderless menu's label and repaints it only under
        // the pointer, so the dots are drawn over an invisible label instead.
        Menu { actions } label: {
            Image(systemName: "ellipsis").opacity(0)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(width: width, height: 28)
        .overlay {
            Image(systemName: "ellipsis")
                .foregroundStyle(isRowHovered ? accent : Theme.labelSecondary)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .help("More actions")
        .accessibilityLabel(label)
    }
}

extension EnvironmentValues {
    /// Whether the pointer is over the row around this view.
    @Entry var isRowHovered = false
}

extension View {
    /// Tracks the pointer over a row or card for its ⋯ menu, when the row
    /// keeps no hover state of its own.
    func tracksRowHover() -> some View { modifier(RowHoverTracking()) }
}

private struct RowHoverTracking: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .environment(\.isRowHovered, isHovered)
            .onHover { isHovered = $0 }
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

/// Drag-to-reorder drawn in the window. A system drag shows the row as a
/// translucent image, so the row is lifted here instead: it follows the pointer
/// opaque, its slot shows where it will land, and rows make way as it passes.
/// The order is saved as it changes.
@MainActor
final class RowLift: ObservableObject {
    static let space = "reorderable rows"

    /// The lifted row's top edge in the list. Only the lifted copy watches it.
    @Published fileprivate(set) var top: CGFloat = 0
    /// The lifted row's slot when the drag began; nil when no row is lifted.
    @Published fileprivate(set) var frame: CGRect?
    fileprivate var grab: CGFloat = 0
    fileprivate var origin: CGFloat = 0
}

extension View {
    /// A row that can be lifted and dragged to a new place in `order`. The
    /// gesture keeps the closures it started with, so `order` and `move` must
    /// read the current order, not a copy taken when the list was drawn.
    func reorderable<ID: Hashable>(
        _ id: ID,
        order: @escaping () -> [ID],
        spacing: CGFloat = 0,
        isEnabled: Bool = true,
        dragging: Binding<ID?>,
        lift: RowLift,
        move: @escaping (_ id: ID, _ to: ID) -> Void
    ) -> some View {
        modifier(Reorderable(id: id, order: order, spacing: spacing, isEnabled: isEnabled,
                             dragging: dragging, lift: lift, move: move))
    }

    /// The list that holds reorderable rows, with the lifted row drawn over it.
    func liftedRow<Row: View>(_ lift: RowLift, @ViewBuilder row: @escaping () -> Row) -> some View {
        coordinateSpace(name: RowLift.space)
            .overlay(alignment: .topLeading) {
                Watching(lift) { lift in
                    if let frame = lift.frame {
                        // The row is selected while lifted: its own accent fill, over an opaque base.
                        row()
                            .frame(width: frame.width, height: frame.height)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                            .background(Theme.card, in: RoundedRectangle(cornerRadius: 9))
                            .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Theme.hairline, lineWidth: 0.5))
                            .shadow(color: .black.opacity(0.2), radius: 12, y: 5)
                            .offset(x: frame.minX, y: lift.top)
                            .allowsHitTesting(false)
                    }
                }
            }
    }
}

private struct Reorderable<ID: Hashable>: ViewModifier {
    let id: ID
    let order: () -> [ID]
    let spacing: CGFloat
    let isEnabled: Bool
    @Binding var dragging: ID?
    let lift: RowLift
    let move: (ID, ID) -> Void

    @Environment(\.tilawaAccent) private var accent
    @State private var slot: CGRect = .zero
    /// Resets when the drag ends or is cancelled; `onEnded` misses a cancel.
    @GestureState private var isDragging = false

    func body(content: Content) -> some View {
        let isLifted = dragging == id
        content
            .opacity(isLifted ? 0 : 1)
            .background {
                if isLifted {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(accent.opacity(0.10))
                        .overlay(RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(accent.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])))
                        .padding(2)
                }
            }
            .background(GeometryReader { proxy in
                let frame = proxy.frame(in: .named(RowLift.space))
                Color.clear
                    .onAppear { slot = frame }
                    .onChange(of: frame) { slot = $0 }
            })
            .zIndex(isLifted ? 1 : 0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .named(RowLift.space))
                    .updating($isDragging) { _, state, _ in state = true }
                    .onChanged(drag),
                including: isEnabled ? .all : .subviews
            )
            .onChange(of: isDragging) { if !$0 { drop() } }
    }

    private func drag(_ value: DragGesture.Value) {
        let order = order()
        guard let index = order.firstIndex(of: id) else { return }
        // ponytail: one row height for the whole list; measure each row if rows start to differ.
        if dragging != id {
            lift.frame = slot
            lift.grab = value.startLocation.y - slot.minY
            lift.origin = slot.minY - CGFloat(index) * (slot.height + spacing)
            dragging = id
        }
        lift.top = value.location.y - lift.grab
        let pitch = slot.height + spacing
        let target = min(max(Int(((lift.top - lift.origin) / pitch).rounded()), 0), order.count - 1)
        if target != index {
            withAnimation(.snappy(duration: 0.25)) { move(id, order[target]) }
        }
    }

    /// The lifted row settles into its slot, then takes its place.
    private func drop() {
        guard dragging == id else { return }
        withAnimation(.snappy(duration: 0.2)) { lift.top = slot.minY }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard dragging == id else { return }
            dragging = nil
            lift.frame = nil
        }
    }
}

extension View {
    /// The hairline under a row in a list card. The list draws it, not the
    /// row, so a dragged row leaves it behind; the last row has none.
    func rowDivider(_ isShown: Bool) -> some View {
        overlay(alignment: .bottom) {
            if isShown { Theme.hairline.frame(height: 0.5) }
        }
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
