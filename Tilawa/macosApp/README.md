# Tilawa macOS App

The macOS native shell for Tilawa, built with **SwiftUI** using Swift Package Manager (`Package.swift`). Consumes the KMP `:shared` core via `Shared.xcframework`.

## Prerequisites

- **OS**: macOS (v13 Ventura or higher)
- **Toolchain**: Swift 5.9+ / Xcode Command Line Tools
- **JDK**: Java 17 or higher (for building the `:shared` framework)

---

## Building and Running

### 1. Build the Shared Framework (XCFramework)
Generate the shared `Shared.xcframework` binary:
```bash
./gradlew :shared:assembleSharedXCFramework
```

### 2. Build the macOS Executable
```bash
cd macosApp
swift build
```

### 3. Run the macOS App
```bash
cd macosApp
swift run
```
