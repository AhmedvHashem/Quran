# Technology Stack

## macOS Application (QuranMac)
- **Language:** Swift 5.5+
- **User Interface:** SwiftUI
- **Architecture:** MVVM (Model-View-ViewModel)
- **State Management:** Combine framework with `@Published` properties.
- **Media Playback:** `AVPlayer` for audio streaming and control.
- **Networking:** `URLSession` with `Codable` for API interactions.
- **Build System:** Swift Package Manager (SPM).

## Windows Application (QuranWindows)
- **Language:** C# / .NET 8
- **User Interface:** WinUI 3 (Windows App SDK 1.4)
- **Architecture:** MVVM (Model-View-ViewModel)
- **State Management:** `CommunityToolkit.Mvvm` (using `ObservableProperty` and `RelayCommand`).
- **Media Playback:** `MediaPlayer` for audio handling.
- **Networking:** `HttpClient` with `Newtonsoft.Json` for serialization.
- **Build System:** MSBuild / NuGet.

## Shared Infrastructure
- **API Source:** Quran.com API v4 (REST).
- **Architecture Pattern:** Standardized MVVM across both platforms for logic separation.
