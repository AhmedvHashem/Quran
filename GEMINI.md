# GEMINI.md

This file serves as a context guide for this project, detailing its structure, build instructions, and architectural conventions.

## Project Overview

This is a multi-platform Quran reader application repository containing native clients for macOS and Windows. Both applications fetch data from the [Quran.com API (v4)](https://api.quran.com/v4) and provide reading and audio playback capabilities.

### Sub-projects

*   **QuranMac:** A macOS application built with SwiftUI and Swift Package Manager.
*   **QuranWindows:** A Windows application built with WinUI 3 and .NET 8.
*   **QuranAPI:** (Currently empty) Planned shared API module.

## Architecture & Design Pattern

Both applications follow the **MVVM (Model-View-ViewModel)** architectural pattern to separate UI logic from business logic and data access.

### 1. Data Layer (Models & Services)
*   **API:** All data is sourced from `api.quran.com/api/v4`.
*   **Models:**
    *   Shared concepts: `Chapter`, `Verse`, `Reciter`, `AudioFile`.
    *   **macOS:** Swift `Codable` structs with `CodingKeys` for snake_case handling.
    *   **Windows:** C# classes using `Newtonsoft.Json` attributes (`[JsonProperty]`).
*   **Services:**
    *   `QuranService`: A singleton service responsible for fetching chapters, verses, reciters, and audio URLs.
    *   `AudioPlayer`: Manages media playback (AVPlayer on macOS, MediaPlayer on Windows) and publishes playback state (playing/paused, current track info).

### 2. ViewModels
*   **Role:** Manages the application state, including the list of chapters, the selected chapter/reciter, and loading/error states.
*   **macOS:** `ContentViewModel` (ObservableObject, @MainActor).
*   **Windows:** `MainViewModel` (ObservableObject from `CommunityToolkit.Mvvm`).

### 3. Views (UI)
*   **macOS (SwiftUI):**
    *   `SidebarView`: List of chapters.
    *   `ReadingView`: Main content area for verses.
    *   `PlayerView`: Bottom bar for audio controls.
*   **Windows (WinUI 3):**
    *   `MainWindow`: Uses `NavigationView` for the main layout.
    *   `ReadingView`: Displays verses using `ListView`.
    *   `PlayerView`: Manages audio controls.

## Building and Running

### macOS (QuranMac)
**Prerequisites:** Xcode, Swift 5.5+

```bash
# Build
cd QuranMac
swift build

# Run
swift run

# Release Build
swift build -c release
```

### Windows (QuranWindows)
**Prerequisites:** .NET 8 SDK, Visual Studio 2022 (with Windows App SDK workload)

```bash
# Restore dependencies (Cross-platform enabled)
cd QuranWindows
dotnet restore

# Build
dotnet build

# Run
dotnet run
```

*Note: `EnableWindowsTargeting` is set to `true` in `QuranWindows.csproj` to allow restoring packages on non-Windows systems.*

## Development Conventions

*   **State Management:**
    *   **macOS:** Uses `Combine` and `@Published` properties.
    *   **Windows:** Uses `CommunityToolkit.Mvvm` with `[ObservableProperty]` and `[RelayCommand]`.
*   **Async/Await:** Both platforms utilize modern async/await patterns for network operations.
*   **Naming:**
    *   Swift: CamelCase.
    *   C#: PascalCase for methods/properties, camelCase/underscore for fields.
