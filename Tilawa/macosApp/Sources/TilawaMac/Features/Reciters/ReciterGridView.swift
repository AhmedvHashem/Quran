import Shared
import SwiftUI

/// Figma `26:2` — Home – Reciter Grid.
struct ReciterGridView: View {
    @StateObject private var viewModel: RecitersViewModel
    @EnvironmentObject private var router: AppRouter

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)

    init(library: QuranLibrary) {
        _viewModel = StateObject(wrappedValue: RecitersViewModel(library: library))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // The window is borderless — leave room for the real traffic lights.
            Color.clear.frame(height: Theme.titleBarHeight)
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.sidebarSurface)
        .task { await viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Choose a Reciter")
                .font(.system(size: 26, weight: .semibold))
            Text("\(viewModel.reciters.count) reciters available  ·  Browse by Riwayah & Style")
                .font(.system(size: 13))
                .foregroundStyle(Theme.labelSecondary)
        }
        .padding(.top, 6)
        .padding(.bottom, 24)
        .padding(.horizontal, 48)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.reciters.isEmpty {
            VStack {
                if let error = viewModel.errorMessage {
                    Text(error).font(.system(size: 13)).foregroundStyle(.red)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                SurfaceGroup(spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.reciters, id: \.self) { reciter in
                            ReciterCard(reciter: reciter) { router.openDetail(reciter) }
                        }
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct ReciterCard: View {
    let reciter: Reciter
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            Artwork(size: 52, iconSize: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(reciter.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isHovered ? .white : .primary)
                Text("Browse riwayat & styles")
                    .font(.system(size: 11))
                    .foregroundStyle(isHovered ? Color.white.opacity(0.8) : Theme.labelSecondary)
            }
            .lineLimit(2)

            Spacer(minLength: 8)

            Text(reciter.arabicName)
                .font(Theme.arabic(15))
                .foregroundStyle(isHovered ? Color.white.opacity(0.95) : Color.black.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .frame(height: 80)
        .surface(
            isHovered ? .tinted(Theme.accent) : .interactive,
            in: .rect(cornerRadius: 12),
            fallback: isHovered ? Theme.accent : Theme.cardSurface
        )
        .contentShape(.rect)
        // The design's blue card is the selected state; on a pointer platform
        // that reads as hover, and nothing is selected before you pick one.
        .onHover { isHovered = $0 }
        .onTapGesture(perform: onSelect)
    }
}

/// The green album tile that stands in for reciter artwork.
struct Artwork: View {
    let size: CGFloat
    let iconSize: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Theme.artwork)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.white)
            }
    }
}
