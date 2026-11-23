import Shared
import SwiftUI

/// One flat history, newest first and grouped by day, with a resume point.
struct RecentlyPlayedView: View {
    @EnvironmentObject private var userLibrary: UserLibrary
    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var nowPlaying: NowPlaying
    @State private var query = ""
    @State private var isConfirmingClear = false
    @State private var selection: SurahRecording?

    var body: some View {
        let sessions = userLibrary.sessions.filter(matches)
        Group {
            if userLibrary.sessions.isEmpty {
                StateMessage(
                    symbol: "clock",
                    title: "Nothing played yet",
                    message: "Surahs you listen to appear here, newest first, so you can pick up where you stopped."
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        if query.isEmpty, let session = userLibrary.sessions.first(where: { $0.heardFraction < 0.98 }) {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeading(title: "Continue listening")
                                continueCard(session)
                            }
                        }
                        history(sessions)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 26)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("Recently Played")
        .searchable(text: $query, placement: .toolbar, prompt: "Search history")
        .toolbar {
            Button("Clear History") { isConfirmingClear = true }
                .disabled(userLibrary.sessions.isEmpty)
        }
        .confirmationDialog("Clear all listening history?", isPresented: $isConfirmingClear) {
            Button("Clear History", role: .destructive) { userLibrary.clearHistory() }
        } message: {
            Text("Every resume point on this Mac is removed.")
        }
    }

    // MARK: - Continue listening

    private func continueCard(_ session: ListeningSession) -> some View {
        let recording = session.recording
        let chapter = catalog.chapter(recording.chapterId)
        let isTimed = catalog.item(for: recording)?.edition.hasTiming ?? false
        let remaining = Double(session.durationMs - session.positionMs) / 1000

        return HStack(spacing: 16) {
            NumberTile(number: recording.chapterId, size: 72, fontSize: 30, radius: 10)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    SurahTitle(
                        title: chapter?.name ?? "Surah \(recording.chapterId)",
                        arabic: chapter?.arabicName, recording: recording, arabicSize: 15
                    )
                    .font(.system(size: 16, weight: .semibold))
                    if isTimed { Tag(title: "Sync", symbol: "waveform") }
                }
                RecordingByline(recording: recording, showsRiwayah: true)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.labelSecondary)
                HStack(spacing: 10) {
                    Text(positionLabel(session, chapter: chapter)).frame(width: 96, alignment: .leading)
                    ProgressTrack(fraction: Double(session.positionMs) / Double(max(session.durationMs, 1)), height: 4)
                    Text("\(remaining.clockTime) left").frame(width: 70, alignment: .leading)
                }
                .font(.system(size: 10).monospacedDigit())
                .foregroundStyle(Theme.labelSecondary)
                .frame(maxWidth: 520)
            }
            Spacer(minLength: 0)
            let isAvailable = catalog.item(for: recording) != nil
            ResumeButton(player: nowPlaying.player, isCurrent: nowPlaying.isCurrent(recording)) { resume(session) }
                .disabled(!isAvailable)
            Menu {
                RecordingActions(recording: recording, play: isAvailable ? { resume(session) } : nil)
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(Theme.labelSecondary)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .tint(Theme.labelSecondary)
            .frame(width: 28, height: 28)
            .accessibilityLabel("More actions")
        }
        .padding(14)
        .card()
    }

    private func positionLabel(_ session: ListeningSession, chapter: Chapter?) -> String {
        if let ayah = session.ayah?.int32Value, let chapter { return "Āyah \(ayah) of \(chapter.versesCount)" }
        return "Stopped at \((Double(session.positionMs) / 1000).clockTime)"
    }

    // MARK: - History

    private func history(_ sessions: [ListeningSession]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeading(title: "History", detail: sessions.count == 1 ? "1 session" : "\(sessions.count) sessions")
            if sessions.isEmpty {
                Text("No session matches “\(query)”")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.labelSecondary)
            }
            ForEach(dayGroups(sessions), id: \.title) { group in
                VStack(alignment: .leading, spacing: 1) {
                    Text(group.title)
                        .font(.system(size: 11, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.labelSecondary)
                        .padding(.leading, 2)
                        .padding(.bottom, 5)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(group.sessions, id: \.self) { session in
                        HistoryRow(
                            session: session,
                            chapter: catalog.chapter(session.recording.chapterId),
                            reciterName: catalog.reciterName(of: session.recording),
                            isAvailable: catalog.item(for: session.recording) != nil,
                            isCurrent: nowPlaying.isCurrent(session.recording),
                            isSelected: selection == session.recording,
                            select: { selection = session.recording },
                            resume: { resume(session) },
                            remove: { userLibrary.remove(session) }
                        )
                    }
                }
            }
        }
    }

    /// Today, yesterday, earlier this week, then by month.
    private func dayGroups(_ sessions: [ListeningSession]) -> [(title: String, sessions: [ListeningSession])] {
        let calendar = Calendar.current
        var groups: [(title: String, sessions: [ListeningSession])] = []
        for session in sessions {
            let date = Date(milliseconds: session.lastPlayedAtMs)
            let title: String
            if calendar.isDateInToday(date) {
                title = "Today"
            } else if calendar.isDateInYesterday(date) {
                title = "Yesterday"
            } else if let days = calendar.dateComponents([.day], from: date, to: .now).day, days < 7 {
                title = "Earlier this week"
            } else {
                title = date.formatted(.dateTime.month(.wide).year())
            }
            if groups.last?.title == title {
                groups[groups.count - 1].sessions.append(session)
            } else {
                groups.append((title, [session]))
            }
        }
        return groups
    }

    private func resume(_ session: ListeningSession) {
        if nowPlaying.isCurrent(session.recording) { return nowPlaying.player.play() }
        guard let item = catalog.item(for: session.recording) else { return }
        let queue = catalog.queue(item.edition)
        let start = queue.firstIndex { $0.chapter.id == item.chapter.id } ?? 0
        // A surah heard to the end starts again from the top.
        let position = session.positionMs < session.durationMs - 2000 ? session.positionMs : 0
        nowPlaying.play(queue, startingAt: start, positionMs: position)
    }

    private func matches(_ session: ListeningSession) -> Bool {
        let chapter = catalog.chapter(session.recording.chapterId)
        return catalog.reciterName(of: session.recording).matches(query) ||
            (chapter.map { $0.name.matches(query) || $0.arabicName.matches(query) || $0.translatedName.matches(query) } ?? false)
    }
}

/// Watches the player so the label follows its observed state.
private struct ResumeButton: View {
    @ObservedObject var player: PlaybackController
    let isCurrent: Bool
    let resume: () -> Void

    var body: some View {
        let isPlaying = isCurrent && player.isPlaying
        PillButton(title: isPlaying ? "Playing" : "Resume", symbol: "play.fill", isPrimary: true, action: resume)
            .disabled(isPlaying)
    }
}

private struct HistoryRow: View {
    let session: ListeningSession
    let chapter: Chapter?
    let reciterName: String
    let isAvailable: Bool
    let isCurrent: Bool
    let isSelected: Bool
    let select: () -> Void
    let resume: () -> Void
    let remove: () -> Void

    @EnvironmentObject private var nowPlaying: NowPlaying
    @Environment(\.tilawaAccent) private var accent
    @State private var isHovered = false

    var body: some View {
        let title = chapter?.name ?? "Surah \(session.recording.chapterId)"
        HStack(spacing: 11) {
            FavoriteButton(recording: session.recording, name: title)
            RowPlayButton(player: nowPlaying.player, isCurrent: isCurrent, name: title) {
                select()
                isCurrent ? nowPlaying.togglePlay() : resume()
            }
            .disabled(!isAvailable)
            HStack(spacing: 11) {
                VStack(alignment: .leading, spacing: 2) {
                    SurahTitle(title: title, recording: session.recording)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isCurrent ? accent : .primary)
                    RecordingByline(recording: session.recording)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.labelSecondary)
                }
                .frame(width: 250, alignment: .leading)
                Text(isAvailable ? session.recording.riwayahShortName : "Unavailable")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.labelSecondary)
                    .frame(width: 96, alignment: .leading)
                HStack(spacing: 9) {
                    ProgressTrack(fraction: session.heardFraction)
                    Text("\(Int((session.heardFraction * 100).rounded()))% heard")
                        .font(.system(size: 10).monospacedDigit())
                        .foregroundStyle(Theme.labelSecondary)
                        .frame(width: 62, alignment: .leading)
                }
                Text(timeLabel)
                    .font(.system(size: 11).monospacedDigit())
                    .foregroundStyle(Theme.labelSecondary)
                    .frame(width: 76, alignment: .trailing)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(chapter?.name ?? "Surah"), \(reciterName)")
            .accessibilityValue("\(Int(session.heardFraction * 100)) percent heard, \(timeLabel)")

            Button(action: remove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.labelTertiary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Remove from history")
            .accessibilityLabel("Remove from history")
        }
        .padding(.horizontal, 10)
        .frame(height: 46)
        .background(
            isSelected ? accent.opacity(0.2) : isHovered ? Theme.segment : .clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .surahRowClicks(select: select, play: isAvailable ? resume : nil)
        .onHover { isHovered = $0 }
        .contextMenu { actions }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAction(named: "Resume") { if isAvailable { resume() } }
    }

    @ViewBuilder
    private var actions: some View {
        RecordingActions(recording: session.recording, play: isAvailable ? resume : nil)
        Divider()
        Button("Remove from History", action: remove)
    }

    /// Minutes for the last hour, the time today and yesterday, then the day.
    private var timeLabel: String {
        let date = Date(milliseconds: session.lastPlayedAtMs)
        let calendar = Calendar.current
        if date > .now.addingTimeInterval(-60) { return "Just now" }
        if date > .now.addingTimeInterval(-3600) {
            return date.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated))
        }
        if calendar.isDateInToday(date) || calendar.isDateInYesterday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        if let days = calendar.dateComponents([.day], from: date, to: .now).day, days < 7 {
            return date.formatted(.dateTime.weekday(.abbreviated))
        }
        return date.formatted(.dateTime.day().month(.abbreviated))
    }
}

extension Date {
    init(milliseconds: Int64) { self.init(timeIntervalSince1970: Double(milliseconds) / 1000) }
}
