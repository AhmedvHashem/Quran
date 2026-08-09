# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the app
cd QuranMac && swift build

# Run the app
cd QuranMac && swift run

# Build for release
cd QuranMac && swift build -c release
```

## Architecture

This is a macOS Quran reader app built with SwiftUI and Swift Package Manager. The app fetches data from the Quran.com API (v4) and provides both reading and audio playback functionality.

### Project Structure

- **QuranMac/** - Swift Package containing the macOS app
- **QuranAPI/** - Empty directory (planned API module)

### Key Components

**Data Flow:** `QuranService` (singleton) → `ContentViewModel` (ObservableObject) → SwiftUI Views

- **QuranService** (`Services/QuranService.swift`): Singleton that handles all API calls to `api.quran.com/api/v4`. Fetches chapters, verses, reciters, and audio URLs.

- **ContentViewModel** (`ViewModels/ContentViewModel.swift`): Main `@MainActor` view model managing app state. Holds chapters list, selected chapter, verses, reciters, and loading/error states. Changing `selectedChapter` triggers automatic verse loading.

- **AudioPlayer** (`Services/AudioPlayer.swift`): AVPlayer wrapper using Combine for audio playback state. Manages play/pause/resume and tracks current reciter/chapter.

### View Hierarchy

`ContentView` → NavigationView with:
- `SidebarView` (chapter list with Arabic names)
- `ReadingView` (verse display in Uthmani script)
- `PlayerView` (bottom audio controls with reciter picker)

### API Models

All models in `Models/` are `Codable` structs with `CodingKeys` for snake_case API responses:
- `Chapter`, `Verse`, `Reciter`, `AudioFile`
- Response wrappers: `ChaptersResponse`, `VersesResponse`, `RecitationsResponse`, `ChapterRecitationResponse`

### Platform Requirements

- macOS 12+
- Swift 5.5+

---

## Tilawa (KMP shared core + multi-platform apps)

`Tilawa/` is the Kotlin Multiplatform project: `:shared` core (android, iosArm64, iosSimulatorArm64, macosArm64, mingwX64, linuxX64), `:androidApp` (Compose), `:iosApp` (SwiftUI/Xcode), `:macosApp` (SwiftUI/SwiftPM + Shared.xcframework binaryTarget), `:windowsApp` (WinUI 3/C# + Shared.dll via CoreClient P/Invoke), `:linuxApp` (GTK 4/libadwaita/C++ + libShared.so C ABI). Shells call only `Greeting` from the core — no Quran logic ported yet. C-export façade (`tilawa_*`) lives in `mingwX64Main`/`linuxX64Main`. Governing architecture: `.ai/arch/APP_STACKS_PLAN.md`.

```bash
scripts/core-build.sh           # assemble :shared for all 5 targets
scripts/package-xcframework.sh  # iOS+macOS release XCFramework
scripts/export-c-header.sh      # build mingw/linux libs, snapshot C headers to abi/
scripts/abi-check.sh            # fail on ABI drift vs abi/ snapshots (also: /abi-check)
```

opencode skills in `.opencode/skills/` (kmp-shared-core, kmp-c-abi, kmp-apple-bridge, winui-bridge, gtk-linux-bridge) hold the per-layer conventions — consult them before editing shared code or any bridge.

Verified library state (Aug 2026): Ktor 3.1.3 (okhttp/darwin/curl engines), multiplatform-settings, Kermit, kotlinx-coroutines/serialization/datetime all compile and link on all 5 targets. SQLDelight was removed — sqliter-driver has no linuxX64 variant and mingwX64 links only on Windows hosts; persistence choice is an open decision gate (likely Room KMP with bundled sqlite).
