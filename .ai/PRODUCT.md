# Tilawa product definition and features

Status: authoritative product source of truth. Updated 2026-09-15.

This document defines what Tilawa is, how it behaves and how it should feel. Platform implementation is defined in [APP_STACKS_PLAN.md](arch/APP_STACKS_PLAN.md).

## Product definition

Tilawa is a fast, native Quran listening and reading application for Android, iOS, macOS, Windows and Linux.

Its core experience is:

> Discover a reciter, choose a riwayah and recording style, then listen to a continuous surah while reading its Quran text in a calm, focused interface.

Tilawa is listening-led during discovery and reading-dominant during playback. Audio is always easy to reach, but the reader remains the visual focus.

Version 1 is not a general Islamic platform, social network, tafsir suite or account-based cloud service.

## Audience and user needs

Tilawa serves people who want to:

- Listen to trusted Quran reciters without visual clutter.
- Browse a reciter's available riwayat and styles clearly.
- Read while listening.
- Follow the current ayah when verified timing is available.
- Download a surah and continue listening offline.
- Use an application that feels correct on their operating system.

## Product principles

### Respect for the Quran

- Use formal, accurate Quran terminology.
- Preserve Quran text verbatim; never modify canonical text for search or display convenience.
- Keep normalized search text separate from display text.
- Do not show text, timing or layout data with an incompatible recording.
- Record the source, revision, checksum, license and notices for bundled content.

### Native on every platform

- macOS is the canonical feature and behavior reference.
- Android, iOS, Windows and Linux must mirror its capabilities, content hierarchy and states.
- They must not copy its pixels or force macOS controls onto another platform.
- Navigation, menus, windows, gestures, keyboard behavior, media controls and accessibility follow the host platform.

### Calm and focused

- Reading and contemplation take priority over decorative or promotional content.
- Use generous whitespace, excellent Arabic typography and restrained ornament.
- Keep secondary metadata quiet.
- Avoid feeds, engagement counters, visual noise and unrelated recommendations.

### Reliable degradation

- Missing timing never prevents audio playback.
- Network failure never prevents access to bundled text or valid downloads.
- An unavailable surah is shown clearly rather than producing a broken player.
- Unsupported text/riwayah combinations are labeled audio-only rather than displaying incorrect text.

## Canonical information architecture

```text
Reciter library
└── Reciter details
    └── Riwayah
        └── Recording style / edition
            └── Surah reader and player
```

The normal first-use flow is:

1. Open the reciter library.
2. Choose a reciter.
3. Review that reciter's recordings grouped by riwayah, then style.
4. Choose an edition.
5. Open the reader on Al-Fatihah.
6. Choose another surah from native navigation when desired.
7. Stream or download the selected edition's continuous surah recording.

Back navigation returns from the reader to the selected reciter's recordings, then to the reciter library.

## Canonical screens

### 1. Reciter library

Purpose: choose a human reciter, not an opaque recording ID.

Content:

- “Choose a Reciter” heading.
- A short catalog summary.
- One card or native list item per reciter.
- English and Arabic reciter names.
- A restrained recitation/audio artwork treatment.
- Featured reciters ordered before the remaining browsable catalog.
- Loading, empty, network-error and retry states.

Desktop may use a spacious multi-column grid. Phones may use an adaptive grid or list. Selection, hover, focus and keyboard behavior must feel native to each platform.

### 2. Reciter details

Purpose: choose the exact recording edition.

Content:

- Reciter identity in English and Arabic.
- Number of available recording editions.
- Recordings grouped by riwayah first.
- Styles within each riwayah, such as Murattal, Mujawwad or Mu'allim.
- Available-surah count.
- A “Featured” label for the curated default when applicable.
- “Verse Sync” when verified ayah timing exists.
- “Full Audio” when playback exists without timing.
- Retry and empty states.

A reciter with one riwayah and one style still uses this screen; it must remain simple rather than inventing a different flow.

### 3. Surah reader and player

Purpose: make reading and listening feel like one activity.

Desktop composition:

- Native chapter sidebar or navigation pane.
- Central Quran reading surface.
- Persistent player area.

Phone composition:

- Native screen navigation for chapters and recording details.
- Full-width reader.
- Compact persistent player that can expand when needed.

Reader content:

- Surah name in Arabic and English/transliteration where appropriate.
- Makki/Madani classification.
- Ayah count using Arabic-Indic digits in the Quran surface.
- Flowing, centered RTL Quran text for v1.
- Clear ayah markers.
- Current-ayah emphasis only when compatible timing exists.

Player content:

- Current surah, reciter and style.
- Play/pause, previous and next controls.
- Elapsed time and duration.
- Volume where the platform normally exposes it.
- Download action and durable download state.
- Timing-aware seek markers and current-ayah position for timed recordings.
- Plain continuous scrubber for untimed recordings.
- Native system media controls outside the application.

## Visual identity

The visual style combines platform-native foundations with restrained traditional character.

### Character

- Modern minimalism.
- Respectful rather than ornamental for ornament's sake.
- Quiet hierarchy and generous spacing.
- High-quality Quran typography.
- Subtle Islamic geometry or calligraphic framing only around meaningful Quran content.
- Familiar platform-native controls for all actions.

### Canonical macOS palette

| Role | Value |
|---|---|
| Interaction accent | `#007AFF` |
| Reciter artwork accent | `#34C759` |
| Sidebar/background | `#F1F0F4` |
| Secondary label | `#8A8A8E` |
| Quran surface | `#FDFBF7` |
| Quran text | `#1A1613` |
| Ornament surface | `#FBF6EC` |
| Ornament border | `#B08A3E` |
| Ornament title | `#6B5220` |
| Ornament subtitle | `#8A6E33` |
| Player surface | `#ECECEC` |

These are semantic brand references, not a requirement to ignore platform colors, contrast rules or appearance modes. Each application maps the roles to native visual conventions while retaining Tilawa's calm identity.

### Typography

- Use the platform system font for interface labels and controls.
- Bundle a verified Quran-capable Arabic font for the v1 reader.
- Preserve Arabic shaping, marks, bidi controls and line readability.
- Never depend on the user having a particular Quran font installed.
- Support native text scaling without clipping or hiding controls.

### Reading mode decision

Version 1 uses accessible, reflowing Unicode Quran text with a bundled verified font. This supports responsive layouts, copying, search and assistive technology.

An exact fixed-page Mushaf is a later, separate reading mode. If built, it uses one verified page-image set with matching ayah bounds plus an accessible Unicode representation. Tilawa will not build multiple competing Mushaf rendering systems at the same time.

### Design source

The original macOS direction is represented by Figma file `Tilawa App` (`6HAE3faqlNALYfTRcvQTAM`):

- `26:2` — Home / reciter grid.
- `7:2` — macOS sidebar, reading surface and player.
- `26:166` — reciter-card navigation annotation.

The macOS implementation is the living behavioral reference. This product document wins when an older mockup conflicts with an accepted product decision.

## Content and playback model

### Catalog and audio

- MP3Quran is the v1 reciter catalog, recording, continuous-surah audio and available ayah-timing source.
- A recording edition is identified by provider, reciter, riwayah, style and recording revision.
- Featured reciters are editorial ordering, not a popularity score from the provider.
- Provider IDs are resolved from verified catalog data and are never guessed.

### Quran text

- Quran text and chapter metadata are bundled for fully offline reading.
- The checksum-pinned bundled Hafs text is approved for v1 display; exact upstream attribution and redistribution terms remain a release gate.
- The initial text edition must be explicitly identified and verified.
- Text compatibility with riwayah and recording edition is checked before display.
- A mismatched recording may remain playable as clearly labeled audio-only content.

### Gapless-only playback

- One continuous audio file represents one surah in one recording edition.
- Tilawa does not chain one audio file per ayah.
- Ayah boundaries come from a separate timing map when available.
- “Gapless” in v1 means no application-created gap between ayat inside one surah.
- Seamless transitions between separate surah files are not promised until verified as a later feature.

### Timing and highlighting

- The native player's actual media position drives highlighting.
- Buffering, pause and interruption do not advance an independent timer.
- Timing must match the exact recording revision.
- Intervals use deterministic boundary behavior and may include unlabeled intro regions.
- Intro or basmala time must not incorrectly highlight ayah 1.
- Missing, partial or invalid timing produces no highlight and a plain scrubber.
- Repeated ayah segments remain distinct timing occurrences when the source provides them.

### Offline downloads

- A download is keyed by recording edition and surah.
- Visible states are not downloaded, downloading, downloaded and failed.
- A verified local file is preferred before network access.
- Downloaded playback works after quitting, disabling the network and reopening the application.
- Partial, missing or corrupt files are reconciled and never presented as ready.
- Removing a download removes both the file and its durable metadata.

### Backend policy

Version 1 has no backend and embeds no client secret. A small Quran Foundation token broker may be introduced later only if MP3Quran timing or catalog coverage becomes a demonstrated limitation.

## Featured-reciter seed

The editable starting collection is:

- Mishary Rashid Alafasy — Hafs ‘an Asim, Murattal.
- Abdur-Rahman As-Sudais — Hafs ‘an Asim, Murattal.
- Saud Ash-Shuraym — Hafs ‘an Asim, Murattal.
- Mahmoud Khalil Al-Husary — Hafs ‘an Asim, Murattal; Mu'allim secondary.
- Mohamed Siddiq Al-Minshawi — Hafs ‘an Asim, Murattal; Mu'allim secondary.
- Abdul Basit Abdul Samad — Hafs ‘an Asim, Murattal; Mujawwad as signature style.
- Saad Al-Ghamdi — Hafs ‘an Asim, Murattal.
- Ali Al-Huthaify — Hafs ‘an Asim, Murattal.
- Maher Al Muaiqly — Hafs ‘an Asim, Murattal.
- Yasser Al-Dosari — Hafs ‘an Asim, Murattal.

This list is content configuration. It can be revised without changing the product architecture.

## Version 1 feature list

### Discovery and selection

- [ ] Load and display the reciter catalog.
- [ ] Show one entry per reciter with English and Arabic names.
- [ ] Order the curated featured collection first while retaining the full catalog.
- [ ] Open a reciter-detail screen.
- [ ] Group recording editions by riwayah and then style.
- [ ] Show edition availability, timing capability and featured status.

### Reading

- [ ] Bundle verified Quran text and chapter metadata.
- [ ] Display accessible, reflowing RTL Quran text with a bundled font.
- [ ] Navigate all 114 surahs through native platform navigation.
- [ ] Show surah metadata and Arabic-Indic ayah markers.
- [ ] Preserve Quran text exactly and validate edition compatibility.
- [ ] Clearly show audio-only editions when compatible text is unavailable.

### Playback

- [ ] Stream one continuous file per surah.
- [ ] Provide play/pause, previous, next, seek, elapsed time and duration.
- [ ] Keep playback alive while navigating elsewhere in the application.
- [ ] Continue through available surahs without selecting unavailable recordings.
- [ ] Report real loading, buffering, playing, paused, ended and failed states.
- [ ] Handle rapid selection without allowing stale requests to replace the newest choice.
- [ ] Integrate native background playback, interruptions, media keys and system controls.

### Ayah synchronization

- [ ] Validate timing against the recording edition and revision.
- [ ] Resolve the active ayah from actual player position.
- [ ] Highlight the current ayah and show timing-aware seek markers when timing exists.
- [ ] Show no highlight and a plain scrubber when timing is unavailable or invalid.
- [ ] Test intro, first/last boundary, seek, pause, buffering, missing timing and repeated segments.

### Offline use

- [ ] Download a selected edition's surah.
- [ ] Show durable download progress and state.
- [ ] Prefer verified local audio before the network.
- [ ] Play after application restart with the network disabled.
- [ ] Detect and recover from interrupted, missing and corrupt downloads.

### Reliability and accessibility

- [ ] Use explicit loading, empty, unavailable, offline, error and retry states.
- [ ] Apply timeouts and preserve cancellation.
- [ ] Allow a failed first request to succeed on retry.
- [ ] Support RTL, Arabic shaping, keyboard navigation, focus, screen readers and platform text scaling.
- [ ] Meet platform contrast, touch-target and pointer-target requirements.
- [ ] Provide equivalent behavior across all five applications using native components.

## Later features

Add these only after the complete v1 flow is reliable on all supported platforms:

- Favorites and bookmarks with durable storage.
- Listening history and saved progress/resume.
- Queue improvements and deliberate shuffle behavior.
- Repeat surah, ayah or selected ayah range.
- Verified seamless transitions between separate surah files.
- Quran text search.
- Copy and share actions that preserve canonical text and citation metadata.
- Exact fixed-page Mushaf mode with matching ayah bounds and accessible text.
- Word-level timing and highlighting.
- Additional riwayat-specific text and Mushaf layout packs.
- Translations and tafsir.
- Additional audio and timing providers.
- A Quran Foundation backend/token broker if provider limitations justify operating it.
- Cross-device synchronization and accounts only when they solve a demonstrated user need.
- Dark appearance after its Quran colors, imagery and contrast have been designed and verified.

## Explicitly outside version 1

- Per-ayah audio-file chaining.
- A required user account.
- A backend without a demonstrated provider or synchronization need.
- Word-by-word highlighting.
- Multiple competing Mushaf rendering engines.
- Pixel-identical interfaces across operating systems.
- Features shown only as inert controls.

## Product state requirements

Every primary screen must define:

- Initial loading.
- Successful content.
- Empty content.
- Offline with usable local content.
- Offline without required content.
- Unavailable recording or surah.
- Recoverable failure with retry.
- Non-recoverable content incompatibility with a clear explanation.

Playback additionally defines preparing, buffering, playing, paused, interrupted, ended and failed states. The UI must reflect observed player state rather than the last button pressed.

## Cross-platform parity rule

For every product change made first on macOS, record:

1. The user-visible behavior.
2. Shared-core impact.
3. Android native equivalent.
4. iOS native equivalent.
5. Windows native equivalent.
6. Linux/GNOME native equivalent.
7. Accessibility and offline implications.
8. Acceptance evidence on each supported platform.

A temporary parity gap may be tracked, but it must be explicit. A feature is not considered fully shipped while another supported application silently lacks it.

## Version 1 acceptance journey

On every supported platform, a user must be able to:

1. Launch Tilawa and browse reciters.
2. Choose a reciter, riwayah and style.
3. Open Al-Fatihah and start continuous playback.
4. Observe correct ayah highlighting for a timed edition.
5. Use an untimed edition without false highlighting.
6. Switch to another available surah and seek safely.
7. Control playback through the platform's native media surface.
8. Download a surah, quit, disable the network, relaunch and play it.
9. Recover from a failed request without restarting the application.
10. Complete the flow with keyboard or assistive technology where the platform supports it.

## Version 1 product implementation plan

This plan turns the feature list above into product increments. Technical phase IDs refer to the implementation plan in `APP_STACKS_PLAN.md`.

### Delivery policy

- Complete and approve each behavior on macOS first.
- Treat macOS as the reference for feature meaning, content and states.
- Translate that behavior to native platform patterns rather than copying macOS layout.
- Ship no visible control without working behavior.
- Keep later features out of v1 implementation and design work.
- Prefer one complete reciter-to-offline-playback journey over partial catalog-wide coverage.

### Current product baseline

| Platform | Current product state | First required outcome |
|---|---|---|
| macOS | The three-screen flow and core visual direction exist as a proof of concept | Make the journey reliable, persistent, accessible and system-integrated |
| Android | Product UI not started | Native compact and expanded-width v1 journey |
| iOS | Product UI not started | Native iPhone and iPad v1 journey |
| Windows | Product UI not started | Native installed x64 v1 journey |
| Linux | Product UI not started | Native installed GNOME x64 v1 journey |

### Product increment map

```text
P0 Lock v1 content and interaction contract
└── P1 Reciter discovery
    └── P2 Recording selection
        └── P3 Reader and continuous playback
            └── P4 Timing and offline reliability
                └── P5 Accessibility and failure recovery
                    └── P6 Five-platform release parity
```

### P0 — Lock the v1 product contract

Status: open; this is a prerequisite to resuming T2. Existing reader enablement is retained, but upstream text provenance and terms remain unresolved.

Outcome: implementation teams have one unambiguous three-screen product to build.

Tasks:

- [ ] Confirm the bundled Quran text edition, source, revision, checksum, license and display name.
- [x] Define the initial rule: bundled text is Hafs only (`rewaya_id = 1`); unknown and other provider riwayat stay audio-only.
- [x] Verify the featured-reciter names and preferred editions against live provider data without guessing IDs (2026-09-15; mapping below).
- [x] Define canonical English and Arabic terminology below.
- [x] Define the v1 labels and offline states below.
- [x] Confirm that untimed audio remains fully playable with no highlighted ayah.
- [x] Confirm that incompatible text editions are clearly audio-only.
- [x] Confirm reflowing Unicode text as the only v1 Quran renderer.
- [x] Select Amiri Quran, already named by the reader theme, under the upstream SIL Open Font License 1.1. T2 must pin the font bytes, include the notice, register the font and verify rendering.
- [x] Exclude favorite, shuffle, repeat and other later-feature controls from the v1 screen specification.
- [x] Define compact, expanded and desktop arrangements in the canonical screens and platform expression checklist.

Acceptance:

- The content manifest inputs are known.
- Every v1 control maps to a real v1 behavior.
- Each screen has approved content, loading, empty, offline, unavailable and error states.
- No later feature is needed to complete the primary journey.

#### Terminology and state contract

| English | Arabic |
|---|---|
| Reciter | القارئ |
| Riwayah | الرواية |
| Recitation style | أسلوب التلاوة |
| Surah / Ayah | السورة / الآية |
| Makki / Madani | مكية / مدنية |
| Featured | مميز |
| Verse Sync | مزامنة الآيات |
| Full Audio | تلاوة كاملة |
| Audio Only | صوت فقط |
| Unavailable | غير متاح |
| Not Downloaded | غير منزّل |
| Downloading | جارٍ التنزيل |
| Downloaded | تم التنزيل |
| Download Failed / Retry | تعذّر التنزيل / إعادة المحاولة |

A successful empty list is an empty state, not a connection failure. A failed request presents the shared safe message and retry eligibility. Compatible bundled text remains readable without timing; incompatible riwayat show Audio Only. Offline playback requires a locally verified file, with missing/partial/corrupt files removed from ready state. Compact layouts use native stacked destinations and a persistent compact player; expanded/desktop layouts use native chapter panes, reader and persistent player as defined above.

#### Confirmed content inputs

The featured IDs below were checked against the [English catalog](https://www.mp3quran.net/api/v3/reciters?language=eng) and its Arabic counterpart on 2026-09-15. Keep the editorial names in the seed; live provider transliterations may differ.

| Reciter | Reciter ID | Preferred edition |
|---|---:|---:|
| Mishary Rashid Alafasy | 123 | 123 |
| Abdur-Rahman As-Sudais | 54 | 54 |
| Saud Ash-Shuraym | 31 | 31 |
| Mahmoud Khalil Al-Husary | 118 | 118 |
| Mohamed Siddiq Al-Minshawi | 112 | 112 |
| Abdul Basit Abdul Samad | 51 | 51 (Mujawwad; 53 is Murattal) |
| Saad Al-Ghamdi | 30 | 30 |
| Ali Al-Huthaify | 74 | 74 |
| Maher Al Muaiqly | 102 | 102 |
| Yasser Al-Dosari | 92 | 92 |

Font: [Amiri Quran upstream](https://github.com/aliftype/amiri), [SIL OFL 1.1 notice](https://github.com/aliftype/amiri/blob/main/OFL.txt). Font selection/license is established; binary bundling and visual verification remain T2 work.

The existing text's JSON and compiled verses match exactly, but its original upstream download/license is still required. Do not replace this missing evidence with a completion checkbox.

Technical dependency: T0 and the content portion of T1.

### P1 — Reciter discovery

Outcome: a user can reliably find and select a human reciter.

Tasks:

- [ ] Present featured reciters first without hiding the rest of the catalog.
- [ ] Show English and Arabic names together.
- [ ] Use a native grid where space supports it and a native list/adaptive grid where it does not.
- [ ] Give each interactive item clear hover, focus, pressed and selected behavior appropriate to the platform.
- [ ] Provide initial loading, successful content, empty catalog, offline failure and retry states.
- [ ] Preserve the latest selection when a stale request completes.
- [ ] Make the complete list reachable by keyboard, touch, pointer and screen reader.

Acceptance:

- Selecting a reciter always opens that reciter's details.
- A failed first request can be retried without relaunching.
- English and Arabic names remain readable at supported text sizes.
- Featured ordering is editorial data, not hard-coded UI duplication.

Technical dependency: T1, followed by the relevant platform phase.

### P2 — Recording selection

Outcome: a user understands and selects the precise recitation they will hear.

Tasks:

- [ ] Show the selected reciter's English and Arabic identity.
- [ ] Group editions by riwayah, then by style.
- [ ] Show available-surah count and timing capability.
- [ ] Mark only a verified preferred edition as featured.
- [ ] Keep a one-riwayah/one-style reciter simple and immediately understandable.
- [ ] Explain unavailable or incompatible content without exposing provider implementation details.
- [ ] Return naturally to the reciter library using the platform's navigation convention.

Acceptance:

- Selecting an edition opens Al-Fatihah when available, otherwise the first available surah.
- Timed, untimed, partial-surah and audio-only editions are visually distinguishable.
- No selection can generate playback for a surah absent from that edition.

Technical dependency: T1, followed by the relevant platform phase.

### P3 — Reader and continuous playback

Outcome: reading and listening work as one stable activity.

Tasks:

- [ ] Keep the Quran reader visually dominant over controls and metadata.
- [ ] Show surah identity, revelation place and ayah count.
- [ ] Render verbatim Quran text with correct RTL shaping and Arabic-Indic ayah markers.
- [ ] Load one continuous file for the selected surah.
- [ ] Implement play/pause, previous, next, seek, elapsed time and duration.
- [ ] Keep playback running while navigating elsewhere in the application.
- [ ] Show preparing, buffering, playing, paused, interrupted, ended and failed states from the actual player.
- [ ] Continue to the next available surah after completion according to the approved v1 behavior.
- [ ] Expose now-playing information and transport controls through the native operating-system surface.

Acceptance:

- Playback does not create gaps between ayat by switching files.
- Leaving the reader does not destroy playback.
- The interface never says “playing” merely because the play button was pressed.
- Previous/next never selects an unavailable surah.
- The reader remains usable while audio is paused, buffering or unavailable.

Technical dependency: T1 and T2, then T3–T6.

### P4 — Timing and offline reliability

Outcome: synchronized reading is trustworthy when available, and downloads work without a network.

Tasks:

- [ ] Highlight an ayah only when the actual player position lies inside a compatible timing segment.
- [ ] Leave intro, basmala-only and unlabeled timing regions unhighlighted.
- [ ] Use timing-aware seek markers for timed editions.
- [ ] Use a plain continuous scrubber for missing, invalid or incompatible timing.
- [ ] Show not-downloaded, downloading, downloaded and failed states.
- [ ] Keep the download associated with its exact recording edition and surah.
- [ ] Prefer a verified local file before contacting the network.
- [ ] Reconcile incomplete, missing and corrupt files.
- [ ] Preserve completed downloads and their metadata through application restart.

Acceptance:

- Pause and buffering freeze highlighting at the observed media position.
- Seeking updates the highlight without a false intermediate ayah.
- Untimed playback never fabricates a current ayah.
- Download → quit → disable network → relaunch → play succeeds.
- A damaged file is not shown as ready and offers a recoverable action.

Technical dependency: T1 and each platform's native player/download implementation.

### P5 — Accessibility and failure recovery

Outcome: the core journey remains understandable and operable beyond the happy path.

Tasks:

- [ ] Provide accessible names, roles, state and value for every interactive control.
- [ ] Preserve logical reading and focus order in RTL and LTR interface contexts.
- [ ] Support native text scaling without clipping Quran text, metadata or controls.
- [ ] Support keyboard operation on desktop and external-keyboard operation where expected on mobile.
- [ ] Announce loading completion, playback failure and download completion appropriately.
- [ ] Make retry available for recoverable catalog, edition, timing and playback failures.
- [ ] Preserve cancellation so navigating away does not produce a delayed error or stale screen.
- [ ] Use respectful, plain-language error copy without exposing URLs, exception names or provider internals.

Acceptance:

- The primary journey completes with the platform screen reader.
- The desktop journey completes without a pointer.
- Large text does not hide the selected reciter, edition or primary playback control.
- A recoverable failure never requires an application restart.

Technical dependency: included in T2–T7, not deferred to a post-v1 cleanup phase.

### P6 — Five-platform release parity

Outcome: users receive the same Tilawa v1 product through five native experiences.

Tasks:

- [ ] Record the macOS reference journey and state screenshots after P1–P5 pass.
- [ ] Verify equivalent Android behavior on compact and expanded widths.
- [ ] Verify equivalent iOS behavior on iPhone and iPad layouts.
- [ ] Verify equivalent Windows behavior from the installed x64 package.
- [ ] Verify equivalent Linux behavior from the installed x64 Flatpak.
- [ ] Compare labels, catalog ordering, content identity, selected edition and error meanings across platforms.
- [ ] Verify each platform uses native navigation and controls rather than macOS-shaped replacements.
- [ ] Close every v1 parity gap or remove the unsupported feature from all v1 applications.

Acceptance:

- All ten steps in the version 1 acceptance journey pass on all five platforms.
- All version 1 feature-list checkboxes are supported by evidence.
- Quran text/content validation and licenses are complete.
- No later-feature control is visible.

Technical dependency: T7.

## Platform expression checklist

| Product element | macOS reference | Android expression | iOS expression | Windows expression | Linux expression |
|---|---|---|---|---|---|
| Reciter browsing | Spacious native grid | Adaptive Material grid/list | SwiftUI adaptive grid/list | WinUI adaptive grid | GTK/libadwaita adaptive grid/list |
| Recording hierarchy | Detail screen with riwayah sections | Native destination and sections | Native destination and sections | Native page and grouped items | Adwaita navigation page and groups |
| Surah navigation | Sidebar | Compact destination or expanded pane | Stack or split view | `NavigationView` pane | Adwaita split/navigation view |
| Reader | Scrollable central surface | Compose RTL reading surface | SwiftUI RTL reading surface | WinUI RTL reading surface | GTK RTL reading surface |
| Player | Persistent bottom area | Media3-backed compact/expanded player | Apple-native compact/expanded player | WinUI player surface | GNOME player surface |
| System playback | Apple Now Playing/media keys | Media notification/system session | Control Center/lock screen | Windows media controls | MPRIS desktop controls |

This table defines equivalent product roles, not component dimensions or pixel specifications.

## Version 1 release gates

Release is blocked by any of the following:

- Incorrect, unidentified or unlicensed Quran text.
- Text displayed for an incompatible riwayah or recording without an audio-only warning.
- False ayah highlighting caused by invalid timing or an independent clock.
- Downloads reported as ready but unavailable after restart.
- Playback tied to a disposable screen lifecycle.
- Missing native media controls or interruption handling.
- A primary flow that cannot recover from a transient network failure.
- A supported platform missing a v1 feature without an explicit product-scope change.
- An inaccessible primary action or unreadable scaled layout.
- An inert control advertising a later feature.

## Later-feature freeze

Favorites, bookmarks, history, saved progress, shuffle, repeat modes, search, fixed-page Mushaf rendering, word timing, translations, tafsir, additional providers, accounts and synchronization remain in the later backlog until P6 and T7 pass. Their models, controls and infrastructure are not created during v1 unless required to remove a correctness or data-loss risk.
