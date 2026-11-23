import SwiftUI

/// Tilawa › Settings (⌘,). General only for now: the design's Appearance and
/// Accent tweaks.
struct SettingsView: View {
    @AppStorage(AppearanceChoice.key) private var appearance = AppearanceChoice.system
    @AppStorage(AccentChoice.key) private var accent = AccentChoice.system

    var body: some View {
        TabView {
            Form {
                Picker("Appearance", selection: $appearance) {
                    ForEach(AppearanceChoice.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                .pickerStyle(.segmented)

                LabeledContent("Accent color") {
                    HStack(spacing: 16) {
                        ForEach(AccentChoice.allCases, id: \.self) { choice in
                            AccentSwatch(choice: choice, isSelected: accent == choice) { accent = choice }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("General", systemImage: "gearshape") }
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .tint(accent.color)
        .preferredColorScheme(appearance.colorScheme)
    }
}

/// One accent choice as a colored dot with its name, like System Settings.
private struct AccentSwatch: View {
    let choice: AccentChoice
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            VStack(spacing: 5) {
                Circle()
                    .fill(choice.color)
                    .frame(width: 18, height: 18)
                    .overlay {
                        if isSelected { Circle().fill(.white).frame(width: 6, height: 6) }
                    }
                    .padding(3)
                    .overlay(Circle().strokeBorder(isSelected ? choice.color : .clear, lineWidth: 1.5))
                Text(choice.title)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(choice.title) accent")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
