import SwiftUI
import UniformTypeIdentifiers

struct PlaylistQueueView: View {
    @EnvironmentObject private var nowPlaying: NowPlaying
    @Environment(\.tilawaAccent) private var accent
    @State private var dragging: QueueEntry.ID?
    @State private var selection: QueueEntry.ID?

    private static let rowType = UTType(mimeType: "application/vnd.tilawa.queue-row", conformingTo: .data)!

    var body: some View {
        let entries = Array(nowPlaying.upcoming)
        VStack(alignment: .leading, spacing: 0) {
            Text("Now Playing")
                .font(.title2.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    if let current = nowPlaying.current {
                        track(current, isCurrent: true, play: nowPlaying.togglePlay) { EmptyView() }
                            .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 9))
                            .padding(.bottom, 8)
                    } else {
                        Text("Not Playing")
                            .font(.callout)
                            .foregroundStyle(Theme.labelSecondary)
                            .padding(.leading, 4)
                            .padding(.bottom, 8)
                    }

                    HStack {
                        sectionTitle("Up Next")
                        Spacer()
                        if !entries.isEmpty {
                            Button("Clear", action: nowPlaying.clearUpcoming)
                                .buttonStyle(.plain)
                                .foregroundStyle(accent)
                                .help("Clear upcoming surahs")
                                .accessibilityLabel("Clear Upcoming Queue")
                        }
                    }
                    .padding(.trailing, 4)

                    if entries.isEmpty {
                        Text(nowPlaying.current == nil ? "Play a surah or add one from its menu." : "No upcoming surahs")
                            .font(.callout)
                            .foregroundStyle(Theme.labelSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 4)
                            .padding(.top, 6)
                    }

                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        queueRow(entry, previous: index > 0 ? entries[index - 1].id : nil,
                                 next: index + 1 < entries.count ? entries[index + 1].id : nil)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Theme.labelSecondary)
            .padding(.leading, 4)
            .accessibilityAddTraits(.isHeader)
    }

    private func queueRow(_ entry: QueueEntry, previous: QueueEntry.ID?, next: QueueEntry.ID?) -> some View {
        let play = { nowPlaying.playQueued(entry.id) }
        return track(entry.item, isCurrent: false, play: play) {
            Menu {
                actions(for: entry, previous: previous, next: next, play: play)
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(Theme.labelSecondary)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .tint(Theme.labelSecondary)
            .frame(width: 26, height: 28)
            .accessibilityLabel("Queue actions for \(entry.item.chapter.name)")
        }
        .background(selection == entry.id ? accent.opacity(0.20) : Theme.segment.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: 9))
        .surahRowClicks(select: { selection = entry.id }, play: play)
        .contextMenu { actions(for: entry, previous: previous, next: next, play: play) }
        .onDrag {
            dragging = entry.id
            selection = entry.id
            let provider = NSItemProvider()
            provider.registerDataRepresentation(forTypeIdentifier: Self.rowType.identifier, visibility: .ownProcess) { complete in
                complete(Data([0]), nil)
                return nil
            }
            return provider
        }
        .onDrop(of: [Self.rowType], delegate: RowReorder(target: entry.id, dragging: $dragging, move: nowPlaying.moveQueued))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(entry.item.chapter.name), \(entry.item.chapter.arabicName)")
        .accessibilityAddTraits(selection == entry.id ? .isSelected : [])
    }

    private func track<Trailing: View>(
        _ item: QueueItem, isCurrent: Bool, play: @escaping () -> Void, @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 5) {
            if !isCurrent { DragHandle() }
            RowPlayButton(player: nowPlaying.player, isCurrent: isCurrent, name: item.chapter.name, action: play)
            VStack(alignment: .leading, spacing: 3) {
                SurahTitle(title: item.chapter.name, arabic: item.chapter.arabicName, recording: item.recording)
                    .font(.system(size: 13, weight: .semibold))
                RecordingByline(recording: item.recording)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.labelSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .padding(.horizontal, 7)
        .frame(minHeight: 49)
    }

    private func actions(for entry: QueueEntry, previous: QueueEntry.ID?, next: QueueEntry.ID?,
                         play: @escaping () -> Void) -> some View {
        Group {
            RecordingActions(recording: entry.item.recording, play: play, showsQueueInsertion: false)
            Divider()
            Button("Move Up") {
                if let previous { nowPlaying.moveQueued(entry.id, to: previous) }
            }
            .disabled(previous == nil)
            Button("Move Down") {
                if let next { nowPlaying.moveQueued(entry.id, to: next) }
            }
            .disabled(next == nil)
            Button("Remove from Queue") { nowPlaying.removeQueued(entry.id) }
        }
    }
}
