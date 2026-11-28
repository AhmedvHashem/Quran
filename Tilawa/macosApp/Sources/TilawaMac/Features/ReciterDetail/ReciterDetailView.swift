import Shared
import SwiftUI

/// One reciter's recording editions, grouped by riwayah and then style.
struct ReciterDetailView: View {
    let reciter: Reciter

    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var nowPlaying: NowPlaying

    var body: some View {
        let editions = catalog.editions(of: reciter)
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                hero(editions)
                ForEach(groups(editions), id: \.first!.riwayah.name) { group in
                    riwayahSection(group)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 28)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay {
            if editions.isEmpty {
                StateMessage(symbol: "waveform.slash", title: "No recordings available")
            }
        }
        .navigationTitle(reciter.name)
        // The hero carries the name; the design's toolbar holds only the back button.
        .hidingToolbarTitle()
    }

    private func hero(_ editions: [RecitationEdition]) -> some View {
        HStack(alignment: .top, spacing: 24) {
            LetterTile(letter: reciter.initial, seed: reciter.id, size: 168, fontSize: 84, radius: 14)
                .shadow(color: .black.opacity(0.12), radius: 1.5, y: 1)
                .shadow(color: .black.opacity(0.25), radius: 18, y: 18)

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(reciter.name)
                        .font(.system(size: 30, weight: .semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(reciter.arabicName)
                        .arabic(22)
                        .foregroundStyle(Theme.labelSecondary)
                }
                Text(summary(editions))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.labelSecondary)

                HStack(spacing: 10) {
                    if let edition = catalog.preferredEdition(of: reciter),
                       let first = catalog.queue(edition).first {
                        PillButton(title: "Play \(first.chapter.name)", symbol: "play.fill", isPrimary: true) {
                            nowPlaying.play(catalog.queue(edition))
                        }
                    }
                    ReciterFavoriteButton(reciter: reciter)
                }
                .padding(.top, 2)
            }
            .padding(.top, 6)
        }
    }

    private func summary(_ editions: [RecitationEdition]) -> String {
        let riwayat = Set(editions.map(\.riwayah.name)).count
        let timed = editions.filter(\.hasTiming).count
        var parts = [
            editions.count == 1 ? "1 recording edition" : "\(editions.count) recording editions",
            riwayat == 1 ? "1 riwayah" : "\(riwayat) riwayat",
        ]
        if timed > 0 { parts.append(timed == 1 ? "Verse Sync on 1 edition" : "Verse Sync on \(timed) editions") }
        return parts.joined(separator: " · ")
    }

    /// Ḥafṣ first, then the riwayat with the most styles; featured editions lead each group.
    private func groups(_ editions: [RecitationEdition]) -> [[RecitationEdition]] {
        Dictionary(grouping: editions, by: \.riwayah.name).values
            .map { $0.sorted { ($0.isFeatured ? 1 : 0, $0.availableSurahs.count) > ($1.isFeatured ? 1 : 0, $1.availableSurahs.count) } }
            .sorted { lhs, rhs in
                let lhsHafs = lhs[0].riwayah.id?.int32Value == 1, rhsHafs = rhs[0].riwayah.id?.int32Value == 1
                if lhsHafs != rhsHafs { return lhsHafs }
                return (lhs.count, rhs[0].riwayah.name) > (rhs.count, lhs[0].riwayah.name)
            }
    }

    private func riwayahSection(_ editions: [RecitationEdition]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(editions[0].riwayah.name).font(.system(size: 13, weight: .semibold))
                Text(editions.count == 1 ? "1 style" : "\(editions.count) styles")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.labelSecondary)
            }
            .padding(.leading, 2)
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(editions.enumerated()), id: \.element.id) { offset, edition in
                    if offset > 0 { Theme.hairline.frame(height: 0.5).padding(.leading, 16) }
                    EditionRow(edition: edition) { router.openRecording(edition) }
                }
            }
            .card()
        }
    }
}

private struct EditionRow: View {
    let edition: RecitationEdition
    let open: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: open) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 7) {
                        Text(edition.style).font(.system(size: 14, weight: .semibold))
                        if edition.isFeatured { Tag(title: "FEATURED") }
                    }
                    Text("\(edition.availableSurahs.count) surahs · \(edition.hasTiming ? "Verse Sync verified for this recording" : "continuous audio, no timing map")")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.labelSecondary)
                }
                Spacer(minLength: 12)
                if edition.hasTiming {
                    Tag(title: "Verse Sync", symbol: "waveform")
                } else {
                    Tag(title: "Full Audio", tint: Theme.labelSecondary, fill: Theme.segment)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.labelTertiary)
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(isHovered ? Theme.segment : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .accessibilityLabel("\(edition.style), \(edition.availableSurahs.count) surahs, \(edition.hasTiming ? "Verse Sync" : "Full Audio")")
        .accessibilityHint("Show the surahs in this edition")
    }
}
