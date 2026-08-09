# Agent Instructions

## Architecture & Structure

- This is a Kotlin Multiplatform (KMP) project with five native app shells.
- `:androidApp`: Android entry point using Jetpack Compose (Gradle module).
- `:iosApp`: iOS entry point using SwiftUI (Xcode project).
- `:macosApp`: macOS shell using SwiftUI (SwiftPM executable, `swift build`/`swift run`). Consumes `:shared` via `Shared.xcframework` binaryTarget.
- `:windowsApp`: Windows shell using WinUI 3 / C# (`dotnet build` on a Windows host). Consumes `:shared` via `Shared.dll` (mingwX64) behind `Shared.cs`; csproj builds the DLL via Gradle if missing.
- `:linuxApp`: Linux shell using GTK 4 + libadwaita / C++ (CMake + gtkmm-4.0). Consumes `:shared` via `libShared.so` (linuxX64) C ABI; CMake builds it via Gradle if missing.
- `:shared`: KMP library module containing shared logic for Android, iOS, macOS, Linux, and Windows targets. C-export façade (`shared_*` symbols) lives in `mingwX64Main`/`linuxX64Main`; after changing exports run `scripts/abi-export.sh` and keep `abi/` snapshots green via `scripts/abi-check.sh`.
- Shell wiring conventions follow `.agents/skills/{kmp-apple-bridge,kmp-windows-bridge,kmp-linux-bridge}`.
