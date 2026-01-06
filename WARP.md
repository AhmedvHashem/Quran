# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Multi-platform Quran reader application with native macOS (SwiftUI) and Windows (WinUI 3) clients. Both applications use the Quran.com API v4 (`https://api.quran.com/api/v4`) and follow MVVM architecture.

## Build Commands

### macOS (QuranMac)
```bash
# Build
cd QuranMac && swift build

# Run
cd QuranMac && swift run

# Release build
cd QuranMac && swift build -c release
```

### Windows (QuranWindows)
```pwsh
# Restore dependencies
cd QuranWindows && dotnet restore

# Build
cd QuranWindows && dotnet build

# Run
cd QuranWindows && dotnet run

# Publish for specific platform
cd QuranWindows && dotnet publish -p:PublishProfile=win-x64
```

## Architecture

### MVVM Pattern
Both applications follow Model-View-ViewModel architecture with identical responsibilities but platform-specific implementations:

**Data Flow:** API → `QuranService` (singleton) → ViewModel (ObservableObject) → Views

### Core Components

#### Services Layer
- **QuranService**: Singleton handling all API interactions
  - macOS: `QuranMac/Sources/QuranMac/Services/QuranService.swift`
  - Windows: `QuranWindows/QuranWindows/Services/QuranService.cs`
  - Methods: `fetchChapters()`, `fetchVerses(chapterId:)`, `fetchReciters()`, `fetchChapterAudio(reciterId:chapterId:)`

- **AudioPlayer**: Media playback wrapper with state management
  - macOS: Uses `AVPlayer` with Combine publishers
  - Windows: Uses `MediaPlayer` with `INotifyPropertyChanged`

#### ViewModels
- **macOS**: `ContentViewModel` (`@MainActor` + `ObservableObject`)
  - Uses `@Published` properties and Combine
  - Auto-loads verses when `selectedChapter` changes via `didSet`
  
- **Windows**: `MainViewModel` (`CommunityToolkit.Mvvm`)
  - Uses `[ObservableProperty]` and `[RelayCommand]` attributes
  - Uses `OnSelectedChapterChanged()` partial method for reactive changes

#### Models
All models are `Codable` (Swift) or JSON-serializable (C#) with snake_case API mapping:
- Core: `Chapter`, `Verse`, `Reciter`, `AudioFile`
- Response wrappers: `ChaptersResponse`, `VersesResponse`, `RecitationsResponse`, `ChapterRecitationResponse`

### View Structure

**macOS (SwiftUI):**
- `ContentView` → `NavigationView` containing:
  - `SidebarView`: Chapter list with Arabic names
  - `ReadingView`: Verses in Uthmani script
  - `PlayerView`: Audio controls with reciter picker

**Windows (WinUI 3):**
- `MainWindow.xaml` → `NavigationView` with:
  - Chapter list in navigation pane
  - `ReadingView`: ListView for verses
  - `PlayerView`: Bottom bar for audio controls
- Custom converters in `Converters/` for XAML bindings

## Platform-Specific Details

### macOS
- **Requirements**: macOS 12+, Swift 5.5+
- **Package Manager**: Swift Package Manager (no external dependencies)
- **Project Structure**: `Sources/QuranMac/` with Models, Services, ViewModels, Views subdirectories
- **State Management**: Combine framework with `@Published` properties

### Windows
- **Requirements**: .NET 8, Windows 10 19041+
- **Dependencies**: 
  - `CommunityToolkit.Mvvm` (8.4.0) - MVVM helpers
  - `Newtonsoft.Json` (13.0.4) - JSON serialization
  - `Microsoft.WindowsAppSDK` (1.8.x)
- **Publish Profiles**: Available for win-x86, win-x64, win-arm64 in `Properties/PublishProfiles/`
- **Build Features**: Trimming and R2R compilation enabled for Release builds

## API Integration

All network calls use async/await and target Quran.com API v4:
- **Base URL**: `https://api.quran.com/api/v4`
- **No authentication required** - API is public
- **Pagination**: Currently uses `per_page=300` for verses (may not handle full pagination for longer chapters)
- **Default Reciter**: Mishari Alafasy (ID: 7)

## Development Conventions

### Code Style
- **Swift**: CamelCase for types/properties, lowercase for function names
- **C#**: PascalCase for public members, camelCase/underscore for private fields
- Both platforms use modern async/await patterns

### State Management Patterns
- **macOS**: Reactive updates via Combine's `@Published` and property observers (`didSet`)
- **Windows**: Source generators via `[ObservableProperty]` and partial methods for change handling

### Adding New Features
When adding features that span both platforms:
1. Implement the Swift version first in the appropriate layer (Model/Service/ViewModel/View)
2. Mirror the implementation in C# with platform-appropriate idioms
3. Maintain API parity between platforms - both should have equivalent capabilities
