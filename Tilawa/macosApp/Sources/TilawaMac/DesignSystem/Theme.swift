import SwiftUI

/// Tokens lifted verbatim from Figma `Tilawa App` (6HAE3faqlNALYfTRcvQTAM),
/// frames `26:2` (Home – Reciter Grid) and `7:2` (macOS — SwiftUI / AppKit).
///
/// ponytail: literal values, light mode only — the design has no dark variant.
/// Swap for an asset catalog when a second appearance lands.
enum Theme {
    static let accent = Color(hex: 0x007AFF)
    static let artwork = Color(hex: 0x34C759)
    static let sidebarSurface = Color(hex: 0xF1F0F4)
    static let labelSecondary = Color(hex: 0x8A8A8E)
    static let hairline = Color.black.opacity(0.14)

    static let mushafSurface = Color(hex: 0xFDFBF7)
    static let mushafText = Color(hex: 0x1A1613)
    static let ornamentSurface = Color(hex: 0xFBF6EC)
    static let ornamentBorder = Color(hex: 0xB08A3E)
    static let ornamentTitle = Color(hex: 0x6B5220)
    static let ornamentSubtitle = Color(hex: 0x8A6E33)

    static let playerSurface = Color(hex: 0xECECEC)
    static let cardSurface = Color.white

    /// The window is borderless, so the traffic lights float over our content.
    static let titleBarHeight: CGFloat = 52

    /// Falls back to the system Arabic face when Amiri Quran isn't installed.
    static func arabic(_ size: CGFloat) -> Font { .custom("Amiri Quran", size: size) }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

/// Arabic-Indic digits, for verse counts and ayah markers.
func arabicIndic(_ value: Int32) -> String {
    String(String(value).map { Character(UnicodeScalar(UInt32($0.asciiValue! - 48) + 0x0660)!) })
}

extension Double {
    /// `0:22`, or `--:--` while an item is still loading.
    var clockTime: String {
        guard isFinite, self >= 0 else { return "--:--" }
        return String(format: "%d:%02d", Int(self) / 60, Int(self) % 60)
    }
}
