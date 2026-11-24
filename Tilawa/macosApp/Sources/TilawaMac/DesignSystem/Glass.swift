import AppKit
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

extension View {
    /// Leaves the window title to VoiceOver and the Window menu, out of the toolbar.
    @ViewBuilder
    func hidingToolbarTitle() -> some View {
        if #available(macOS 15, *) { toolbar(removing: .title) } else { self }
    }
}

extension View {
    /// Keeps the end of every scrolling page above the floating player bar.
    /// Margins pass down through the environment to every scroll view, pushed
    /// pages included; content still scrolls under the bar's glass.
    @available(macOS 14, *)
    func playerBarClearance() -> some View {
        contentMargins(.bottom, PlayerBar.height, for: .scrollContent)
            .contentMargins(.bottom, PlayerBar.height, for: .scrollIndicators)
    }
}

/// A native search field in the detail toolbar instead of `.searchable`.
/// SwiftUI appends `.searchable` after the inspector tracking separator on
/// macOS 26, which pushes the field into the queue column; a `.primaryAction`
/// `NSSearchField` stays in the detail toolbar and still adopts Liquid Glass.
struct ToolbarSearchItem: ToolbarContent {
    @Binding var text: String
    let prompt: String
    /// Inserts a fixed spacer before the field so a preceding toolbar item keeps its own glass shape.
    var separated = false

    var body: some ToolbarContent {
        if separated {
            if #available(macOS 26, *) {
                ToolbarSpacer(.fixed)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            ToolbarSearchField(text: $text, prompt: prompt)
        }
    }
}

private struct ToolbarSearchField: NSViewRepresentable {
    @Binding var text: String
    let prompt: String

    final class Coordinator: NSObject, NSSearchFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) { self.text = text }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSSearchField else { return }
            sync(field.stringValue)
        }

        @objc func searchAction(_ sender: NSSearchField) {
            sync(sender.stringValue)
        }

        private func sync(_ value: String) {
            if text.wrappedValue != value { text.wrappedValue = value }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeNSView(context: Context) -> NSSearchField {
        let field = NSSearchField()
        field.delegate = context.coordinator
        field.target = context.coordinator
        field.action = #selector(Coordinator.searchAction(_:))
        field.placeholderString = prompt
        field.stringValue = text
        field.sendsSearchStringImmediately = true
        field.sendsWholeSearchString = false
        field.maximumNumberOfLines = 1
        field.cell?.usesSingleLineMode = true
        field.cell?.isScrollable = true
        field.setAccessibilityLabel(prompt)
        let preferred = field.widthAnchor.constraint(equalToConstant: 200)
        preferred.priority = .defaultHigh
        preferred.isActive = true
        field.widthAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true
        return field
    }

    func updateNSView(_ field: NSSearchField, context: Context) {
        context.coordinator.text = $text
        if field.stringValue != text { field.stringValue = text }
        if field.placeholderString != prompt {
            field.placeholderString = prompt
            field.setAccessibilityLabel(prompt)
        }
    }
}
