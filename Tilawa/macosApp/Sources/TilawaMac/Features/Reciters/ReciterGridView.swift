import Shared
import SwiftUI

/// The whole catalog, with search and filters. Featured reciters live on Home.
struct ReciterGridView: View {
    @EnvironmentObject private var catalog: Catalog

    @State private var query = ""
    @State private var riwayahId: Int32?
    @State private var style: String?
    @State private var syncOnly = false

    var body: some View {
        CatalogGate {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    let matches = catalog.reciters.filter(matches)
                    SectionHeading(title: "All reciters", detail: "\(matches.count) of \(catalog.reciters.count)")
                        .padding(.bottom, 14)
                    filterBar.padding(.bottom, 20)
                    if matches.isEmpty {
                        StateMessage(
                            symbol: "magnifyingglass",
                            title: "No reciters match",
                            message: "Try another name, or clear the filters.",
                            actionTitle: "Clear Filters",
                            action: clear
                        )
                    } else {
                        ReciterGrid(reciters: matches)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 26)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Reciters")
        .toolbar {
            ToolbarSearchItem(text: $query, prompt: "Search reciters")
        }
    }

    // MARK: - Filters

    /// One row when it fits; otherwise the riwayah chips get a row of their own.
    private var filterBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                riwayahPicker
                Divider().frame(height: 18)
                otherFilters
            }
            VStack(alignment: .leading, spacing: 10) {
                riwayahPicker
                HStack(spacing: 10) { otherFilters }
            }
        }
        .font(.system(size: 12))
    }

    private var riwayahPicker: some View {
        FilterChips(
            title: "Riwayah",
            options: [(Int32?.none, "All riwayat")] + riwayahOptions.map { (Int32?.some($0.id), $0.name) },
            selection: $riwayahId
        )
    }

    @ViewBuilder
    private var otherFilters: some View {
        FilterChips(
            title: "Recitation style",
            options: [(String?.none, "All recordings")] + styleOptions.map { (String?.some($0), $0) },
            selection: $style
        )

        Divider().frame(height: 18)

        FilterToggle(title: "Verse Sync", symbol: "waveform", isOn: $syncOnly)
            .help("Only reciters with verified ayah timing")

        Button("Clear", action: clear)
            .buttonStyle(.borderless)
            .fixedSize()
            .disabled(!isFiltering)
    }

    /// The four riwayat most reciters record in.
    private var riwayahOptions: [(id: Int32, name: String)] {
        // ponytail: top four as segments, like the design; a menu if users need the long tail.
        topValues(4) { $0.riwayah.id?.int32Value }
            .compactMap { id in
                catalog.editionsByReciter.values.lazy.flatMap { $0 }
                    .first { $0.riwayah.id?.int32Value == id }
                    .map { (id, $0.riwayah.shortName) }
            }
    }

    private var styleOptions: [String] { topValues(3) { $0.style } }

    /// The most common values across reciters, counting each reciter once.
    private func topValues<Value: Hashable>(_ limit: Int, of key: (RecitationEdition) -> Value?) -> [Value] {
        var counts: [Value: Int] = [:]
        for editions in catalog.editionsByReciter.values {
            for value in Set(editions.compactMap(key)) { counts[value, default: 0] += 1 }
        }
        // Ties break by value so the chips never reorder between renders.
        return counts.sorted { ($0.value, "\($1.key)") > ($1.value, "\($0.key)") }.prefix(limit).map(\.key)
    }

    private var isFiltering: Bool { riwayahId != nil || style != nil || syncOnly }

    private func clear() {
        riwayahId = nil
        style = nil
        syncOnly = false
        query = ""
    }

    /// Filters combine: a reciter matches when one edition satisfies all of them.
    private func matches(_ reciter: Reciter) -> Bool {
        guard reciter.name.matches(query) || reciter.arabicName.matches(query) else { return false }
        guard isFiltering else { return true }
        return catalog.editions(of: reciter).contains { edition in
            (riwayahId == nil || edition.riwayah.id?.int32Value == riwayahId) &&
                (style == nil || edition.style == style) &&
                (!syncOnly || edition.hasTiming)
        }
    }

}

/// Reciter cards in the design's portrait layout, four across at the default width.
struct ReciterGrid: View {
    let reciters: [Reciter]

    @EnvironmentObject private var catalog: Catalog
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var nowPlaying: NowPlaying

    private let columns = [GridItem(.adaptive(minimum: 200, maximum: 280), spacing: 20)]
    private let styleOrder = ["Murattal", "Mujawwad", "Muʿallim"]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
            ForEach(reciters, id: \.self) { reciter in
                let editions = catalog.editions(of: reciter)
                ReciterCard(
                    reciter: reciter,
                    styles: editions.map(\.style).uniqued
                        .sorted { (styleOrder.firstIndex(of: $0) ?? .max) < (styleOrder.firstIndex(of: $1) ?? .max) }
                        .prefix(3).joined(separator: " · "),
                    hasSync: editions.contains(where: \.hasTiming),
                    open: { router.open(.reciter(reciter)) }
                )
                .contextMenu {
                    if let edition = catalog.preferredEdition(of: reciter) {
                        Button("Play Complete Muṣḥaf") { nowPlaying.play(catalog.queue(edition)) }
                        Button("Shuffle Surahs") { nowPlaying.shuffle(catalog.queue(edition)) }
                    }
                }
            }
        }
    }
}

/// Shows the catalog's content once loaded, and its loading and failure states until then.
struct CatalogGate<Content: View>: View {
    @EnvironmentObject private var catalog: Catalog
    @ViewBuilder let content: Content

    var body: some View {
        if catalog.isLoaded {
            content
        } else if catalog.failure != nil {
            StateMessage(
                symbol: "wifi.exclamationmark",
                title: "Couldn't reach the catalogue",
                message: "Check your connection and try again.",
                actionTitle: "Try Again"
            ) { Task { await catalog.load() } }
        } else {
            VStack(spacing: 10) {
                ProgressView()
                Text("Loading reciters").font(.system(size: 12)).foregroundStyle(Theme.labelSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct ReciterCard: View {
    let reciter: Reciter
    let styles: String
    let hasSync: Bool
    let open: () -> Void

    @EnvironmentObject private var userLibrary: UserLibrary
    @State private var isHovered = false

    var body: some View {
        let isFavorite = userLibrary.isFavorite(reciter)
        Button(action: open) {
            VStack(alignment: .leading, spacing: 0) {
                LetterTile(letter: reciter.initial, seed: reciter.id)
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .overlay(alignment: .bottom) { Theme.hairline.frame(height: 0.5) }

                VStack(alignment: .leading, spacing: 3) {
                    Text(reciter.name)
                        .font(.system(size: 13, weight: .semibold))
                    Text(reciter.arabicName)
                        .arabic(14)
                        .foregroundStyle(Theme.labelSecondary)
                    HStack(spacing: 6) {
                        Text(styles)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.labelSecondary)
                        if hasSync { Tag(title: "Sync", symbol: "waveform") }
                    }
                    .padding(.top, 1)
                }
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.top, 11)
                .padding(.bottom, 12)
            }
            .card(raised: isHovered)
            .offset(y: isHovered ? -2 : 0)
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Beside the card's button, not inside it: the heart shows on hover
        // and stays while the reciter is a favorite.
        .overlay(alignment: .topTrailing) {
            if isHovered || isFavorite {
                ReciterFavoriteButton(reciter: reciter, controlSize: .small)
                    .padding(8)
                    .offset(y: isHovered ? -2 : 0)
                    .transition(.opacity)
            }
        }
        .onHover { isHovered = $0 }
        .contextMenu {
            Button(isFavorite ? "Remove from Favorites" : "Add to Favorites") { userLibrary.toggleFavorite(reciter) }
        }
        .accessibilityLabel("\(reciter.name), \(reciter.arabicName)")
        .accessibilityValue(hasSync ? "\(styles), Verse Sync" : styles)
        .accessibilityHint("Show riwayat and recording styles")
        .accessibilityAction(named: isFavorite ? "Remove from Favorites" : "Add to Favorites") {
            userLibrary.toggleFavorite(reciter)
        }
    }
}

extension Sequence where Element: Hashable {
    /// Distinct elements in their first-seen order.
    var uniqued: [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

/// One filter group as Liquid Glass chips; the selected chip is prominent
/// glass. A segmented control below macOS 26.
struct FilterChips<Value: Hashable>: View {
    let title: String
    let options: [(value: Value, label: String)]
    @Binding var selection: Value

    var body: some View {
        if #available(macOS 26, *) {
            // Spacing 0 keeps chips from melting together, which bled the
            // selected chip's tint into its neighbour.
            GlassEffectContainer(spacing: 0) {
                HStack(spacing: 6) {
                    ForEach(options.indices, id: \.self) { index in
                        chip(options[index])
                    }
                }
            }
            .fixedSize()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(title)
        } else {
            Picker(title, selection: $selection) {
                ForEach(options.indices, id: \.self) { Text(options[$0].label).tag(options[$0].value) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
        }
    }

    @available(macOS 26, *)
    @ViewBuilder
    private func chip(_ option: (value: Value, label: String)) -> some View {
        let isSelected = selection == option.value
        let button = Button(option.label) {
            withAnimation(.snappy(duration: 0.2)) { selection = option.value }
        }
        .buttonBorderShape(.capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        if isSelected { button.buttonStyle(.glassProminent) } else { button.buttonStyle(.glass).tint(nil) }
    }
}

/// An on/off filter in the same glass as `FilterChips`.
struct FilterToggle: View {
    let title: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        if #available(macOS 26, *) {
            let button = Button {
                withAnimation(.snappy(duration: 0.2)) { isOn.toggle() }
            } label: {
                Label(title, systemImage: symbol)
            }
            .buttonBorderShape(.capsule)
            .fixedSize()
            .accessibilityAddTraits(isOn ? .isSelected : [])
            if isOn { button.buttonStyle(.glassProminent) } else { button.buttonStyle(.glass).tint(nil) }
        } else {
            Toggle(isOn: $isOn) { Label(title, systemImage: symbol) }
                .toggleStyle(.button)
                .fixedSize()
        }
    }
}
