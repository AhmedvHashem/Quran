# Tilawa iOS App

The iOS native shell for Tilawa, built with **SwiftUI**. Consumes the KMP `:shared` core via Kotlin/Native Apple Framework (`Shared.xcframework`).

## Prerequisites

- **OS**: macOS
- **IDE**: Xcode 15 or higher
- **JDK**: Java 17 or higher (for building the Kotlin `:shared` core)

---

## Building and Running

### 1. Build the Shared Framework (XCFramework)
Before building the iOS app for the first time, generate the shared XCFramework:
```bash
./gradlew :shared:assembleSharedXCFramework
```

### 2. Open in Xcode
```bash
open iosApp/iosApp.xcodeproj
```
From Xcode, select an iOS Simulator (e.g. iPhone 16) or a connected iOS device, then press **Cmd + R** to build and run.

### 3. Command Line Build (iOS Simulator)
To compile the iOS app directly from the command line:
```bash
xcodebuild -project iosApp/iosApp.xcodeproj \
           -scheme iosApp \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build
```
