# Tilawa application stack

Status: authoritative target architecture. Updated 2026-09-13.

This document is the only technical architecture source of truth for Tilawa. Product behavior and features are defined in [PRODUCT.md](../PRODUCT.md).

## Architecture decision

Tilawa uses a Kotlin Multiplatform shared core and five platform-native application shells.

```text
Kotlin Multiplatform shared core
├── Android: Kotlin/JVM API → Kotlin + Jetpack Compose
├── iOS: Kotlin/Native XCFramework → SKIE Swift overlay → Swift + SwiftUI
├── macOS: Kotlin/Native XCFramework → SKIE Swift overlay → Swift + SwiftUI
├── Windows: Kotlin/Native DLL → kotlin-native-nuget → C# + WinUI 3
└── Linux: Kotlin/Native .so → kotlin-native-nuget → C# host
                                      └── Gir.Core → GTK 4 + libadwaita
```

The governing boundary is:

> Share product logic and portable infrastructure. Implement UI, navigation, media playback, lifecycle, background execution and operating-system integration natively in each platform shell.

### Supported targets

| Platform | Required target | Explicitly unsupported |
|---|---|---|
| Android | Kotlin/JVM Android target | — |
| iOS | `iosArm64`, `iosSimulatorArm64` | Intel simulator support unless later required |
| macOS | `macosArm64` | `macosX64` |
| Windows | `mingwX64` / `win-x64` | Windows ARM and x86 |
| Linux | `linuxX64` / `linux-x64` | Other architectures until a product requirement and CI exist |

No Windows ARM artifact will be advertised or packaged. No Intel macOS artifact will be built or advertised.

## macOS as the canonical application

The macOS application is the product baseline. It defines:

- Features and their intended behavior.
- Information hierarchy and user flow.
- Content, labels and terminology.
- Domain state and state transitions.
- Design tokens and brand character.
- Loading, empty, offline, unavailable and error behavior.
- Accessibility intent.

Every accepted macOS product change must be assessed for Android, iOS, Windows and Linux and then reflected in those applications. This is functional parity, not pixel parity.

Each platform must use its recommended native component for the same job. A macOS sidebar may become an Android adaptive navigation surface, an iOS `NavigationSplitView`, a Windows `NavigationView`, or a libadwaita navigation split view. The content and behavior stay equivalent while layout, interaction, menus, shortcuts, animation and window behavior follow the host platform.

Before planning unfamiliar native functionality, verify the current official platform documentation and human-interface guidance. Record the source in the implementation plan or pull request rather than guessing from another platform.

## Shared-core responsibilities

The KMP shared module owns logic that must behave identically everywhere:

- Reciter, riwayah, recording edition, surah, verse and timing models.
- Catalog retrieval and mapping.
- Recording identity and text/audio/timing compatibility rules.
- Featured-reciter ordering rules.
- Playback-track and queue policy, but not the audio engine.
- Pure position-to-ayah resolution using the native player's reported position.
- Download metadata, desired state and reconciliation policy, but not OS background execution.
- Favorites, bookmarks, listening progress and history when those features are introduced.
- Networking and serialization where a portable implementation is sufficient.
- Portable validation, errors and cancellation semantics.
- Pure business-use cases and their tests.

The shared module must not own:

- Views, UI components, navigation stacks or window management.
- Platform view models whose purpose is binding to a native UI toolkit.
- Audio decoding, audio focus, interruptions or media sessions.
- Lock-screen, notification, taskbar, menu-bar or desktop media controls.
- Platform background services or transfer schedulers.
- Platform filesystem locations, permissions, package identity or distribution.
- Platform-specific accessibility implementation.

The exported shared API stays intentionally small. Only stable product-facing types and operations are public. Internal repositories, transport DTOs and implementation details are not exported merely because a generator can expose them.

## Dependency policy

Use this order for every dependency decision:

1. Kotlin or platform standard library.
2. Official native platform API or component.
3. A dependency already used by Tilawa.
4. A maintained, widely adopted library that solves a demonstrated requirement.

Popular KMP libraries may be added when needed and when all required targets are verified. Expected foundations include Kotlin coroutines and Flow, kotlinx.serialization, kotlinx-datetime, Ktor, Multiplatform Settings and Kermit. A database, dependency-injection framework, navigation framework or caching framework is not required until a real feature needs it.

Native libraries may be added under the same rule. Check maintenance, license, target support, packaging impact and compatibility first. Do not add two libraries that solve the same bridge or lifecycle problem.

Compiler plugins and interop generators must be version-pinned. Upgrade their compatible toolchain as a unit, never independently.

## Platform stacks

### Android

| Concern | Decision |
|---|---|
| Language | Kotlin |
| Shared integration | Direct Kotlin/JVM dependency on the shared module |
| UI | Jetpack Compose with Material 3 and adaptive layouts |
| Navigation | Current official Navigation Compose APIs and adaptive navigation components |
| State/lifecycle | Android lifecycle APIs, ViewModel and lifecycle-aware Flow collection |
| Media | AndroidX Media3 ExoPlayer with a `MediaSessionService` |
| Downloads | Media3 `DownloadService` for media; WorkManager only for appropriate deferrable work |
| Images | Platform-supported loading; Coil only when remote-image caching is actually needed |
| Distribution | Android App Bundle through Google Play-compatible tooling |

The application must handle audio focus, interruptions, media notification controls, Bluetooth/headset actions, process recreation and adaptive window sizes according to Android guidance.

Primary references: [Jetpack Compose](https://developer.android.com/develop/ui/compose), [adaptive layouts](https://developer.android.com/develop/ui/compose/layouts/adaptive), [Media3 background playback](https://developer.android.com/media/media3/session/background-playback), [Media3 downloads](https://developer.android.com/media/media3/exoplayer/downloading-media).

### iOS

| Concern | Decision |
|---|---|
| Language | Swift |
| Shared integration | Kotlin/Native XCFramework enhanced by SKIE |
| UI | SwiftUI, with UIKit only when it provides a required system capability |
| Navigation | `NavigationStack` and `NavigationSplitView` as appropriate for the device class |
| State/lifecycle | Swift Observation and structured concurrency around the SKIE-exposed API |
| Media | AVFoundation `AVPlayer`; `AVQueuePlayer` only when a real multi-track queue requires it |
| System playback | `AVAudioSession`, Now Playing information and remote commands |
| Downloads | Background `URLSession`, with app-owned file validation and metadata |
| Distribution | Signed App Store archive |

SKIE is the selected Swift interop layer. It augments the Objective-C-compatible Kotlin framework with a Swift overlay for better Swift-facing types, coroutine APIs and Flow consumption. Kotlin Swift Export is not used alongside it.

Primary references: [SKIE](https://skie.touchlab.co/intro), [SwiftUI navigation](https://developer.apple.com/documentation/swiftui/navigation), [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer), [background downloads](https://developer.apple.com/documentation/foundation/downloading-files-in-the-background).

### macOS

| Concern | Decision |
|---|---|
| Language | Swift |
| Shared integration | `macosArm64` Kotlin/Native XCFramework enhanced by SKIE |
| UI | SwiftUI, with AppKit for capabilities not adequately exposed by SwiftUI |
| Navigation | Native macOS split views, sidebars, commands and window behavior |
| State/lifecycle | Swift Observation and structured concurrency around the SKIE-exposed API |
| Media | AVFoundation `AVPlayer` owned at application level |
| System playback | Now Playing, remote commands, media keys and interruption handling |
| Downloads | Background `URLSession`, app-support storage and atomic file replacement |
| Distribution | Signed and notarized macOS application for Apple Silicon |

The macOS application remains the canonical product implementation, but it must still follow current macOS guidance rather than introducing custom controls where native ones already fit.

Primary references: [macOS design guidance](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos), [SwiftUI](https://developer.apple.com/xcode/swiftui/), [AVFoundation](https://developer.apple.com/av-foundation/).

### Windows

| Concern | Decision |
|---|---|
| Language | C# on .NET |
| Shared integration | `mingwX64` Kotlin/Native DLL packaged by `kotlin-native-nuget` with generated C# bindings |
| UI | WinUI 3 and Windows App SDK |
| Navigation | `NavigationView`, `Frame` and native window patterns |
| State/lifecycle | .NET async/cancellation and WinUI binding patterns |
| Media | `Windows.Media.Playback.MediaPlayer` and `MediaPlaybackList` when a queue is required |
| System playback | System Media Transport Controls |
| Downloads | Windows Background Transfer when work must survive suspension; `HttpClient` otherwise |
| Distribution | Signed x64 MSIX package |

The generated NuGet package is the C# entry point to the shared core. Kotlin suspend functions, Flow/state and disposable Kotlin objects must be consumed through the generator's supported mappings and .NET lifecycle patterns. Generated bindings are checked into or retained as a build artifact for review, and `Interop.cs` is diffed on every generator upgrade.

Primary references: [kotlin-native-nuget](https://github.com/xxfast/kotlin-native-nuget), [WinUI 3](https://learn.microsoft.com/en-us/windows/apps/winui/winui3/), [Windows media playback](https://learn.microsoft.com/en-us/windows/apps/develop/media-playback/media-playback), [Background Transfer](https://learn.microsoft.com/en-us/windows/apps/develop/networking/background-transfers).

### Linux

| Concern | Decision |
|---|---|
| Language | C# on .NET |
| Shared integration | `linuxX64` Kotlin/Native `.so` packaged by `kotlin-native-nuget` with generated C# bindings |
| Native bindings | Gir.Core packages for GTK, Adwaita, GStreamer, Gio and related GNOME libraries |
| UI | GTK 4 and libadwaita, following the GNOME HIG |
| Navigation | libadwaita adaptive navigation and split-view components |
| State/lifecycle | .NET async/cancellation coordinated with the GLib main context |
| Media | GStreamer through Gir.Core |
| System playback | MPRIS over D-Bus/Gio |
| Downloads | .NET `HttpClient`, resumable requests where supported and atomic file replacement |
| Distribution | x64 Flatpak as the primary package |

The Linux C# host has two independent dependency paths:

- The Tilawa shared-core NuGet supplies generated C# bindings and the Kotlin/Native `.so` runtime asset.
- Gir.Core supplies C# bindings for GTK 4, libadwaita, GStreamer and other GObject libraries.

Gir.Core does not package Tilawa's Kotlin core, and `kotlin-native-nuget` does not provide GNOME UI bindings. The Flatpak/runtime must provide the required native GTK, libadwaita and GStreamer libraries.

Primary references: [Gir.Core](https://github.com/gircore/gir.core), [libadwaita](https://gnome.pages.gitlab.gnome.org/libadwaita/), [GNOME HIG](https://developer.gnome.org/hig/), [MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/).

## Interop rules

### Apple

- Export a narrow Objective-C-compatible framework surface.
- Use SKIE for the Swift overlay and Flow/coroutine ergonomics.
- Prefer immutable values and explicit cancellation/lifecycle ownership.
- Keep UI-specific Swift models in the Swift application when they do not belong to shared product logic.
- Pin SKIE and Kotlin to a documented compatible pair.

### Windows and Linux

- Publish the shared core as a RID-aware NuGet package using `kotlin-native-nuget`.
- Include only the public packages intended for native applications.
- Prefer bridge-supported primitives, values, collections, suspend functions and flows.
- Dispose generated wrapper objects deterministically where required.
- Propagate cancellation, failures and nullability without converting them to empty success values.
- Pin the plugin and diff generated bindings during upgrades.
- Run generated-binding smoke tests on both Windows and Linux.

`kotlin-native-nuget` is currently pre-1.0. Its Windows x64 target is exercised upstream; its Linux targets are mapped but are not exercised in upstream CI. Tilawa therefore requires its own Linux integration test and release gate. Gir.Core is also pre-1.0, so its version is pinned and upgrades require a native UI/media smoke test.

The initial shared toolchain must use the intersection supported by SKIE and `kotlin-native-nuget`. As of this decision, that intersection is Kotlin 2.4.10. Re-check both compatibility tables before any upgrade.

References: [NuGet compatibility and targets](https://github.com/xxfast/kotlin-native-nuget/blob/main/docs/topics/prerequisites.md), [SKIE compatibility](https://skie.touchlab.co/intro), [Kotlin/Native target support](https://kotlinlang.org/docs/native-target-support.html).

## Native implementation rule

For every platform-specific feature:

1. Start from the equivalent macOS product behavior.
2. Read the current official platform documentation and design guidance.
3. Select the platform's recommended component or service.
4. Define only the minimal shared contract needed by product logic.
5. Implement the behavior in the native shell.
6. Verify lifecycle, cancellation, offline behavior, accessibility and system integration on that platform.

Examples:

| Product behavior | Shared core owns | Native application owns |
|---|---|---|
| Play a surah | Recording identity, URL/local reference, queue policy and timing data | Decoder, player, audio focus, media session and actual playback state |
| Highlight an ayah | Pure mapping from media position to a validated timing segment | Position observation, rendering, scrolling and animation |
| Download a surah | Download identity, requested state and metadata rules | Background transfer, file destination, permissions and OS scheduling |
| Navigate reciter → edition → reader | Available entities and selection state | Navigation container, transitions, restoration and window/device adaptation |
| Display an error | Stable error meaning and retry eligibility | Native message, alert, inline state and accessibility announcement |

## Persistence and content

Use plain files plus Multiplatform Settings for v1 downloads and small preferences. Add a database only when a concrete relational or indexed-search requirement appears and only after its Windows and Linux native targets pass build and runtime validation.

Store enough durable metadata to reopen downloaded audio after restart. Resolve verified local files before requiring the network. Write downloads to a temporary file, validate completion, then atomically replace the final file. Reconcile missing, partial and corrupt files at startup.

Content packages must record source, edition, riwayah/layout compatibility, revision, checksum, license and notices. Audio timing must identify the exact recording revision it describes.

## Testing and CI

Use native CI hosts and do not treat compilation on one host as five-platform proof.

| CI lane | Required checks |
|---|---|
| Shared | Common unit tests, API compatibility and content/timing validation |
| Android | JVM/unit tests, Compose UI smoke test and Media3 lifecycle test |
| iOS | XCFramework/SKIE build, Swift compile and simulator flow test |
| macOS ARM64 | XCFramework/SKIE build, Swift build, product-flow test and packaging smoke test |
| Windows x64 | Native core/NuGet generation, WinUI build, generated-binding lifecycle test and MSIX smoke test |
| Linux x64 | Native core/NuGet generation, Gir.Core app build, GTK/GStreamer integration test and Flatpak smoke test |

The minimum cross-platform acceptance slice is one reciter, two surahs, streaming, download, offline restart, timed and untimed playback, native play/pause controls, cancellation and one visible failure/retry path.

## Version 1 technical implementation plan

### Planning rules

- Deliver one complete user journey before widening catalog or feature scope.
- Reuse the existing shared models, repository, tests and macOS screens where they satisfy this document.
- Replace target-incompatible code directly; do not preserve two bridge or shell implementations.
- Keep each native player inside its application. Share inputs, timing rules and durable metadata, not a universal player abstraction.
- Add no database, backend, dependency-injection framework or shared navigation framework in v1.
- Do not implement anything from `PRODUCT.md`'s later-feature list.
- Do not leave inactive future controls in a v1 interface.

### Current implementation baseline

| Area | Starting point | V1 gap |
|---|---|---|
| Shared core | Reciters, editions, chapters, bundled verses, MP3Quran client, playback track, timing DTOs and download-state implementations exist | Durable default storage, content identity, timing validation, local-first behavior, explicit failures and cancellation |
| macOS | Reciter library, edition selection, reader, AVPlayer wrapper, timing-aware/plain scrubbers and foreground download exist | App-owned player, observed engine state, persistent offline restart, request cancellation, content/font validation and accessibility pass |
| Android | Compose template consumes shared Kotlin directly | Entire v1 product slice and Media3 integration |
| iOS | SwiftUI template consumes the Kotlin framework | SKIE and the entire v1 product slice |
| Windows | WinUI shell exists | NuGet-generated shared API, x64-only configuration and the entire v1 product slice |
| Linux | Shell directory exists | C#/.NET Gir.Core application, generated shared-core NuGet integration and the entire v1 product slice |
| Delivery | Local shared/macOS builds are available | Native-host CI, packaging, clean-install and parity evidence |

### Phase dependency

```text
T0 Interop and toolchain proof
└── T1 Shared v1 contract and correctness
    └── T2 Canonical macOS v1
        ├── T3 Android v1
        ├── T4 iOS v1
        ├── T5 Windows v1
        └── T6 Linux v1
            └── T7 Parity and release validation
```

T3–T6 may proceed independently after T2 locks the behavior. They are complete only when T7 verifies the same acceptance journey on every target.

### T0 — Prove the selected toolchain and interop

Goal: make the smallest real shared API call from each selected native stack before building more UI.

Tasks:

- [x] Record a green baseline for shared tests and the current macOS build.
- [x] Align Kotlin, KSP, Gradle, SKIE and `kotlin-native-nuget` on one pinned compatibility set.
- [x] Remove the `macosX64` target and all Intel macOS packaging configuration.
- [x] Configure SKIE for `iosArm64`, `iosSimulatorArm64` and `macosArm64` frameworks.
- [x] Confirm a Swift caller can await one shared suspend operation and consume its returned models.
- [x] Configure `kotlin-native-nuget` to publish only the intended shared API for `win-x64` and `linux-x64`.
- [x] Restrict the Windows project and package output to x64.
- [x] Consume the generated core package from the existing WinUI application and call one suspend operation with cancellation and disposal.
- [x] Recreate `linuxApp` as a C#/.NET Gir.Core application using GTK 4 and libadwaita.
- [x] Consume the Linux core package and call the same suspend operation from the GLib main context.
- [x] Add minimal macOS, Windows and Linux CI lanes for framework/NuGet generation and consumer compilation.

Acceptance:

- Android calls the shared core directly.
- iOS and macOS compile against the SKIE-enhanced framework.
- Windows and Linux load the RID-specific native asset from the generated NuGet package.
- One reciter-loading call succeeds on all five targets.
- Cancellation and generated-object disposal are exercised on Windows and Linux.
- No unsupported Windows or macOS architecture appears in build or package metadata.

Stop condition: do not begin full Windows or Linux UI work until their generated bindings run on the real target OS.

Status: implementation and local compilation are complete; T0 acceptance remains gated on the Windows and Linux CI lanes proving native loading, the reciter call, cancellation and disposal on their real target OS.

### T1 — Stabilize the shared v1 contract

Goal: give every application one reliable, narrow product API.

Tasks:

- [x] Keep `QuranLibrary` as the single exported composition root.
- [x] Export only reciters, editions, chapters, verses, playback-track data, timing resolution and download metadata required by v1.
- [x] Add explicit recording identity: provider, edition, reciter, riwayah, style and recording revision.
- [x] Add a bundled-content manifest containing text edition, source, revision, checksum, license and notices.
- [x] Enforce text/audio/timing compatibility before producing a readable playback track.
- [x] Return a clearly identified audio-only result when the recording has no compatible bundled text.
- [x] Validate requested surahs against the selected edition before constructing an audio URL.
- [x] Resolve a verified downloaded path before catalog or timing network work.
- [x] Make persistent settings the production default; retain the in-memory store only for tests.
- [x] Add failed download state and enough metadata to reconcile missing, partial and corrupt files.
- [x] Add one pure timing resolver with `[start, end)` boundaries, unlabeled regions and repeated occurrences.
- [x] Preserve coroutine cancellation instead of catching it as a normal failure.
- [x] Distinguish successful empty results from retryable transport failures.
- [x] Cache only successful catalog responses and add explicit request timeouts/status validation.
- [x] Keep timing failure degradable to an untimed playback track.

Smallest required tests:

- [x] Compatible and incompatible text/recording combinations.
- [x] Available and unavailable surah selection.
- [x] Local-first playback with the network unavailable.
- [x] Failed first catalog request followed by successful retry.
- [x] Cancellation is not cached as empty data.
- [x] Timing intro, exact boundary, gap, final boundary, missing timing and repeated occurrence.
- [x] Download metadata survives a new shared-store instance and reconciles a missing file.
- [x] Generated Apple and C# consumers compile against the final exported API.

Acceptance: a platform can implement the complete v1 flow without reaching into shared internals or reproducing a domain rule.

Status: complete. The bundled text remains deliberately audio-only until P0 confirms its exact upstream QUL resource and license; its current bytes and SHA-256 checksum are recorded without claiming unverified provenance.

### T2 — Finish the canonical macOS v1 slice

Goal: turn the existing macOS proof of concept into the behavioral reference for every other application.

Tasks:

- [ ] Move `AVPlayer` ownership to an application-level playback controller so playback survives navigation.
- [ ] Observe `AVPlayerItem.status`, `AVPlayer.timeControlStatus`, duration, buffering, end and failure instead of inferring state from commands.
- [ ] Cancel or generation-guard overlapping reciter, edition and surah loads.
- [ ] Continue only through surahs available in the selected edition.
- [ ] Use the shared timing resolver and leave intro/gap regions unhighlighted.
- [ ] Use persistent download metadata and a background `URLSession` configuration.
- [ ] Write to a temporary file, validate the response/file, then atomically install it.
- [ ] Reconcile downloads at launch and prove offline playback after restart.
- [ ] Add Now Playing metadata, remote commands, media-key behavior and interruption handling.
- [ ] Bundle and verify the selected Quran font.
- [ ] Implement loading, buffering, offline, unavailable, error and retry states from `PRODUCT.md`.
- [ ] Remove favorite, shuffle, repeat or other later-feature controls until their features are implemented.
- [ ] Add keyboard navigation, focus labels, VoiceOver labels and scalable interface text.
- [ ] Preserve the existing reciter → edition → reader information architecture and visual tokens.

Acceptance: the complete `PRODUCT.md` v1 acceptance journey passes on macOS ARM64 and becomes the reference recording/screenshots for T3–T6.

### T3 — Implement Android v1

Goal: reproduce the canonical behavior with Android-native Compose and Media3 patterns.

Tasks:

- [ ] Replace the template UI with reciter library, edition selection and reader/player destinations.
- [ ] Use Material 3 adaptive layouts: phone navigation on compact widths and list/detail or supporting panes when space permits.
- [ ] Use Android ViewModel and lifecycle-aware Flow collection around the direct shared API.
- [ ] Implement application-level playback in a Media3 `MediaSessionService` with ExoPlayer.
- [ ] Connect the UI through a media controller rather than owning ExoPlayer in a composable.
- [ ] Provide media notification, audio focus, noisy-route/headset handling and system transport controls.
- [ ] Use Media3 downloads for offline audio and register verified results with the shared core.
- [ ] Render bundled Quran text with correct RTL, Arabic shaping, font and native accessibility semantics.
- [ ] Implement timed highlighting/plain fallback and all required product states.
- [ ] Add one Compose navigation/UI journey test plus one service/download lifecycle test.

Acceptance: the full v1 journey passes on a phone-sized emulator and one expanded-width emulator/device.

### T4 — Implement iOS v1

Goal: reproduce the canonical behavior with SwiftUI and Apple media/background APIs.

Tasks:

- [ ] Build Swift-facing adapters only where the SKIE API still needs presentation-friendly shaping.
- [ ] Replace the template with reciter library, edition selection and reader/player screens.
- [ ] Use `NavigationStack` on compact devices and `NavigationSplitView` where the device/window supports it.
- [ ] Add an application-owned AVPlayer controller with observed playback/buffering/failure state.
- [ ] Add `AVAudioSession`, Now Playing and remote-command integration.
- [ ] Use background `URLSession` for downloads and register validated files with the shared core.
- [ ] Render bundled Quran text with correct RTL, Dynamic Type and VoiceOver semantics.
- [ ] Implement timed highlighting/plain fallback and all required product states.
- [ ] Add one XCUITest for the primary journey and focused tests for player/download lifecycle.

Acceptance: the full v1 journey passes on an iPhone simulator/device and an iPad or regular-width simulator.

### T5 — Implement Windows v1

Goal: reproduce the canonical behavior with WinUI 3 and the generated shared-core NuGet API.

Tasks:

- [ ] Remove direct shared-library calls from application UI code; use the generated NuGet API through a small C# application service.
- [ ] Implement reciter library, edition selection and reader/player pages with `NavigationView`, `Frame` and adaptive WinUI layouts.
- [ ] Use `MediaPlayer` as an application-owned service and `MediaPlaybackList` only if the v1 chapter-continuation behavior requires it.
- [ ] Integrate System Media Transport Controls and observed buffering/failure state.
- [ ] Use Background Transfer for durable downloads and register verified files with the shared core.
- [ ] Handle generated wrapper disposal and cancellation deterministically.
- [ ] Render bundled Quran text with correct flow direction, font, keyboard navigation and Narrator semantics.
- [ ] Implement timed highlighting/plain fallback and all required product states.
- [ ] Produce and clean-install a signed-development x64 MSIX package.

Acceptance: the full v1 journey passes on a clean Windows x64 environment from the installed MSIX package.

### T6 — Implement Linux v1

Goal: reproduce the canonical behavior with C#, Gir.Core, GTK 4 and libadwaita.

Tasks:

- [ ] Use one C#/.NET application project referencing the Tilawa core package and required Gir.Core packages.
- [ ] Implement an `Adw.Application` and adaptive reciter, edition and reader/player navigation.
- [ ] Coordinate asynchronous state updates with the GLib main context.
- [ ] Implement application-owned GStreamer playback through Gir.Core.
- [ ] Export playback state and controls through MPRIS.
- [ ] Use `HttpClient` with temporary files, validation, atomic replacement and resumable range requests only when the server supports them.
- [ ] Register verified downloads with the shared core and reconcile them at launch.
- [ ] Bundle or runtime-provide the Quran font and required GTK/libadwaita/GStreamer native libraries.
- [ ] Render Quran content with correct RTL, keyboard navigation and Orca semantics.
- [ ] Implement timed highlighting/plain fallback and all required product states.
- [ ] Produce and clean-install an x64 Flatpak.

Acceptance: the full v1 journey passes from the Flatpak on a clean supported GNOME environment, including MPRIS and offline restart.

### T7 — Cross-platform parity and release validation

Goal: prove that five separately native applications ship one product.

Tasks:

- [ ] Run the `PRODUCT.md` acceptance journey on all five installed applications.
- [ ] Verify timed and untimed editions, unavailable surahs, retry, cancellation and stale-selection behavior.
- [ ] Verify download → quit → disable network → relaunch → play on every platform.
- [ ] Verify native media controls, interruption behavior and background rules on every platform.
- [ ] Verify keyboard/pointer/touch behavior and the platform screen reader.
- [ ] Verify Quran text, font, edition, checksum, license and notices in release artifacts.
- [ ] Verify that no secret or unsupported architecture is packaged.
- [ ] Record explicit parity gaps; block v1 release on any gap in the v1 feature list.
- [ ] Tag the pinned Kotlin/SKIE/NuGet/Gir.Core compatibility set used by the release.

Acceptance: all five release packages pass the same product journey on clean target environments.

## Definition of done for a feature

A feature is complete only when:

- Its product behavior is defined in `PRODUCT.md`.
- Shared logic is implemented once when the behavior is genuinely shared.
- Every supported application has the equivalent behavior or an explicitly tracked parity gap.
- Each application uses native UI and platform integration rather than imitating macOS controls.
- Cancellation, failures, offline behavior and accessibility are handled.
- The relevant native build and smallest meaningful test pass on the target OS.
