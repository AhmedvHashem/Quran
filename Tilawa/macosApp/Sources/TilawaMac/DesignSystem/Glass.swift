import SwiftUI

/// Liquid Glass, applied through one seam so the deployment floor stays at
/// macOS 13: on 26+ these render as real glass, below they fall back to the
/// flat Figma fills. Nothing outside this file names a `Glass` type.
enum Surface {
    case plain
    case interactive
    case tinted(Color)
}

extension View {
    @ViewBuilder
    func surface(_ style: Surface = .plain, in shape: some Shape, fallback: Color) -> some View {
        if #available(macOS 26, *) {
            glassEffect(style.glass, in: shape)
        } else {
            background(fallback, in: shape)
        }
    }
}

@available(macOS 26, *)
private extension Surface {
    var glass: Glass {
        switch self {
        case .plain: .regular
        case .interactive: .regular.interactive()
        case .tinted(let color): .regular.tint(color).interactive()
        }
    }
}

/// Groups sibling glass shapes so they blend into each other instead of
/// stacking their own blurs. A no-op below macOS 26.
struct SurfaceGroup<Content: View>: View {
    var spacing: CGFloat = 20
    @ViewBuilder let content: Content

    var body: some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
    }
}

/// A borderless icon button that picks up the glass button style on macOS 26.
struct IconButton: View {
    let symbol: String
    var size: CGFloat = 14
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size))
                .foregroundStyle(tint ?? .primary)
                .frame(width: 28, height: 28)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
