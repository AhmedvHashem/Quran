import AppKit
import Shared
import SwiftUI

/// Tokens from the Claude Design canvas "Tilawa Desktop App - Design": the
/// palette in PRODUCT.md and the dark values from the canvas's Appearance tweak.
enum Theme {
    // Light and dark values from the design's Appearance tweak.
    static let content = Color(light: 0xFFFFFF, dark: 0x141416)
    static let card = Color(light: 0xFFFFFF, dark: 0x232326)
    static let labelSecondary = Color(light: 0x8A8A8E, dark: 0x98989D)
    static let labelTertiary = Color(light: .black.withAlphaComponent(0.35), dark: .white.withAlphaComponent(0.4))
    static let hairline = Color(light: .black.withAlphaComponent(0.12), dark: .white.withAlphaComponent(0.14))
    static let segment = Color(
        light: NSColor(red: 120 / 255, green: 120 / 255, blue: 128 / 255, alpha: 0.14),
        dark: .white.withAlphaComponent(0.12)
    )

    static let mushafSurface = Color(light: 0xFDFBF7, dark: 0x17140F)
    static let ornamentSurface = Color(light: 0xFBF6EC, dark: 0x211B12)
    static let ornamentBorder = Color(light: 0xB08A3E, dark: 0xC9A45C)
    static let playerSurface = Color(light: 0xECECEC, dark: 0x232326)

    /// Reciter avatar tiles: background and letter, picked by reciter id.
    static let tiles: [(background: Color, ink: Color)] = [
        (Color(light: 0xDEE9E2, dark: 0x1E2B25), Color(light: 0x2F6B52, dark: 0x6FBF9B)),
        (Color(light: 0xEFE7D4, dark: 0x2C271B), Color(light: 0x8A6B23, dark: 0xC8A65C)),
        (Color(light: 0xE0E3EE, dark: 0x1F2333), Color(light: 0x414C7A, dark: 0x8A97C8)),
        (Color(light: 0xEDE1DA, dark: 0x2C221D), Color(light: 0x7E4F3C, dark: 0xC08B72)),
        (Color(light: 0xDAE7E9, dark: 0x1B2729), Color(light: 0x2E6470, dark: 0x6FA8B2)),
        (Color(light: 0xE8DFE7, dark: 0x271F26), Color(light: 0x6A4566, dark: 0xB189A8)),
    ]

    /// Falls back to the system Arabic face when Amiri Quran isn't installed.
    static func arabic(_ size: CGFloat) -> Font { .custom("Amiri Quran", size: size) }

    /// Amiri Quran's natural line is ~2.45 em to leave room for marks; the
    /// design sets Arabic names at 1.5 em. This is the trim per side, per point.
    static let arabicTrim: CGFloat = {
        guard let font = NSFont(name: "Amiri Quran", size: 100) else { return 0 }
        return min(0, (150 - NSLayoutManager().defaultLineHeight(for: font)) / 200)
    }()
}

/// A letter or number centred by its ink, not its line box. Amiri Quran keeps
/// a tall ascent for marks, so a plainly centred glyph sits low in its tile.
struct ArabicGlyph: View {
    let text: String
    let size: CGFloat

    var body: some View {
        Text(text).font(Theme.arabic(size)).offset(y: Theme.inkOffset(of: text) * size)
    }
}

extension Theme {
    @MainActor private static var inkOffsets: [String: CGFloat] = [:]

    /// How far, per point of font size, to move `text` so its drawn shape sits
    /// at the centre of its line box.
    @MainActor
    static func inkOffset(of text: String) -> CGFloat {
        if let cached = inkOffsets[text] { return cached }
        let font = NSFont(name: "Amiri Quran", size: 100) ?? .systemFont(ofSize: 100)
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
        let ink = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        // The line box puts the baseline `ascender` below its top; `ink` is measured up from the baseline.
        let lineHeight = NSLayoutManager().defaultLineHeight(for: font)
        let offset = ink.isEmpty ? 0 : (lineHeight / 2 - (font.ascender - ink.midY)) / 100
        inkOffsets[text] = offset
        return offset
    }
}

extension View {
    /// An Arabic line at the design's 1.5 line height, like CSS `line-height: 1.5`.
    func arabic(_ size: CGFloat) -> some View {
        font(Theme.arabic(size)).padding(.vertical, Theme.arabicTrim * size)
    }
}

/// Settings › General › Appearance.
enum AppearanceChoice: String, CaseIterable {
    case system, light, dark

    static let key = "appearance"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// Settings › General › Accent color.
enum AccentChoice: String, CaseIterable {
    case system, green, gold

    static let key = "accent"

    var title: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .system: Color(nsColor: .controlAccentColor)
        case .green: Color(light: 0x1B7A5A, dark: 0x3FBF8F)
        case .gold: Color(light: 0x97762B, dark: 0xD8B463)
        }
    }
}

private struct TilawaAccentKey: EnvironmentKey {
    static var defaultValue: Color { AccentChoice.system.color }
}

extension EnvironmentValues {
    var tilawaAccent: Color {
        get { self[TilawaAccentKey.self] }
        set { self[TilawaAccentKey.self] = newValue }
    }
}

extension Color {
    /// A color that follows the light or dark appearance it is drawn in.
    init(light: NSColor, dark: NSColor) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        })
    }

    init(light: UInt32, dark: UInt32) {
        self.init(light: NSColor(hex: light), dark: NSColor(hex: dark))
    }
}

extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// Arabic-Indic digits, for surah numbers.
func arabicIndic(_ value: Int32) -> String {
    String(String(value).map { Character(UnicodeScalar(UInt32($0.asciiValue! - 48) + 0x0660)!) })
}

extension Double {
    /// `0:22`, `2:12:40`, or `--:--` while an item is still loading.
    var clockTime: String {
        guard isFinite, self >= 0 else { return "--:--" }
        let total = Int(self)
        return total >= 3600
            ? String(format: "%d:%02d:%02d", total / 3600, total / 60 % 60, total % 60)
            : String(format: "%d:%02d", total / 60, total % 60)
    }
}

extension String {
    /// Case- and mark-insensitive form for matching, never for display: folds
    /// Latin diacritics and Arabic harakat and hamza seats alike.
    var searchKey: String { folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil) }

    func matches(_ query: String) -> Bool {
        let key = query.trimmingCharacters(in: .whitespaces).searchKey
        return key.isEmpty || searchKey.contains(key)
    }
}

// MARK: - Surfaces

extension View {
    /// The design's raised card on the white content surface. Content is
    /// clipped to the corners; only the card itself casts the shadow.
    func card(radius: CGFloat = 12, raised: Bool = false) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
            .background {
                RoundedRectangle(cornerRadius: radius)
                    .fill(Theme.card)
                    .shadow(color: .black.opacity(0.05), radius: 1.5, y: 1)
                    .shadow(color: .black.opacity(raised ? 0.16 : 0.09), radius: raised ? 16 : 12, y: raised ? 10 : 8)
            }
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Theme.hairline.opacity(0.5), lineWidth: 0.5))
    }
}

// MARK: - Artwork

/// Initial-letter avatar: reciters ship no photographs in v1.
struct LetterTile: View {
    let letter: String
    let seed: Int32
    var size: CGFloat? = nil
    var fontSize: CGFloat = 60
    var radius: CGFloat = 0

    var body: some View {
        let tile = Theme.tiles[Int(seed.magnitude) % Theme.tiles.count]
        ZStack {
            tile.background
            ArabicGlyph(text: letter, size: fontSize)
                .foregroundStyle(tile.ink.opacity(0.9))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .accessibilityHidden(true)
    }
}

extension Reciter {
    /// First letter of the Arabic name, falling back to the English one.
    var initial: String { String((arabicName.first ?? name.first) ?? " ") }

    /// The family name for tight spots, like the design's "Al-Husary":
    /// the last word, with a leading "Al" or "Abdul" kept.
    var shortName: String {
        let words = name.split(separator: " ")
        guard words.count > 1 else { return name }
        let keep = ["Al", "Abdul", "El"].contains(words[words.count - 2]) ? 2 : 1
        return keep < words.count ? words.suffix(keep).joined(separator: " ") : name
    }
}

/// The surah number on the muṣḥaf ornament surface.
struct NumberTile: View {
    let number: Int32
    var size: CGFloat = 28
    var fontSize: CGFloat = 13
    var radius: CGFloat = 7

    var body: some View {
        ArabicGlyph(text: arabicIndic(number), size: fontSize)
            .foregroundStyle(Theme.ornamentBorder)
            .frame(width: size, height: size)
            .background(Theme.ornamentSurface, in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Theme.hairline, lineWidth: 0.5))
            .accessibilityHidden(true)
    }
}

/// The large ornament tile heading an edition or a collection.
struct OrnamentTile<Content: View>: View {
    var surface = Theme.ornamentSurface
    var ink = Theme.ornamentBorder
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .bottom) {
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(spacing: 4) {
                Rectangle().frame(height: 1).opacity(0.4)
                Circle().frame(width: 4, height: 4).opacity(0.5)
                Rectangle().frame(height: 1).opacity(0.4)
            }
            .foregroundStyle(ink)
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .frame(width: 148, height: 148)
        .background(surface)
        .card(radius: 14)
        .accessibilityHidden(true)
    }
}

// MARK: - Controls

/// The design's capsule actions: accent for the primary one, card for the rest.
/// Liquid Glass buttons on macOS 26; the design's flat capsules below it.
struct PillButton: View {
    let title: String
    let symbol: String?
    var isPrimary = false
    let action: () -> Void
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        if #available(macOS 26, *) {
            let button = Button(action: action) { label.padding(.horizontal, 3) }
                .controlSize(.large)
                .buttonBorderShape(.capsule)
            // Clear glass stays neutral; only the primary action takes the accent.
            if isPrimary { button.buttonStyle(.glassProminent) } else { button.buttonStyle(.glass).tint(nil) }
        } else {
            Button(action: action) {
                label
                    .foregroundStyle(isPrimary ? Color.white : Color.primary)
                    .padding(.leading, symbol == nil ? 14 : 13)
                    .padding(.trailing, 15)
                    .frame(height: 30)
                    .background {
                        if isPrimary {
                            Capsule().fill(accent).shadow(color: accent.opacity(0.35), radius: 4, y: 2)
                        } else {
                            Capsule().fill(Theme.card).overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 0.5))
                                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                        }
                    }
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var label: some View {
        HStack(spacing: 7) {
            if let symbol { Image(systemName: symbol).font(.system(size: 11, weight: .semibold)) }
            Text(title).font(.system(size: 12, weight: isPrimary ? .semibold : .medium))
        }
    }
}

extension View {
    /// A menu or button in the same glass capsule as a secondary `PillButton`.
    @ViewBuilder
    func glassPill() -> some View {
        if #available(macOS 26, *) {
            controlSize(.large).buttonBorderShape(.capsule).buttonStyle(.glass).tint(nil)
        } else {
            buttonStyle(.bordered)
        }
    }
}

/// A status capsule: "Āyah timing verified", the player's ayah position.
struct CapsuleTag: View {
    let title: String
    var symbol: String? = nil
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        HStack(spacing: 5) {
            if let symbol { Image(systemName: symbol).font(.system(size: 9, weight: .semibold)) }
            Text(title).font(.system(size: 10, weight: .semibold).monospacedDigit())
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 9)
        .frame(height: 24)
        .background(accent.opacity(0.12), in: Capsule())
        .overlay(Capsule().strokeBorder(accent.opacity(0.35), lineWidth: 0.5))
    }
}

/// A small tag: Verse Sync, Featured, Full Audio.
struct Tag: View {
    let title: String
    var symbol: String? = nil
    var tint: Color? = nil
    var fill: Color? = nil
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        HStack(spacing: 3) {
            if let symbol { Image(systemName: symbol).font(.system(size: 8, weight: .semibold)) }
            Text(title).font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(tint ?? accent)
        .padding(.horizontal, 5)
        .padding(.vertical, 1)
        .background(fill ?? accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
    }
}

/// Section title with a quiet count beside it.
struct SectionHeading: View {
    let title: String
    var detail: String? = nil
    var size: CGFloat = 20

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: size > 16 ? 10 : 8) {
            Text(title).font(.system(size: size, weight: .semibold))
            if let detail {
                Text(detail).font(.system(size: 12)).foregroundStyle(Theme.labelSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// Three little bars marking the row that is playing.
struct PlayingBars: View {
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach([6.0, 11, 8], id: \.self) { height in
                RoundedRectangle(cornerRadius: 1).frame(width: 2, height: height)
            }
        }
        .foregroundStyle(accent)
        .frame(height: 12)
        .accessibilityLabel("Current surah")
    }
}

/// A thin progress track.
struct ProgressTrack: View {
    let fraction: Double
    var height: CGFloat = 3
    @Environment(\.tilawaAccent) private var accent

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.segment)
                Capsule().fill(accent).frame(width: geo.size.width * min(max(fraction, 0), 1))
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }
}

/// Loading, empty, no-results and failure states, centered in the content area.
struct StateMessage: View {
    let symbol: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(Theme.labelSecondary)
                .frame(width: 40, height: 40)
                .background(Theme.segment, in: Circle())
            Text(title).font(.system(size: 14, weight: .semibold))
            if let message {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.labelSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            if let actionTitle, let action {
                PillButton(title: actionTitle, symbol: nil, isPrimary: true, action: action).padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
