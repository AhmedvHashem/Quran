---
name: kmp-apple-bridge
description: Consuming the KMP shared core from iOS and macOS Swift apps. Use when editing Xcode projects, Swift files importing the Shared framework, XCFramework packaging, SKIE configuration, or Swift façade code around Kotlin APIs.
---

# Apple Bridge (iOS + macOS)

Governing contract: `.ai/arch/APP_STACKS_PLAN.md`. UI is SwiftUI (UIKit/AppKit where needed); the shared core is consumed as an Apple framework — no Compose Multiplatform, no shared UI.

## Consumption route (baseline)

1. Gradle builds static frameworks (`baseName = "Shared"`, already configured for iosArm64, iosSimulatorArm64, macosArm64).
2. Xcode Run Script phase (before Compile Sources, User Script Sandboxing OFF):
   ```bash
   ./gradlew :shared:embedAndSignAppleFrameworkForXcode
   ```
3. For a distributable multi-arch binary:
   ```bash
    ./gradlew :shared:assembleSharedReleaseXCFramework
   ```
4. `import Shared` in Swift; put a small Swift façade over generated names when it improves ergonomics.

## Ergonomics: SKIE

SKIE (touchlab, Gradle plugin `co.touchlab.skie`) regenerates the Objective-C header so Swift sees real enums, sealed classes as enums, and `Flow` as AsyncSequence-friendly types. Add it when the Swift façade starts accumulating boilerplate — not before.

Swift Export (Kotlin 2.4, Alpha) maps `suspend`→`async` and `Flow`→`AsyncSequence` directly via `embedSwiftExportForXcode`. **Evaluate only** — do not adopt as baseline until it stabilizes.

## Rules

- The exported Kotlin surface stays narrow (see `kmp-shared-core`); hide anything that doesn't map cleanly behind a bridge-friendly façade.
- Package resources on the Apple side — the Kotlin binary does not carry app resources or Info.plist config.
- Lifecycle, navigation, notifications, widgets, store/billing, signing: always Swift-side.
- `Flow` collection: wrap in the Swift façade (SKIE-generated async sequence or a small `ObservableObject` adapter); cancel collection from `onDisappear` / `deinit` — no leaked Kotlin jobs.
- iOS and macOS share the framework; keep platform-specific Swift in each app target, shared Swift helpers in a small local package if duplication appears.

## Verify

Build both apps in Xcode after any shared-API change: Tilawa/iosApp and the macOS app. A green Gradle build alone does not prove the framework imports cleanly.
