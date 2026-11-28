import Shared
import SwiftUI

/// The surah being listened to, then one flat history, newest first and
/// grouped by day.
struct RecentlyPlayedView: View {
    @EnvironmentObject private var history: ListeningHistory
    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var nowPlaying: NowPlaying
    @State private var query = ""
    @State private var isConfirmingClear = false
    @State private var selection: SurahRecording?

    var body: some View {
        let current = nowPlaying.current?.recording
        // With nothing in the player, as after a relaunch, the newest unfinished
        // session is the one to continue.
        let resumable = current == nil ? history.sessions.first { $0.heardFraction < 0.98 } : nil
        let continuing = current ?? resumable?.recording
        // The surah being continued is not history yet: it joins the list
        // once another surah takes its place.
        let earlier = history.sessions.filter { $0 != resumable && !nowPlaying.isCurrent($0.recording) }
        let shownContinuing = continuing.flatMap { matches($0) ? $0 : nil }
        Group {
            if continuing == nil && earlier.isEmpty {
                StateMessage(
                    symbol: "clock",
                    title: "Nothing played yet",
                    message: "Surahs you listen to appear here, newest first, so you can pick up where you stopped."
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        if let recording = shownContinuing {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeading(title: "Continue listening")
                                continueCard(recording, session: resumable)
                            }
                        }
                        if !earlier.isEmpty || shownContinuing == nil {
                            historyList(earlier.filter { matches($0.recording) })
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 26)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Clear History") { isConfirmingClear = true }
                    .disabled(history.sessions.isEmpty)
            }
            ToolbarSearchItem(text: $query, prompt: "Search history", separated: true)
        }
        .confirmationDialog("Clear all listening history?", isPresented: $isConfirmingClear) {
            Button("Clear History", role: .destructive) { history.clearHistory() }
        } message: {
            Text("Every resume point on this Mac is removed.")
        }
    }

    // MARK: - Continue listening

    /// The surah in the player, live, or a stored session to resume.
    private func continueCard(_ recording: SurahRecording, session: ListeningSession?) -> some View {
        let chapter = catalog.chapter(recording.chapterId)
        let isTimed = catalog.item(for: recording)?.edition.hasTiming ?? false
        let isCurrent = nowPlaying.isCurrent(recording)
        let isAvailable = catalog.item(for: recording) != nil
        let resume: () -> Void = {
            if let session, !isCurrent { self.resume(session) } else { nowPlaying.player.play() }
        }

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
                if isCurrent {
                    Watching(nowPlaying.player.clock) { clock in
                        positionLine(ayah: clock.ayah, elapsed: clock.elapsed,
                                     duration: nowPlaying.player.duration, chapter: chapter, isStopped: false)
                    }
                } else if let session {
                    positionLine(ayah: session.ayah?.int32Value, elapsed: Double(session.positionMs) / 1000,
                                 duration: Double(session.durationMs) / 1000, chapter: chapter, isStopped: true)
                }
            }
            Spacer(minLength: 0)
            ResumeButton(player: nowPlaying.player, isCurrent: isCurrent, resume: resume)
                .disabled(!isAvailable)
            RowMenu(label: "More actions") {
                RecordingActions(recording: recording, play: isAvailable ? resume : nil)
            }
        }
        .padding(14)
        .card()
        .tracksRowHover()
    }

    /// "Āyah 12 of 286 · 1:58:20 left", or the time when the recording is untimed.
    private func positionLine(ayah: Int32?, elapsed: Double, duration: Double, chapter: Chapter?, isStopped: Bool) -> some View {
        var parts: [String] = []
        if let ayah, let chapter {
            parts.append("Āyah \(ayah) of \(chapter.versesCount)")
        } else {
            parts.append(isStopped ? "Stopped at \(elapsed.clockTime)" : elapsed.clockTime)
        }
        if duration > elapsed { parts.append("\((duration - elapsed).clockTime) left") }
        return Text(parts.joined(separator: " · "))
            .font(.system(size: 11).monospacedDigit())
            .foregroundStyle(Theme.labelSecondary)
    }

    // MARK: - History

    private func historyList(_ sessions: [ListeningSession]) -> some View {
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
                            remove: { history.remove(session) }
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

    private func matches(_ recording: SurahRecording) -> Bool {
        let chapter = catalog.chapter(recording.chapterId)
        return catalog.reciterName(of: recording).matches(query) ||
            (chapter.map { $0.name.matches(query) || $0.arabicName.matches(query) || $0.translatedName.matches(query) } ?? false)
    }
}

/// Resume, or Pause while this surah plays. Watches the player so the label
/// follows its observed state.
private struct ResumeButton: View {
    @ObservedObject var player: PlaybackController
    let isCurrent: Bool
    let resume: () -> Void

    var body: some View {
        let canPause = isCurrent && player.isActive
        PillButton(
            title: canPause ? "Pause" : "Resume",
            symbol: canPause ? "pause.fill" : "play.fill",
            isPrimary: true,
            action: canPause ? player.pause : resume
        )
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
                    SurahTitle(title: title, arabic: chapter?.arabicName, recording: session.recording)
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
