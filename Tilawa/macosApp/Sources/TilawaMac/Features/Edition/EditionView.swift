import Shared
import SwiftUI

/// Every surah inside one recording edition, in muṣḥaf order.
struct EditionView: View {
    let edition: RecitationEdition

    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var nowPlaying: NowPlaying
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var userLibrary: UserLibrary
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selectedChapter: Int32?

    var body: some View {
        let queue = catalog.queue(edition)
        let shown = queue.indices.filter { matches(queue[$0].chapter) }

        ScrollViewReader { scroll in
            scrollContent(queue, shown: shown)
                .task(id: router.editionLink) {
                    guard let link = router.editionLink, link.destination == router.current, link.editionId == edition.id,
                          let chapter = queue.first(where: { $0.chapter.id == link.chapterId })?.chapter else { return }
                    selectedChapter = chapter.id
                    if !matches(chapter) {
                        query = ""
                        await Task.yield()
                    }
                    guard !Task.isCancelled else { return }
                    scroll.scrollTo(chapter.id, anchor: .center)
                }
        }
        .navigationTitle("\(edition.style) · \(edition.riwayahShortName)")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                let back = router.backTitle { userLibrary.collection($0)?.name }
                Button(action: { dismiss() }) {
                    Label(back, systemImage: "chevron.left")
                        .labelStyle(.titleAndIcon)
                }
                .keyboardShortcut("[", modifiers: .command)
                .help("Back to \(back)")
                .accessibilityLabel("Back to \(back)")
            }
            ToolbarSearchItem(text: $query, prompt: "Find surah")
        }
    }

    private func scrollContent(_ queue: [QueueItem], shown: [Int]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero(queue)
                VStack(spacing: 0) {
                    ColumnHeader {
                        Color.clear.frame(width: 14, height: 1)
                        Color.clear.frame(width: 26, height: 1)
                        Text("Surah").frame(width: 250, alignment: .leading)
                        Text("Length").frame(maxWidth: .infinity, alignment: .leading)
                        Color.clear.frame(width: 28, height: 1)
                    }
                    if shown.isEmpty {
                        Text("No surah matches “\(query)”")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.labelSecondary)
                            .frame(maxWidth: .infinity, minHeight: 88)
                    }
                    LazyVStack(spacing: 0) {
                        ForEach(shown, id: \.self) { index in
                            let item = queue[index]
                            let play = { nowPlaying.play(queue, startingAt: index) }
                            SurahRow(
                                recording: item.recording,
                                chapter: item.chapter,
                                isCurrent: nowPlaying.isCurrent(item.recording),
                                isSelected: selectedChapter == item.chapter.id,
                                select: { selectedChapter = item.chapter.id },
                                play: play
                            ) {
                                Text("\(item.chapter.versesCount) āyāt")
                                    .font(.system(size: 11.5).monospacedDigit())
                                    .foregroundStyle(Theme.labelSecondary)
                            } actions: {
                                RecordingActions(recording: item.recording, play: play)
                            }
                            .id(item.chapter.id)
                        }
                    }
                }
                .card()
            }
            .padding(.horizontal, 32)
            .padding(.top, 26)
            .padding(.bottom, 32)
        }
    }

    private func hero(_ queue: [QueueItem]) -> some View {
        HStack(alignment: .bottom, spacing: 20) {
            OrnamentTile {
                ArabicGlyph(text: String(arabicStyle?.first ?? "م"), size: 56)
                    .foregroundStyle(Theme.ornamentBorder)
            }

            VStack(alignment: .leading, spacing: 9) {
                Text("Recording edition")
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .kerning(0.6)
                    .foregroundStyle(Theme.labelSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(edition.style).font(.system(size: 30, weight: .bold))
                    if let arabicStyle {
                        Text(arabicStyle).arabic(24).foregroundStyle(Theme.labelSecondary)
                    }
                }
                .accessibilityAddTraits(.isHeader)
                HStack(spacing: 0) {
                    if let reciter = catalog.reciter(edition.reciterId) {
                        NameLink(title: reciter.name) { router.open(.reciter(reciter)) }
                        Text(" · ")
                    }
                    Text(metadata(queue))
                }
                .font(.system(size: 12.5))
                .foregroundStyle(Theme.labelSecondary)
                HStack(spacing: 9) {
                    PillButton(title: "Play All", symbol: "play.fill", isPrimary: true) { nowPlaying.play(queue) }
                    PillButton(title: "Shuffle", symbol: "shuffle") { nowPlaying.shuffle(queue) }
                    if edition.hasTiming {
                        CapsuleTag(title: "Āyah timing verified", symbol: "waveform")
                    }
                }
                .disabled(queue.isEmpty)
                .padding(.top, 5)
            }
            .padding(.bottom, 4)
        }
    }

    private func metadata(_ queue: [QueueItem]) -> String {
        let ayat = queue.reduce(0) { $0 + Int($1.chapter.versesCount) }
        return [
            edition.riwayah.name,
            queue.count == 1 ? "1 surah" : "\(queue.count) surahs",
            "\(ayat.formatted()) āyāt",
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }

    /// Arabic names for the styles the catalog uses; others show English only.
    private var arabicStyle: String? {
        ["Murattal": "مرتل", "Mujawwad": "مجود", "Muʿallim": "معلم"][edition.style]
    }

    private func matches(_ chapter: Chapter) -> Bool {
        query.trimmingCharacters(in: .whitespaces) == "\(chapter.id)" ||
            chapter.name.matches(query) || chapter.translatedName.matches(query) || chapter.arabicName.matches(query)
    }
}
