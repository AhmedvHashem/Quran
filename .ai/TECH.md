# Tilawa application stack

Status: authoritative target architecture. Updated 2026-11-23.

This document is the only technical architecture source of truth for Tilawa. Product behavior and features are defined in [PRODUCT.md](PRODUCT.md).

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

### Current implementation focus

- Build the audio player first: native playback engines, the persistent player bar, lifecycle, system media controls and continuous surah navigation.
- Build history and collections on the durable library store, proved on all five targets.
- Defer downloads, the reader and ayah bookmarks (product scope change, 2026-11-23). The shared download store and bundled text stay: the text validates timing and supplies ayah counts.
- Defer fixed-page Mushaf rendering, word-level timing, translations and tafsir.

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
- Playback-track and queue policy, including play-all and shuffle order, but not the audio engine.
- Pure position-to-ayah resolution using the native player's reported position.
- Download metadata, desired state, byte accounting and reconciliation policy, but not OS background execution.
- Listening sessions: identity, last media position, derived ayah, heard fraction and newest-first ordering.
- Collections: identity, the pinned Favorites rule, manual order and item validity.
- Ayah bookmarks: edition, surah, ayah and media position identity.
- Storage-budget accounting: used bytes, per-reciter totals and the limit-reached decision.
- Search normalization and matching predicates over reciters, editions, surahs and library items. Display text stays verbatim.
- The durable library store and its schema, migrations and queries.
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
| Downloads | Deferred with the product feature; background `URLSession` and atomic replacement when it returns |
| Materials | Liquid Glass on macOS 26+: system sidebar, toolbar, search and segmented controls, a full-width glass player bar floating over the content, glass (`.glass`, `.glassProminent`) action buttons, and reciter filters as glass chips (`FilterChips`). Content cards stay opaque. The bar lives in its own `NSHostingView`, added to the window's frame view above the content view (`FloatingPlayerBar`). `NavigationSplitView`'s columns are AppKit views stacked over anything SwiftUI floats on top of them, so a SwiftUI overlay or `safeAreaInset` let clicks through to rows beneath and was covered by pushed pages. Scroll views get the bar's height as bottom `contentMargins` so every page ends above it Below macOS 26 the same views fall back to flat fills through `DesignSystem/Glass.swift` and `PillButton` |
| SDK stamp | `Package.swift` links with `-platform_version macos 13.0 26.0`. SwiftPM's default `swiftbuild` backend otherwise stamps the deployment target (13.0) as the SDK version, and AppKit then runs the app in pre-26 compatibility mode with no Liquid Glass chrome. Check with `otool -l .build/debug/TilawaMac \| grep -A5 LC_BUILD_VERSION` |
| Lists | Card lists of surah rows for the edition, history and collection screens |
| Search | `.searchable` with native filter controls |
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
| Download a surah (later) | Download identity, requested state and metadata rules | Background transfer, file destination, permissions and OS scheduling |
| Navigate reciter → edition → surahs | Available entities and selection state | Navigation container, transitions, restoration and window/device adaptation |
| Open the reader from the player bar (later) | Nothing; the reader reads existing playback state | Overlay presentation, focus movement, focus mode and the guarantee that audio is untouched |
| Resume a surah | Session identity, stored media position and derived ayah | Seeking the engine to that position and restoring the screen |
| Keep a collection | Collection and item identity, manual order and validity | Reorder gesture, rename affordance, drag and drop and list animation |
| Bookmark an ayah (later) | Edition, surah, ayah and media position | Creation affordance, list presentation and opening the reader at that ayah |
| Report storage use | Byte totals, per-reciter grouping and the limit decision | Budget control, disk reporting and the platform storage-management entry point |
| Search the library | Normalized matching predicates over shared entities | Search field, debounce, result presentation and the no-results state |
| Display an error | Stable error meaning and retry eligibility | Native message, alert, inline state and accessibility announcement |

## Persistence and content

Tilawa has one durable store: serialized documents on disk, owned by the shared core.

A document is read once into memory, changed there and rewritten whole. Writes go to a temporary file and then atomically replace the target, so a crash mid-write never leaves a partial document.

| Document | Holds |
|---|---|
| `downloads.json` | Download records (no v1 writer since downloads were deferred) |
| `sessions.json` | Listening sessions with media position, derived ayah and heard fraction (`LibraryStore`) |
| `collections.json` | Favorites first, then user collections with their manual order and items (`LibraryStore`) |
| `bookmarks.json` | Ayah bookmarks, when they return with the reader |
| `preferences.json` | Last selected filters, when a preference needs persisting |

This fits the data. The whole library is a few thousand small records on one device. Ordering, day grouping, per-reciter grouping, byte sums and name search are operations on an in-memory list, not queries that need an index. Rewriting one document costs a few hundred kilobytes.

T2 selected this over SQL and recorded the evidence. Quran text search stays a later feature, and it would index the bundled text, not this store.

Store enough durable metadata to reopen downloaded audio after restart. Resolve verified local files before requiring the network. Write downloads to a temporary file, validate completion, then atomically replace the final file. Reconcile missing, partial and corrupt files at startup.

Content packages must record source, edition, riwayah/layout compatibility, revision, checksum, license and notices. Audio timing must identify the exact recording revision it describes.

## Testing and CI

Use native CI hosts and do not treat compilation on one host as five-platform proof.

| CI lane | Required checks |
|---|---|
| Shared | Common unit tests, API compatibility, content/timing validation and durable-document round-trip tests |
| Android | JVM/unit tests, Compose UI smoke test and Media3 lifecycle test |
| iOS | XCFramework/SKIE build, Swift compile and simulator flow test |
| macOS ARM64 | XCFramework/SKIE build, Swift build, product-flow test and packaging smoke test |
| Windows x64 | Native core/NuGet generation, WinUI build, generated-binding lifecycle test and MSIX smoke test |
| Linux x64 | Native core/NuGet generation, Gir.Core app build, GTK/GStreamer integration test and Flatpak smoke test |

The minimum cross-platform acceptance slice is one reciter, two surahs, streaming, seek, one resumed session after restart, one collection item, native system controls, cancellation and one visible failure and retry path.

Each platform CI lane additionally writes a document on its real target and reads it back in a second process.

## Version 1 technical implementation plan

### Planning rules

- Deliver one complete user journey before widening catalog or feature scope.
- Reuse the existing shared models, repository, tests and macOS screens where they satisfy this document.
- Replace target-incompatible code directly; do not preserve two bridge or shell implementations.
- Keep each native player inside its application. Share inputs, timing rules and durable metadata, not a universal player abstraction.
- Keep the current Quran rendering unchanged unless the reader specification in `PRODUCT.md` requires the change.
- Add no backend, dependency-injection framework or shared navigation framework in v1.
- Keep exactly one durable store mechanism. Every new entity is another document, never a second mechanism.
- Do not implement anything from `PRODUCT.md`'s later-feature list.
- Do not leave inactive future controls in a v1 interface.

### Current implementation baseline

| Area | Starting point | V1 gap |
|---|---|---|
| Shared core | Reciters, editions, chapters, bundled verses, MP3Quran client, playback track, timing, download-state, sessions and collections exist | Search normalization and shuffle order |
| macOS | The redesign's five screens, sidebar, persistent player bar, queue, history and collections exist (2026-11-23) | Acceptance evidence, materials and contrast checks, and the accessibility pass |
| Android | Compose template consumes shared Kotlin directly | Entire v1 product slice and Media3 integration |
| iOS | SwiftUI template consumes the Kotlin framework | SKIE and the entire v1 product slice |
| Windows | WinUI shell exists | NuGet-generated shared API, x64-only configuration and the entire v1 product slice |
| Linux | Shell directory exists | C#/.NET Gir.Core application, generated shared-core NuGet integration and the entire v1 product slice |
| Delivery | Local shared/macOS builds are available | Native-host CI, packaging, clean-install and parity evidence |

### Phase dependency

```text
T0 Interop and toolchain proof
└── T1 Shared v1 contract and correctness
    └── T2 Durable library store on all five targets
        └── T3 Canonical macOS v1
            ├── T4 Android v1
            ├── T5 iOS v1
            ├── T6 Windows v1
            └── T7 Linux v1
                └── T8 Parity and release validation
```

**Current gate (2026-09-22): T0 is complete. T2 has chosen and proved its store on a macOS host; only its Windows and Linux CI cross-process check is open, so the library increments may start. T1 is complete for the audio scope and reopened for the redesign's library scope. P0 is reopened for the redesign's interaction contract. T3 work may proceed. The exact audio/timing revision binding stays deferred and blocks only future timing and highlighting changes, not core playback.**

T4 to T7 may proceed independently after T3 locks the behavior. They are complete only when T8 verifies the same acceptance journey on every target.

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

Status: complete. [Run 35030465383](https://github.com/AhmedvHashem/Quran/actions/runs/35030465383), for commit `93d901d`, passed Apple, Windows and Linux on 2026-09-15 (verified 2026-09-21). Windows now uses Ktor WinHTTP; both C# runtime smoke checks pass native loading, catalog access, cancellation, disposal and structured failures. Apple uses Xcode 26.3. Earlier failures are superseded by this run.

T0 acceptance evidence:

- [x] Green Apple CI with Xcode 26.3, framework generation, Swift smoke and iOS compile.
- [x] Green Windows x64 runtime smoke: native load, nonempty live catalog, cancellation and deterministic disposal.
- [x] Green Linux x64 runtime smoke with the same checks.
- [x] Reciter-call runtime evidence from Android and iOS: Pixel 10 emulator and iPhone 17 / iOS 26.2 both displayed “242 reciters available” on 2026-09-15. Android required the missing `INTERNET` permission to stop an OkHttp dispatcher crash.

Local runtime command: `cd Tilawa/macosApp && swift run InteropSmoke`. C# command on each target OS: `dotnet run --project interopSmoke/InteropSmoke.csproj -r win-x64` or `-r linux-x64` from `Tilawa`. Neither a skipped native test nor a cross-compiled executable closes these gates.

### T1 — Stabilize the shared v1 contract

Goal: give every application one reliable, narrow product API.

Tasks:

- [x] Keep `QuranLibrary` as the single exported composition root.
- [x] Export only reciters, editions, chapters, verses, playback-track data, timing resolution and download metadata required by v1.
- [x] Add recording identity: provider, edition, reciter, riwayah, style and provider-folder identity.
- [ ] Establish an immutable recording revision or checksum binding for timing; deferred until timing/highlighting work resumes.
- [x] Add the bundled-content manifest and verify its checksum against both the JSON and all compiled verses.
- [x] Record the owner's 2026-09-21 confirmation that the bundled text is free to use as-is; preserve its revision, checksum and bytes. Keep exact upstream URL/license identifier explicitly unrecorded rather than inventing them.
- [x] Enforce verified-text/riwayah compatibility and match timing by edition ID plus audio folder; reject malformed, overlapping or partial timing.
- [ ] Prove exact timing/audio revision compatibility using the immutable identity above; deferred until timing/highlighting work resumes.
- [x] Return a clearly identified audio-only result when the recording has no compatible bundled text.
- [x] Validate requested surahs against the selected edition before constructing an audio URL.
- [x] Resolve a verified downloaded path before catalog or timing network work.
- [x] Make persistent settings the production default; retain the in-memory store only for tests.
- [x] Add failed download state, enumerate persisted records without network access, and require checksum, positive byte count and matching identity for completed metadata.
- [x] Reconcile missing/corrupt files and mark abandoned transfers failed after the native transfer service confirms they are inactive.
- [x] Add one pure timing resolver with `[start, end)` boundaries, unlabeled regions and repeated occurrences.
- [x] Preserve coroutine cancellation instead of catching it as a normal failure.
- [x] Distinguish successful empty results from retryable transport failures.
- [x] Cache only successful catalog responses and add explicit request timeouts/status validation.
- [x] Keep both timing-discovery and segment-request failures degradable to untimed playback; preserve cancellation and retry discovery after an outage.
- [x] Return expected failures as `QuranFailure(code, retryable, message)` inside typed catalog/edition/surah result values; preserve cancellation as an exception. Native consumers use result fields rather than parsing bridge exception text.

Smallest required tests:

- [x] Compatible and incompatible text/recording combinations.
- [x] Available and unavailable surah selection.
- [x] Local-first playback with the network unavailable.
- [x] Failed first catalog request followed by successful retry.
- [x] Cancellation is not cached as empty data.
- [x] Timing intro, exact boundary, gap, final boundary, missing timing and repeated occurrence.
- [x] Download metadata survives a new shared-store instance and reconciles a missing file.
- [x] Generated Apple, WinUI and Linux consumers compile against the exported API; Windows/Linux runtime smoke checks pass in run 35030465383.

Acceptance: a platform can implement the complete v1 flow without reaching into shared internals or reproducing a domain rule.

Status: complete for the audio-player scope. Reopened on 2026-09-22 for the redesign's library scope. The immutable audio/timing revision binding remains deferred and must be completed before timing or highlighting behavior changes.

#### T1 additions for the redesign

These extend the same exported contract. They depend on T2 for storage, so define the types first and implement persistence after T2 passes.

- [x] Add listening-session identity, last media position, derived ayah, heard fraction and newest-first ordering (`LibraryStore`, `sessions.json`).
- [x] Add collection identity, the pinned Favorites rule and manual ordering (`collections.json`). Items carry a name snapshot so an item whose recording left the catalog stays readable; native shells resolve validity against the catalog.
- [x] Add `allEditions()` so reciter filters need one catalog call, and map MP3Quran's muṣḥaf-named styles to Mujawwad and Muʿallim.
- [ ] Add search normalization and matching predicates for English names, Arabic names, transliterations and surah numbers. Keep display text verbatim. macOS uses Foundation's diacritic- and case-insensitive folding until this lands.
- [ ] Add deterministic play-all and shuffle order for an edition and for a collection. macOS uses the system shuffle until P0 defines the rule.
- [x] Keep the exported API narrow: expose product operations, not the store.
- Deferred with their product features: ayah-bookmark identity, download byte size and bitrate, and the storage-budget rule.

Smallest required tests for the additions:

- [x] A replayed surah updates one session instead of creating two.
- [x] Favorites cannot be renamed, reordered or deleted.
- [x] A collection keeps its manual order across a new store instance.
- [x] An item whose recording left the catalog stays present (verified in the macOS app, shown as unavailable).
- [ ] An Arabic query and an English query find the same reciter (waits for shared normalization).

`LibraryStoreTest` covers the store; `:shared:macosArm64Test` ran 41 tests with no failures on 2026-11-23.

#### T1 contract and validation evidence

- `reciters()`, `editions()` and `surah()` return `RecitersResult`, `EditionsResult` and `SurahResult`. Check `failure` before consuming content; successful empty lists have no failure. Expected failures carry stable code, retry eligibility and safe display text; cancellation and unexpected exceptions still throw.
- `QuranLibrary.downloads()` exposes persisted metadata before network discovery. Native applications own file inspection and must reconcile records before offering local playback. Metadata checks alone do not verify a file on disk.
- Call `reconcileDownload` only after the OS transfer service confirms no active transfer for that record. A missing/checksum-mismatched/truncated file loses ready status; an abandoned transfer becomes failed and can be retried.
- Bundled text remains enabled under the existing owner decision. Custom imported JSON never inherits the bundled text's verified status.
- MP3Quran timing discovery must match both the edition ID and `folder_url` to the selected audio folder. This prevents mismatched-folder timing; it does not establish immutable audio revision identity. The remaining proof is deferred and must be completed before timing or highlighting behavior changes.
- `hasTiming` means compatible timing is advertised for the edition; a track may still be untimed when its surah timing is missing or invalid.
- Run `python3 Tilawa/scripts/check_content.py` from the repository root. It checks the pinned JSON SHA-256, chapter metadata, sequential verse numbers, all 114 chapter dispatches, and exact equality of all 6,236 compiled verses.
- Run `./gradlew :shared:allTests :shared:assembleSharedReleaseXCFramework :shared:packNuget :shared:nugetReportDiagnostics :androidApp:assembleDebug` from `Tilawa`, followed by native consumer builds. Tests now cover timing discovery outage/retry, folder mismatch, invalid surah IDs, cancellation/retry, incompatible riwayah, successful empty catalog caching, incomplete/corrupt metadata and abandoned transfers.
- Source review: [MP3Quran catalog](https://www.mp3quran.net/api/v3/reciters?language=eng), [timed reads](https://www.mp3quran.net/api/v3/ayat_timing/reads), [runner Xcode inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md). Live catalog checked 2026-09-15; Abdul Basit's Mujawwad edition is 51 (53 is Murattal), matching the product seed.

#### Verified locally on 2026-09-15

| Check | Result |
|---|---|
| Shared common tests on macOS ARM64 | 35 passed, zero failures/errors/skips |
| Shared common tests on iOS ARM64 simulator | 35 passed, zero failures/errors/skips |
| JSON/compiled Quran content integrity | 114 chapters and all 6,236 verses match the pinned checksum/data |
| Release XCFramework | iOS device/simulator and macOS, ARM64 only |
| NuGet generation and API diagnostics | Passed; `win-x64` DLL and `linux-x64` shared object only |
| macOS Swift application build | Passed against the updated result API |
| Swift interop runtime | 242 reciters, Al-Fatihah's 7 timing segments, and nonretryable structured unavailable-surah error |
| Android debug build and launch | Passed; emulator displayed 242 reciters after permission fix |
| iOS build and launch | Passed; iPhone 17 / iOS 26.2 displayed 242 reciters |
| C# runtime-smoke and Linux shell compilation | Passed against a fresh generated NuGet, zero compiler warnings/errors |
| Windows/Linux native runtime | Subsequently passed on their actual CI hosts in run 35030465383 |

T3 audio-player work may proceed. A proved audio/timing revision binding is required only before timing or highlighting behavior changes; the text file remains unchanged.

### T2 — Prove the durable library store on all five targets

Goal: choose one store for history, collections, bookmarks and download records, and prove it runs on every target before any feature depends on it.

Decision: **serialized documents on `kotlinx-io`**, not SQL.

Tasks:

- [x] Write the data shape from the `PRODUCT.md` content model: sessions, collections, collection items, bookmarks and download records.
- [x] Apply the dependency policy order and record the candidates with their target support.
- [x] Verify Kotlin/Native support for `mingwX64` before anything else.
- [x] Verify `linuxX64`, `macosArm64`, `iosArm64` and Android support.
- [x] Pin the store version with the existing Kotlin, SKIE and `kotlin-native-nuget` compatibility set.
- [x] Implement the common document store and one platform state directory per target.
- [x] Port `DownloadStore` onto it and delete the two mechanisms it replaced.
- [x] Prove a write in one store instance is readable by the next instance.
- [x] Prove every target compiles and links, including `mingwX64` and `linuxX64` from a macOS host.
- [ ] Prove a cross-process write and read on Windows and Linux CI hosts through the generated NuGet bindings.
- [ ] Add the document round-trip check to every platform CI lane.

#### Candidates and evidence

Checked against Maven Central module metadata on 2026-09-22.

| Candidate | `mingwX64` | `linuxX64` | Verdict |
|---|---|---|---|
| SQLDelight `native-driver` → SQLiter 1.3.3 | artifact published | artifact published | **Rejected.** The artifacts exist, but SQLiter links `-lsqlite3` against a system SQLite. The `mingwX64` target then links only on a Windows host, which breaks local and CI cross-compilation from macOS. |
| `kotlinx-io-core` 0.9.1 | published | published | **Selected.** JetBrains-maintained, covers every target this project builds, needs no system library. |

An earlier comment in `shared/build.gradle.kts` claimed SQLiter publishes no `linuxX64` variant. That was wrong: 1.3.1 and later publish both `linux_x64` and `mingw_x64`. The real constraint is the `-lsqlite3` link, not the missing artifact. The comment is replaced.

SQL was also more machinery than the data needs. See Persistence and content above.

#### What this replaced

`DownloadStore` previously used two mechanisms: Multiplatform Settings on Android, Apple and Windows, and a hand-written POSIX file store on Linux. Both are gone.

- Settings is a preference store. Holding roughly 1,248 download records in `NSUserDefaults` or the Windows registry is the wrong use, and the Windows implementation was `@ExperimentalSettingsImplementation`.
- Multiplatform Settings has no Linux target, which forced the second mechanism in the first place.
- `multiplatform-settings` is removed from the build. Preferences become another document.

#### Verified locally on 2026-09-22

| Check | Result |
|---|---|
| `:shared:allTests` | 36 passed on `macosArm64` and 36 on `iosSimulatorArm64`; zero failures, errors or skips |
| `:shared:linuxX64Binaries` | Linked from a macOS host |
| `:shared:mingwX64Binaries` | Linked from a macOS host |
| `:shared:packNuget`, `:shared:nugetReportDiagnostics` | Passed |
| `:shared:assembleSharedReleaseXCFramework` | Written for iOS device, iOS simulator and macOS, ARM64 only |
| `:androidApp:assembleDebug` | Passed; `TilawaStorageInitializer` merges into the application manifest |

`mingwX64Test` and `linuxX64Test` are skipped on a macOS host because their executables cannot run there. Linking is proved; running stays a CI-host gate, as T0 already requires.

Acceptance:

- One mechanism and one code path serve all five applications.
- A record written by one store instance is readable by the next.
- Windows and Linux exercise the store on their real CI hosts through the generated bindings.
- Cancellation and disposal behave the same as the rest of the shared API.

Status: selected and proved on a macOS host. The remaining gate is the cross-process read on the Windows and Linux CI hosts. Sessions, collections and bookmarks may now be built as further documents.

### T3 — Finish the canonical macOS v1 slice

Goal: build the redesign on macOS and make it the behavior reference for every other application.

Tasks:

- [x] Move `AVPlayer` ownership to an application-level playback controller so playback survives navigation.
- [x] Observe `AVPlayerItem.status`, `AVPlayer.timeControlStatus`, duration, buffering, end and failure instead of inferring state from commands.
- [x] Cancel or generation-guard overlapping reciter, edition and surah loads.
- [x] Continue only through surahs available in the selected edition.
- [x] Use the shared timing resolver and leave intro/gap regions without an ayah position.
- [x] Add Now Playing metadata, remote commands and media-key behavior; macOS has no `AVAudioSession`, so observed `AVPlayer` pause/wait/failure state is its native interruption path.
- [x] Rebuild the information architecture as the redesign defines it: sidebar, Home (featured reciters), Reciters (the whole catalog), Reciter detail, Recording edition, Recently Played and Collections. Each sidebar destination keeps its own navigation stack.
- [x] Move the player into a persistent 88pt bottom bar present on every screen, including the no-recording state.
- [x] Add search and the reciter filter chips (riwayah, style, Verse Sync, clear).
- [x] Build the library destinations on the T2 store: history and resume, Favorites and user collections.
- [x] Add play all and shuffle for an edition and a collection.
- [ ] Implement loading, buffering, offline, unavailable, error and retry states from `PRODUCT.md` on every screen. Catalog, playback and unavailable-item states exist; an offline banner does not.
- [ ] Apply the redesign's translucent materials, and verify contrast with reduced transparency and increased contrast.
- [ ] Add keyboard navigation, focus labels, VoiceOver labels and scalable text across the whole journey. Rows, controls and the seek bar carry labels; a full VoiceOver pass is still due.
- Deferred with the product scope change on 2026-11-23: downloads and offline restart, the reader overlay, focus mode and text-size controls.

Acceptance: the `PRODUCT.md` v1 acceptance journey passes on macOS ARM64 and becomes the reference recording and screenshots for T4 to T7.

Status: active. The redesign landed on 2026-11-23.

- `Catalog` loads reciters, every edition and the chapters once for the app. `ListeningHistory` and `UserLibrary` republish the shared history and collections, kept apart because playback saves progress every 10 seconds and only Recently Played shows it. `NowPlaying` owns the queue: play all, shuffle, continue to the next surah and resume at a stored position.
- The macOS queue panel uses the same row drop delegate as collections. Each upcoming queue entry has a stable ID so repeated recordings can be moved or removed independently. Other platforms will adopt the corresponding controls in T4–T7.
- Sessions save on pause, on the end of a surah, before switching surahs, every 10 seconds of playback and on quit.
- Space toggles playback through a key monitor that ignores text input; a bare-Space menu shortcut would swallow spaces in search and name fields.
- Rendering stays local to what changed. `PlaybackClock` holds the 5 Hz position and the current ayah, and only the seek row and ayah tag observe it. The App and `RootView` own the models without observing them, and the menu commands observe their own. Before this, every position tick rebuilt the whole window (2026-11-24: 60–100% CPU while playing, now ~7%, most of it audio decoding). Environment values must be stable: a `Color` built per render never equals the last one and re-renders every view that reads it.
- General settings persists appearance and accent in macOS preferences. The chosen accent updates app controls and the floating player bar in place. macOS paints sidebar selection only in the system accent, so the sidebar switches that drawing off per row (`RowHighlightOff`) and draws its own accent fill, gray in an inactive window. A row's selection `.tag` must be its last modifier; a badge or menu after it breaks selection.
- Reciter and recording links and single-click selection with double-click playback are implemented on macOS. Other platform shells will adopt the corresponding navigation, playback controls and settings in T4–T7.
- The edition screen replaces the system back chevron with the design's labelled capsule ("‹ Al-Husary", ⌘[), using `Reciter.shortName`. Arabic letters and numbers in tiles are centred on their drawn shape (`ArabicGlyph`), since Amiri Quran's tall ascent sits a plainly centred glyph low.
- The shared core shows formal riwayah transliterations by MP3Quran riwayah id and the editorial English names of the featured seed. Saved history and collection items show the catalog's current reciter name, falling back to their snapshot.
- Rendered design references: the canvas boards render offline by inlining their theme variables and running headless Chrome; compared screen by screen on 2026-11-23.
- Checked by hand in the built app on 2026-11-23: browse, filters and no results, edition play, history resume at the stored position after relaunch, row removal, collection creation, the unavailable-item state and the collection filter. Not yet exercised in the app: the row ⋯ and context menus, drag reordering and Space during typing.

### T4 — Implement Android v1

Goal: reproduce the canonical behavior with Android-native Compose and Media3 patterns.

Tasks:

- [ ] Replace the template UI with the canonical destinations and the persistent player bar.
- [ ] Use Material 3 adaptive layouts: phone navigation on compact widths and list/detail or supporting panes when space permits.
- [ ] Use Android ViewModel and lifecycle-aware Flow collection around the direct shared API.
- [ ] Implement application-level playback in a Media3 `MediaSessionService` with ExoPlayer.
- [ ] Connect the UI through a media controller rather than owning ExoPlayer in a composable.
- [ ] Provide media notification, audio focus, noisy-route/headset handling and system transport controls.
- [ ] Bind the library destinations to the shared durable store.
- [ ] Implement every required state from `PRODUCT.md`, including no results and storage budget reached.
- [ ] Add one Compose navigation/UI journey test plus one playback-service lifecycle test.

Acceptance: the full v1 journey passes on a phone-sized emulator and one expanded-width emulator/device.

### T5 — Implement iOS v1

Goal: reproduce the canonical behavior with SwiftUI and Apple media/background APIs.

Tasks:

- [ ] Build Swift-facing adapters only where the SKIE API still needs presentation-friendly shaping.
- [ ] Replace the template with the canonical screens and the persistent player bar.
- [ ] Use `NavigationStack` on compact devices and `NavigationSplitView` where the device/window supports it.
- [ ] Add an application-owned AVPlayer controller with observed playback/buffering/failure state.
- [ ] Add `AVAudioSession`, Now Playing and remote-command integration.
- [ ] Bind the library destinations to the shared durable store.
- [ ] Implement every required state from `PRODUCT.md`, including no results and storage budget reached.
- [ ] Add one XCUITest for the primary journey and a focused test for player lifecycle.

Acceptance: the full v1 journey passes on an iPhone simulator/device and an iPad or regular-width simulator.

### T6 — Implement Windows v1

Goal: reproduce the canonical behavior with WinUI 3 and the generated shared-core NuGet API.

Tasks:

- [ ] Remove direct shared-library calls from application UI code; use the generated NuGet API through a small C# application service.
- [ ] Implement the canonical pages and the persistent player bar with `NavigationView`, `Frame` and adaptive WinUI layouts.
- [ ] Use `MediaPlayer` as an application-owned service and `MediaPlaybackList` only if the v1 chapter-continuation behavior requires it.
- [ ] Integrate System Media Transport Controls and observed buffering/failure state.
- [ ] Handle generated wrapper disposal and cancellation deterministically.
- [ ] Bind the library destinations to the shared durable store through the generated bindings.
- [ ] Implement every required state from `PRODUCT.md` with keyboard and Narrator support.
- [ ] Produce and clean-install a signed-development x64 MSIX package.

Acceptance: the full v1 journey passes on a clean Windows x64 environment from the installed MSIX package.

### T7 — Implement Linux v1

Goal: reproduce the canonical behavior with C#, Gir.Core, GTK 4 and libadwaita.

Tasks:

- [ ] Use one C#/.NET application project referencing the Tilawa core package and required Gir.Core packages.
- [ ] Implement an `Adw.Application` with the canonical navigation and the persistent player bar.
- [ ] Coordinate asynchronous state updates with the GLib main context.
- [ ] Implement application-owned GStreamer playback through Gir.Core.
- [ ] Export playback state and controls through MPRIS.
- [ ] Bundle or runtime-provide the required GTK/libadwaita/GStreamer native libraries.
- [ ] Bind the library destinations to the shared durable store through the generated bindings.
- [ ] Implement every required state from `PRODUCT.md` with keyboard and Orca support.
- [ ] Produce and clean-install an x64 Flatpak.

Acceptance: the full v1 journey passes from the Flatpak on a clean supported GNOME environment, including MPRIS and a resumed session after restart.

### T8 — Cross-platform parity and release validation

Goal: prove that five separately native applications ship one product.

Tasks:

- [ ] Run the `PRODUCT.md` acceptance journey on all five installed applications.
- [ ] Verify available and unavailable surahs, seeking, retry, cancellation and stale-selection behavior.
- [ ] Verify that history and collections survive restart on every platform.
- [ ] Verify that reported storage usage matches the bytes on disk after reconciliation.
- [ ] Verify native media controls, interruption behavior and background rules on every platform.
- [ ] Verify keyboard/pointer/touch behavior and the platform screen reader.
- [ ] Verify recording identity, bundled-content integrity, licenses and notices in release artifacts.
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
