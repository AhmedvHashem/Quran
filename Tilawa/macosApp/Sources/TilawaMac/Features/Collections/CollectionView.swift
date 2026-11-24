import Shared
import SwiftUI

/// Favorites and user collections. Favorites lists newest first; a user
/// collection keeps its manual order, which dragging a row changes.
struct CollectionView: View {
    let collectionId: String

    @EnvironmentObject private var userLibrary: UserLibrary
    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var nowPlaying: NowPlaying
    @EnvironmentObject private var router: AppRouter
    @Environment(\.tilawaAccent) private var accent
    @State private var query = ""
    @State private var isConfirmingDelete = false
    @State private var selection: SurahRecording?
    /// The row being dragged, while a reorder is in progress.
    @State private var dragging: SurahRecording?

    var body: some View {
        if let collection = userLibrary.collection(collectionId) {
            content(collection)
                .navigationTitle(collection.name)
                .toolbar {
                    // Sits just left of the search field, like the design's toolbar actions.
                    if !collection.isFavorites {
                        ToolbarItem(placement: .primaryAction) {
                            Menu {
                                Button("Rename…") { router.rename(collection) }
                                Button("Delete…") { isConfirmingDelete = true }
                            } label: {
                                Label("Collection actions", systemImage: "ellipsis")
                            }
                            .menuIndicator(.hidden)
                            .help("Rename or delete this collection")
                        }
                    }
                    ToolbarSearchItem(
                        text: $query,
                        prompt: collection.isFavorites ? "Search favorites" : "Filter in collection",
                        separated: !collection.isFavorites
                    )
                }
                .confirmationDialog("Delete “\(collection.name)”?", isPresented: $isConfirmingDelete) {
                    Button("Delete Collection", role: .destructive) {
                        router.destination = .home
                        userLibrary.delete(collection.id)
                    }
                } message: {
                    Text("The collection is removed. The recitations in it stay in the catalog.")
                }
        } else {
            StateMessage(symbol: "questionmark.folder", title: "This collection no longer exists")
        }
    }

    private func content(_ collection: RecitationCollection) -> some View {
        // Favorites reads newest first; a user collection keeps its own order.
        let items = collection.isFavorites ? Array(collection.items.reversed()) : collection.items
        let playable = items.compactMap { catalog.item(for: $0.recording) }

        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero(collection, playable: playable)
                if items.isEmpty {
                    StateMessage(
                        symbol: collection.isFavorites ? "heart" : "music.note.list",
                        title: collection.isFavorites ? "No favorites yet" : "This collection is empty",
                        message: "Use ⋯ on any surah and choose \(collection.isFavorites ? "Add to Favorites" : "Add to Collection")."
                    )
                    .frame(height: 240)
                } else {
                    if collection.isFavorites {
                        SectionHeading(title: "Recitations", detail: "\(items.count)", size: 13)
                            .padding(.bottom, -14)
                    }
                    list(collection, items: items, playable: playable)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 26)
            .padding(.bottom, 32)
        }
    }

    private func hero(_ collection: RecitationCollection, playable: [QueueItem]) -> some View {
        HStack(alignment: .bottom, spacing: 20) {
            if collection.isFavorites {
                OrnamentTile(surface: accent.opacity(0.10), ink: accent) {
                    Image(systemName: "heart.fill").font(.system(size: 44)).foregroundStyle(accent)
                }
            } else {
                OrnamentTile {
                    ArabicGlyph(text: "ﷲ", size: 44).foregroundStyle(Theme.ornamentBorder)
                }
            }

            VStack(alignment: .leading, spacing: 9) {
                Text(collection.isFavorites ? "Pinned collection" : "Collection")
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .kerning(0.6)
                    .foregroundStyle(Theme.labelSecondary)
                Text(collection.name)
                    .font(.system(size: 30, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Text(metadata(collection))
                    .font(.system(size: 12.5))
                    .foregroundStyle(Theme.labelSecondary)
                HStack(spacing: 9) {
                    PillButton(title: "Play All", symbol: "play.fill", isPrimary: true) { nowPlaying.play(playable) }
                        .disabled(playable.isEmpty)
                    PillButton(title: "Shuffle", symbol: "shuffle") { nowPlaying.shuffle(playable) }
                        .disabled(playable.isEmpty)
                }
                .padding(.top, 5)
            }
            .padding(.bottom, 4)
        }
    }

    private func metadata(_ collection: RecitationCollection) -> String {
        let count = collection.items.count
        let reciters = Set(collection.items.map(\.recording.reciterId)).count
        var parts = [
            count == 1 ? "1 recitation" : "\(count) recitations",
            reciters == 1 ? "1 reciter" : "\(reciters) reciters",
        ]
        if !collection.isFavorites, collection.updatedAtMs > 0 {
            parts.append("updated \(Date(milliseconds: collection.updatedAtMs).formatted(.relative(presentation: .named)))")
        }
        return parts.joined(separator: " · ")
    }

    private func list(_ collection: RecitationCollection, items: [CollectionItem], playable: [QueueItem]) -> some View {
        let isManual = !collection.isFavorites
        return VStack(spacing: 0) {
            ColumnHeader {
                if isManual && query.isEmpty { Color.clear.frame(width: 14, height: 1) }
                Color.clear.frame(width: 14, height: 1)
                Color.clear.frame(width: 26, height: 1)
                Text("Surah").frame(width: 250, alignment: .leading)
                Text("Reciter").frame(maxWidth: .infinity, alignment: .leading)
                if !isManual { Text("Added").frame(width: 90, alignment: .trailing) }
                Color.clear.frame(width: 28, height: 1)
            }
            ForEach(Array(items.enumerated()), id: \.element.recording) { offset, entry in
                if matches(entry.recording), let chapter = catalog.chapter(entry.recording.chapterId) {
                    let item = catalog.item(for: entry.recording)
                    let play = { () -> Void in
                        guard let item, let start = playable.firstIndex(of: item) else { return }
                        nowPlaying.play(playable, startingAt: start)
                    }
                    SurahRow(
                        recording: entry.recording,
                        showsDragHandle: isManual && query.isEmpty,
                        linksToRecording: true,
                        chapter: chapter,
                        isCurrent: nowPlaying.isCurrent(entry.recording),
                        isSelected: selection == entry.recording,
                        isAvailable: item != nil,
                        select: { selection = entry.recording },
                        play: play
                    ) {
                        HStack {
                            HStack(spacing: 0) {
                                if item == nil { Text("Unavailable · ") }
                                RecordingByline(recording: entry.recording)
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.labelSecondary)
                            .lineLimit(1)
                            Spacer(minLength: 8)
                            if !isManual {
                                Text(addedLabel(entry.addedAtMs))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.labelSecondary)
                                    .frame(width: 90, alignment: .trailing)
                            }
                        }
                    } actions: {
                        RecordingActions(recording: entry.recording, collectionId: collection.id, play: item == nil ? nil : play)
                        if isManual {
                            // The keyboard and VoiceOver path for reordering; dragging is the pointer one.
                            Divider()
                            Button("Move Up") { userLibrary.moveItem(in: collection.id, from: offset, to: offset - 1) }
                                .disabled(offset == 0)
                            Button("Move Down") { userLibrary.moveItem(in: collection.id, from: offset, to: offset + 1) }
                                .disabled(offset == items.count - 1)
                        }
                    }
                    .reorderable(isManual && query.isEmpty, item: entry.recording, dragging: $dragging) { from, to in
                        let order = items.map(\.recording)
                        guard let source = order.firstIndex(of: from), let destination = order.firstIndex(of: to) else { return }
                        userLibrary.moveItem(in: collection.id, from: source, to: destination)
                    }
                }
            }
        }
        .card()
    }

    private func addedLabel(_ milliseconds: Int64) -> String {
        let date = Date(milliseconds: milliseconds)
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if let days = calendar.dateComponents([.day], from: date, to: .now).day, days < 7 { return "\(days) days ago" }
        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    private func matches(_ recording: SurahRecording) -> Bool {
        guard let chapter = catalog.chapter(recording.chapterId) else { return query.isEmpty }
        return chapter.name.matches(query) || chapter.arabicName.matches(query) ||
            chapter.translatedName.matches(query) || catalog.reciterName(of: recording).matches(query)
    }
}

private extension View {
    /// Drag a row anywhere to reorder; rows move out of its way as it passes.
    @ViewBuilder
    func reorderable(
        _ isEnabled: Bool,
        item: SurahRecording,
        dragging: Binding<SurahRecording?>,
        move: @escaping (SurahRecording, SurahRecording) -> Void
    ) -> some View {
        if isEnabled {
            onDrag {
                dragging.wrappedValue = item
                return NSItemProvider(object: "\(item.editionId):\(item.chapterId)" as NSString)
            }
            .onDrop(of: [.text], delegate: RowReorder(target: item, dragging: dragging, move: move))
        } else {
            self
        }
    }
}
