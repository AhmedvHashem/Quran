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
