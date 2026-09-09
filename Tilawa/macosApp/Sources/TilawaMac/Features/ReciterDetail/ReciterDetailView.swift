import Shared
import SwiftUI

/// Reciter detail screen: lists all available recordings grouped by riwayah then style.
struct ReciterDetailView: View {
    @StateObject private var viewModel: ReciterDetailViewModel
    @EnvironmentObject private var router: AppRouter

    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 380), spacing: 16)
    ]

    init(library: QuranLibrary, reciter: Reciter) {
        _viewModel = StateObject(wrappedValue: ReciterDetailViewModel(library: library, reciter: reciter))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(height: Theme.titleBarHeight)

            // Back button and header
            topBar
                .padding(.horizontal, 48)
                .padding(.top, 8)
                .padding(.bottom, 16)

            reciterHeader
                .padding(.horizontal, 48)
                .padding(.bottom, 24)

            Divider()
                .padding(.horizontal, 48)
                .padding(.bottom, 20)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.sidebarSurface)
        .task { await viewModel.load() }
    }

    private var topBar: some View {
        Button(action: { router.backToReciters() }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                Text("All Reciters")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(Theme.accent)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Theme.accent.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var reciterHeader: some View {
        HStack(spacing: 20) {
            Artwork(size: 72, iconSize: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.reciter.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text("\(viewModel.editions.count) recording \(viewModel.editions.count == 1 ? "edition" : "editions") available")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.labelSecondary)
            }

            Spacer()

            Text(viewModel.reciter.arabicName)
                .font(Theme.arabic(26))
                .foregroundStyle(Color.black.opacity(0.75))
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.editions.isEmpty {
            VStack {
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage, viewModel.editions.isEmpty {
            VStack(spacing: 12) {
                Text("Failed to load editions")
                    .font(.system(size: 15, weight: .semibold))
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                Button("Retry") { Task { await viewModel.load() } }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(viewModel.groups) { group in
                        riwayahSection(group)
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 32)
            }
        }
    }

    private func riwayahSection(_ group: RiwayahGroup) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.accent)
                Text(group.riwayah.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("(\(group.editions.count) \(group.editions.count == 1 ? "style" : "styles"))")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.labelSecondary)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(group.editions, id: \.id) { edition in
                    EditionCard(edition: edition) {
                        router.openPlayer(viewModel.reciter, edition)
                    }
                }
            }
        }
    }
}

private struct EditionCard: View {
    let edition: RecitationEdition
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(edition.style)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isHovered ? .white : .primary)

                    Text("\(edition.availableSurahs.count) Surahs available")
                        .font(.system(size: 12))
                        .foregroundStyle(isHovered ? Color.white.opacity(0.8) : Theme.labelSecondary)
                }

                Spacer()

                if edition.isFeatured {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("Featured")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(isHovered ? Color.white.opacity(0.25) : Theme.accent.opacity(0.12))
                    .foregroundStyle(isHovered ? .white : Theme.accent)
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 8) {
                if edition.hasTiming {
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.system(size: 10))
                        Text("Verse Sync")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isHovered ? Color.white.opacity(0.2) : Color.green.opacity(0.12))
                    .foregroundStyle(isHovered ? .white : Color.green.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle")
                            .font(.system(size: 10))
                        Text("Full Audio")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isHovered ? Color.white.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundStyle(isHovered ? .white : Theme.labelSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(isHovered ? .white : Theme.accent)
            }
        }
        .padding(14)
        .frame(minHeight: 90)
        .surface(
            isHovered ? .tinted(Theme.accent) : .interactive,
            in: .rect(cornerRadius: 12),
            fallback: isHovered ? Theme.accent : Theme.cardSurface
        )
        .contentShape(.rect)
        .onHover { isHovered = $0 }
        .onTapGesture(perform: onSelect)
    }
}
