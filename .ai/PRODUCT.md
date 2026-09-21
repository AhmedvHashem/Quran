# Tilawa product definition and features

Status: authoritative product source of truth. Updated 2026-09-22.

This document defines what Tilawa is, how it behaves and how it should feel. Platform implementation is defined in [TECH.md](TECH.md).

## Product definition

Tilawa is a fast, native Quran audio player for Android, iOS, macOS, Windows and Linux. The Quran text is a read-along surface inside the player. It is not a separate reading application.

Its core experience is:

> Discover a reciter, choose a riwayah and recording style, then listen to a continuous surah through a calm, reliable native player.

Listening is the application. A persistent player bar runs on every screen. It owns the current recording and the observed playback state. The muṣḥaf opens over that player from the player bar. Closing the muṣḥaf never interrupts audio.

A personal library surrounds the player: recently played with resume, offline downloads with a storage budget, and collections with favorites and ayah bookmarks.

Version 1 is not a general Islamic platform, social network, tafsir suite or account-based cloud service.

### Current focus

- Build the eight canonical screens and the persistent player bar as one connected library.
- Prioritize playback lifecycle, native system controls, continuous surah navigation, downloads and offline playback.
- Treat the reader as a read-along surface that the player bar opens and closes.
- Keep the current Quran rendering and highlighting behavior. Add only the reader controls this document defines.
- Change Quran text handling only to prevent a correctness, security, data-loss or accessibility regression.
- Defer fixed-page Mushaf rendering, word-level timing, translations and tafsir.

## Audience and user needs

Tilawa serves people who want to:

- Listen to trusted Quran reciters without visual clutter.
- Browse a reciter's available riwayat and styles clearly.
- Read while listening.
- Follow the current ayah when verified timing is available.
- Download a surah and continue listening offline.
- Continue a surah at the ayah where they stopped.
- Keep chosen recitations in favorites and in personal collections.
- Bookmark an ayah and return to it in both audio and text.
- See and control how much disk the offline recitations use.
- Find a reciter, edition or surah by name in either language.
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

- Listening and contemplation take priority over decorative or promotional content.
- Use generous whitespace, excellent Arabic typography and restrained ornament.
- Keep secondary metadata quiet.
- Avoid feeds, engagement counters, visual noise and unrelated recommendations.

### Reliable degradation

- Missing timing never prevents audio playback.
- Network failure never prevents access to bundled text or valid downloads.
- An unavailable surah is shown clearly rather than producing a broken player.
- Unsupported text/riwayah combinations are labeled audio-only rather than displaying incorrect text.

## Canonical information architecture

Tilawa has one persistent player and four library destinations. The listening chain is the primary path. The muṣḥaf sits at the end of that chain and opens from the player bar.

```text
Persistent player bar  (present on every screen)
└── Reader  (opened and closed from the player bar chip)
    └── Reader focus mode

Library
├── Reciters                     ← library home
│   └── Reciter detail           ← editions grouped by riwayah, then style
│       └── Recording edition    ← every surah inside one edition
├── Recently Played
├── Downloads
└── Collections
    ├── Favorites                ← pinned, always present
    └── User collections         ← reorderable and renamable
```

The normal first-use flow is:

1. Open Reciters, the library home.
2. Choose a reciter.
3. Review that reciter's editions, grouped by riwayah and then by style.
4. Choose an edition and open its surah list.
5. Start a surah. The player bar takes over and keeps playing everywhere.
6. Open the reader from the player bar to follow the text, then close it.
7. Move freely to Recently Played, Downloads or a collection while audio continues.

Back navigation follows the listening chain in reverse. The sidebar reaches any library destination directly. Playback continues until the user stops it or the queue ends.

## Canonical screens

Version 1 has eight screens and one persistent component. Every screen carries the sidebar and the player bar.

### Persistent player bar

The player bar is a component, not a screen. It is present on every screen, including the reader.

Content, from leading to trailing edge:

- Current surah number in Arabic-Indic digits.
- Surah name, then reciter and style on a second line.
- Play/pause, previous and next.
- Elapsed time, a scrubber and duration.
- Timing-aware seek markers for timed recordings; a plain continuous scrubber otherwise.
- Volume where the platform normally exposes it.
- An ayah-position chip, for example `Ayah 1 of 7`, that opens and closes the reader.

Rules:

- The chip fills with the interaction accent while the reader is open.
- The chip shows no ayah position for an untimed recording; it still opens the reader.
- The bar reflects observed player state, never the last button pressed.
- Native system media controls mirror the bar outside the application.

Phones use a compact bar that expands into the primary playback surface. The chip becomes the reader entry in that expanded surface.

### 1. Reciters

Purpose: choose a human reciter, not an opaque recording ID.

Content:

- Sidebar with a Library group (Reciters, Recently Played, Downloads with a count) and a Collections group (Favorites with a count, then user collections with counts, and an add-collection control).
- Screen title and a reciter search field.
- A "Featured reciters" section header with a shown-of-total count.
- Filter chips in three rows: riwayah, recitation style and Verse Sync. A clear control resets them.
- One card or native list item per reciter: initial-letter avatar, English name, Arabic name, available styles and a Verse Sync badge when verified timing exists.
- Featured reciters ordered before the remaining browsable catalog.
- Loading, empty, no-results, network-error and retry states.

Desktop may use a spacious multi-column grid. Phones may use an adaptive grid or list. Selection, hover, focus and keyboard behavior must feel native to each platform.

### 2. Reciter detail

Purpose: choose the exact recording edition.

Content:

- Hero with initial-letter avatar, English name and Arabic name.
- A summary line: edition count, riwayah count and where Verse Sync is verified.
- Two primary actions: play the first available surah, and open the reader.
- Editions grouped by riwayah first. Each riwayah header states its style count and whether it is compatible with the bundled text.
- Style rows within each riwayah, such as Murattal, Mujawwad or Mu'allim.
- Per style: available-surah count, a plain-language capability sentence and one capability badge.
- A "Featured" label on the curated default when applicable.

The three capability badges are exclusive:

| Badge | Meaning |
|---|---|
| Verse Sync | Verified ayah timing exists for this recording revision |
| Full Audio | Continuous audio plays; no timing map exists |
| Audio only | The audio riwayah does not match the bundled text, so no text is shown |

A reciter with one riwayah and one style still uses this screen. It must remain simple rather than inventing a different flow.

### 3. Recording edition

Purpose: browse and start any surah inside one chosen edition.

Content:

- Title bar with the reciter name, the style and riwayah, a surah search field and a sort control.
- Hero with the style name in English and Arabic, and a metadata line: reciter, riwayah, surah count, ayah count, total duration and bitrate.
- Actions: play all, shuffle and download all.
- A timing badge when ayah timing is verified for the edition.
- A surah table with columns for index, surah, length, offline state and duration.
- Each row shows the Arabic-Indic number, English name, Arabic name and ayah count.
- The offline column shows the durable download state for that surah in that edition.
- Progressive loading for the remaining surahs of a long edition.
- Loading, empty, offline, unavailable and retry states.

Phones use a native list instead of a table. The same columns become a row with secondary text.

### 4. Reader

Purpose: follow the text while listening. The reader is a read-along surface, not the home of the application.

Rules:

- The reader opens only from the player bar chip.
- Closing the reader leaves playback untouched.
- The reader is unavailable for an `Audio only` recording, and the chip explains why.

Content:

- Header with the surah name, the capability badge, text-size decrease and increase controls, and a close control labeled to state that audio keeps playing.
- Quran surface: surah name in Arabic, Makki/Madani classification and ayah count in Arabic, then the same line in English.
- Flowing, centered RTL Quran text with clear ayah end markers and Arabic-Indic ayah numbers.
- Current-ayah emphasis only when compatible timing exists.
- A surah pane listing all chapters with a total count and an offline count.
- A jump field that accepts a number, a transliteration or Arabic.
- Chapter filters: all, offline and recent.

### 5. Reader focus mode

Purpose: remove everything except the text while audio continues.

Content:

- The Quran surface and the player bar only.
- No surah pane and no sidebar.
- The header keeps the surah name, the capability badge and the text-size controls.

Audio never pauses when entering or leaving focus mode.

### 6. Recently Played

Purpose: return to what the user was listening to.

Content:

- Title, a history search field and a clear-history action.
- A "Continue listening" card with the surah, reciter, style, riwayah, the stopped ayah position, the remaining time and a resume action.
- A history list with a session count, grouped by day: today, yesterday, then earlier periods.
- Each row shows the Arabic-Indic surah number, surah name, reciter, riwayah, a heard percentage and a timestamp.
- A per-row remove action.

History is one flat list, newest first. It has no completion filters.

### 7. Downloads

Purpose: control what is on the device and how much disk it uses.

Content:

- Title, a download search field and a manage-storage action.
- A storage budget: used size, the reserved size, the reciter and file counts, and a segmented bar with a per-reciter legend.
- Filters: all, downloading and on-device, plus a group-by-reciter control.
- An active-transfer count.
- Per-reciter groups showing surah count, coverage, total size and bitrate.
- Per-surah rows showing the style, riwayah, duration, total size and either transferred size or the on-device state.

### 8. Collections

Purpose: keep chosen recitations and ayat together.

Favorites is a pinned collection. It is always present and cannot be removed or renamed. User collections behave the same way, but they can be reordered, renamed and edited.

Content:

- Title, a filter field and a sort or add-surahs action.
- Hero with a collection kicker, the name and a metadata line: item counts, total duration, reciter count and, for user collections, the last update.
- Actions: play all, shuffle, and download all or edit.
- An all-offline badge when every item is on the device.
- A recitations table with columns for surah, reciter, added date and duration. A user collection keeps its manual order and shows an index column.
- An ayah-bookmarks section, in Favorites, listing the surah, the ayah reference, the ayah text, the media position and the recording. Opening a bookmark opens the reader at that ayah.

## Visual identity

The visual style combines platform-native foundations with restrained traditional character.

### Character

- Modern minimalism.
- Respectful rather than ornamental for ornament's sake.
- Quiet hierarchy and generous spacing.
- High-quality Quran typography.
- Subtle Islamic geometry or calligraphic framing only around meaningful Quran content.
- Familiar platform-native controls for all actions.

### Material and depth

The macOS direction is translucent. Chrome floats over a warm-to-cool window wall.

- The sidebar, the title bar and the player bar are translucent blurred materials.
- Cards are translucent and lift on hover.
- Content surfaces and the Quran surface stay opaque, so text contrast never depends on what is behind it.
- Hairlines and inner highlights define edges instead of heavy borders.

Each platform maps this to its own material system. Translucency is never allowed to reduce text contrast below the platform requirement. A platform without a material system uses its opaque equivalent.

### Canonical macOS palette

| Role | Value |
|---|---|
| Window wall | `linear-gradient(152deg, #E6DED2 0%, #D9DCE2 46%, #C8CFD7 100%)` |
| Chrome surface | `rgba(247,246,249,0.66)` |
| Sidebar surface | `rgba(250,249,252,0.58)` |
| Player bar surface | `rgba(252,251,253,0.62)` |
| Card surface | `rgba(255,255,255,0.58)` |
| Card surface, raised | `rgba(255,255,255,0.86)` |
| Content surface | `#FFFFFF` |
| Quran surface | `#FDFBF7` |
| Quran text | `#1A1613` |
| Primary label | `#000000` |
| Secondary label | `#8A8A8E` |
| Tertiary label | `rgba(0,0,0,0.35)` |
| Hairline | `rgba(0,0,0,0.12)` |
| Interaction accent | `#007AFF` |
| Accent fill | `rgba(0,122,255,0.12)` |
| Accent wash | `rgba(0,122,255,0.10)` |
| Accent glow | `rgba(0,122,255,0.35)` |
| Reciter artwork accent | `#34C759` |
| Ornament surface | `#FBF6EC` |
| Ornament border | `#B08A3E` |
| Ornament title | `#6B5220` |
| Ornament subtitle | `#8A6E33` |
| Field surface | `rgba(255,255,255,0.5)` |
| Segmented track | `rgba(120,120,128,0.14)` |
| Material blur | `saturate(180%) blur(26px)` |

These are semantic brand references, not a requirement to ignore platform colors, contrast rules or appearance modes. Each application maps the roles to native visual conventions while retaining Tilawa's calm identity.

### Typography

- Use the platform system font for interface labels and controls.
- Use a bundled Quran font for the Quran surface. Never depend on the user having it installed.
- Preserve Arabic shaping, marks, bidi controls and line readability.
- Support native text scaling without clipping or hiding controls.
- The reader provides its own text-size decrease and increase controls, independent of the system size.

Open item: the redesign names Scheherazade New first, with Amiri Quran as the fallback. P0 selected Amiri Quran. Both use the SIL Open Font License 1.1. Confirm the primary face before bundling the binary.

### Reciter identity

Reciters use an initial-letter avatar over the artwork accent. Version 1 ships no reciter photographs and no provider imagery.

### Reading mode decision

Version 1 uses accessible, reflowing Unicode Quran text with a bundled verified font. This supports responsive layouts, copying, search and assistive technology.

An exact fixed-page Mushaf is a later, separate reading mode. If built, it uses one verified page-image set with matching ayah bounds plus an accessible Unicode representation. Tilawa will not build multiple competing Mushaf rendering systems at the same time.

### Design source

The canonical macOS direction is the Claude Design project [Tilawa macOS design direction](https://claude.ai/design/p/00ceec80-f100-4f4c-bc92-22605c66b612), file `Tilawa macOS - Redesign copy 2.dc.html`. It defines nine frames in four flow sections:

| Flow section | Frames |
|---|---|
| Browse and listen | Reciters, Reciter detail, Recording edition, Reader, Reader focus mode |
| Recently played | Flat history with resume |
| Downloads | Storage budget and transfers |
| Collections | Favorites, one user collection |

The macOS implementation is the living behavioral reference. This product document wins when a mockup conflicts with an accepted product decision.

## Content and playback model

### Catalog and audio

- MP3Quran is the v1 reciter catalog, recording, continuous-surah audio and available ayah-timing source.
- A recording edition is identified by provider, reciter, riwayah, style and recording revision.
- Featured reciters are editorial ordering, not a popularity score from the provider.
- Provider IDs are resolved from verified catalog data and are never guessed.

### Quran text

- Quran text and chapter metadata are bundled for fully offline reading.
- The checksum-pinned bundled Hafs text is approved for use unchanged. On 2026-09-21 the product owner confirmed that its license is free and permits use as-is; this resolves the license decision. No specific license identifier or exact upstream URL has been supplied.
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

### Offline downloads and storage

- A download is keyed by recording edition and surah.
- Visible states are not downloaded, downloading, downloaded and failed.
- A verified local file is preferred before network access.
- Downloaded playback works after quitting, disabling the network and reopening the application.
- Partial, missing or corrupt files are reconciled and never presented as ready.
- Removing a download removes both the file and its durable metadata.
- Durable metadata records the byte size and bitrate of every file, so Downloads reports real usage.
- The user sets a storage budget. Tilawa reports used size against that budget and groups usage by reciter.
- Tilawa never deletes a download to stay inside the budget. It stops new downloads and explains why.

### Library history and resume

- A listening session is keyed by recording edition and surah.
- A session records the last media position, the derived ayah when timing exists, the heard fraction and the last-played time.
- History is one flat list, newest first, grouped by day.
- Replaying a surah updates the existing session instead of adding a duplicate.
- Resume restores the recording and seeks to the stored media position.
- The user can remove one session or clear the whole history. Removal is immediate and local.
- History is device-local in version 1. There is no account and no synchronization.

### Collections, favorites and ayah bookmarks

- Favorites is a pinned collection. It always exists. It cannot be renamed, reordered or deleted.
- A user collection has a name, a manual order and its own items.
- A collection item is a recording: edition plus surah. It is never a bare surah number.
- An ayah bookmark records edition, surah, ayah and media position. It opens the reader at that ayah and can start audio at that position.
- A collection reports its total duration, reciter count and offline coverage.
- If the underlying recording leaves the catalog, the item stays visible and is clearly marked unavailable.

### Search and filtering

- Search is entity search over reciters, editions, surahs, history, downloads and collection items. It is not Quran text search.
- Search matches English names, Arabic names and transliterations.
- The surah jump field also accepts a surah number.
- Matching uses normalized text. Display text stays verbatim.
- Reciter filters are riwayah, recitation style and Verse Sync. Filters combine, and one action clears them.
- A successful search with no match is a no-results state, not a failure.

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
- [ ] Show one entry per reciter with English and Arabic names and an initial-letter avatar.
- [ ] Order the curated featured collection first while retaining the full catalog.
- [ ] Open a reciter-detail screen.
- [ ] Group recording editions by riwayah and then style.
- [ ] Show edition availability, capability badge and featured status.
- [ ] Open a recording-edition screen listing every surah in that edition.
- [ ] Show per-surah length, ayah count and offline state in the edition list.

### Search and filtering

- [ ] Search reciters, surahs, history, downloads and collection items by English name, Arabic name or transliteration.
- [ ] Accept a surah number in the reader jump field.
- [ ] Filter reciters by riwayah, recitation style and Verse Sync, and clear all filters in one action.
- [ ] Sort an edition's surahs in mushaf order.
- [ ] Show a no-results state that is distinct from a failure state.
- [ ] Keep normalized matching text separate from verbatim display text.

### Playback

- [ ] Stream one continuous file per surah.
- [ ] Show a persistent player bar on every screen, with the current surah, reciter and style.
- [ ] Provide play/pause, previous, next, seek, elapsed time, duration and volume.
- [ ] Show timing-aware seek markers for timed recordings and a plain scrubber otherwise.
- [ ] Keep playback alive while navigating anywhere in the application.
- [ ] Play all and shuffle an edition or a collection.
- [ ] Continue through available surahs without selecting unavailable recordings.
- [ ] Report real loading, buffering, playing, paused, ended and failed states.
- [ ] Handle rapid selection without allowing stale requests to replace the newest choice.
- [ ] Integrate native background playback, interruptions, media keys and system controls.

### Read-along reader

- [ ] Open and close the reader from the player bar chip, without interrupting audio.
- [ ] Show the ayah position in the chip, and fill the chip with the accent while the reader is open.
- [ ] Render the Quran surface with surah heading, Makki/Madani classification, ayah count and ayah markers.
- [ ] Provide reader text-size decrease and increase, independent of the system text size.
- [ ] Provide a focus mode that hides the sidebar and surah pane while audio continues.
- [ ] Provide a surah pane with total and offline counts, a jump field, and all/offline/recent filters.
- [ ] Preserve Quran text exactly, and never show it for an incompatible edition.
- [ ] Explain the disabled reader for an `Audio only` recording.

### Existing audio timing

- Preserve the current timing-aware seek markers and ayah highlighting as-is.
- Continue using a plain scrubber when timing is unavailable or invalid.
- Defer timing and text-synchronization changes until the recording-revision binding is proved.

### Recently played and resume

- [ ] Record a session per recording edition and surah, with media position, ayah, heard fraction and last-played time.
- [ ] Show a continue-listening card with the stopped position, the remaining time and a resume action.
- [ ] List history newest first, grouped by day, with a session count.
- [ ] Update an existing session on replay instead of creating a duplicate.
- [ ] Remove one session, and clear the whole history.
- [ ] Survive application restart.

### Collections, favorites and bookmarks

- [ ] Provide a pinned Favorites collection that cannot be renamed, reordered or deleted.
- [ ] Create, rename, reorder, edit and delete user collections.
- [ ] Add and remove recordings, and keep the manual order of a user collection.
- [ ] Create ayah bookmarks that open the reader at that ayah and can start audio at the stored position.
- [ ] Show per-collection duration, reciter count and offline coverage.
- [ ] Mark an item unavailable when its recording leaves the catalog, without losing the item.
- [ ] Survive application restart.

### Offline use and storage

- [ ] Download a selected edition's surah, and download a whole edition or collection.
- [ ] Show durable download progress and state.
- [ ] Prefer verified local audio before the network.
- [ ] Play after application restart with the network disabled.
- [ ] Detect and recover from interrupted, missing and corrupt downloads.
- [ ] Show a storage budget with used size, reserved size, file count and per-reciter usage.
- [ ] Let the user set the reserved size, and stop new downloads at the limit instead of deleting files.
- [ ] Group downloads by reciter, and filter by all, downloading and on-device.

### Reliability and accessibility

- [ ] Use explicit loading, empty, no-results, unavailable, offline, error and retry states.
- [ ] Apply timeouts and preserve cancellation.
- [ ] Allow a failed first request to succeed on retry.
- [ ] Support keyboard navigation, focus, screen readers and platform text scaling throughout, without regressing RTL or Arabic rendering.
- [ ] Meet platform contrast, touch-target and pointer-target requirements, including over translucent materials.
- [ ] Provide equivalent behavior across all five applications using native components.

## Later features

Add these only after the complete v1 flow is reliable on all supported platforms:

- Repeat surah, ayah or a selected ayah range.
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
- Reciter photographs or provider imagery.
- Features shown only as inert controls.

## Product state requirements

Every primary screen must define:

- Initial loading.
- Successful content.
- Empty content.
- A no-results state for a search or filter.
- Offline with usable local content.
- Offline without required content.
- Unavailable recording or surah.
- Recoverable failure with retry.
- Non-recoverable content incompatibility with a clear explanation.

Playback additionally defines preparing, buffering, playing, paused, interrupted, ended and failed states. The UI must reflect observed player state rather than the last button pressed.

The player bar additionally defines a no-recording state, an untimed state with no ayah position and a disabled-reader state for `Audio only` recordings.

Downloads additionally defines a storage-budget-reached state.

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
2. Search and filter the catalog, then clear the filters.
3. Choose a reciter, riwayah and style.
4. Open the edition and see every surah with its length and offline state.
5. Start Al-Fatihah and see the player bar take over.
6. Pause, resume and seek from the player bar.
7. Open the reader from the player bar chip, follow the text, enter focus mode, then close the reader with audio still playing.
8. Navigate to another library destination without stopping playback.
9. Switch to another available surah and seek safely.
10. Control playback through the platform's native media surface.
11. Download a surah, quit, disable the network, relaunch and play it.
12. Read the storage budget, and see the download grouped under its reciter.
13. Stop mid-surah, reopen Recently Played and resume at the stored position.
14. Add a recording to Favorites, create a collection, add the recording to it and play the collection.
15. Bookmark an ayah and reopen the reader at that ayah.
16. Recover from a failed request without restarting the application.
17. Complete the whole flow with keyboard or assistive technology where the platform supports it.

## Version 1 product implementation plan

This plan turns the feature list above into product increments. Technical phase IDs refer to the implementation plan in `TECH.md`.

### Delivery policy

- Complete and approve each behavior on macOS first.
- Treat macOS as the reference for feature meaning, content and states.
- Translate that behavior to native platform patterns rather than copying macOS layout.
- Ship no visible control without working behavior.
- Keep later features out of v1 implementation and design work.
- Prefer one complete reciter-to-offline-playback journey over partial catalog-wide coverage.
- Build the listening chain before the library destinations that decorate it.
- Do not start fixed-page Mushaf, word-timing or translation work during v1.

### Current product baseline

| Platform | Current product state | First required outcome |
|---|---|---|
| macOS | The three-screen flow and the earlier flat visual direction exist as a proof of concept | Rebuild against the redesign: eight screens, the persistent player bar, the reader overlay and the translucent material direction |
| Android | Product UI not started | Native compact and expanded-width v1 journey |
| iOS | Product UI not started | Native iPhone and iPad v1 journey |
| Windows | Product UI not started | Native installed x64 v1 journey |
| Linux | Product UI not started | Native installed GNOME x64 v1 journey |

### Product increment map

```text
P0 Lock v1 content and interaction contract
└── P1 Reciter discovery
    └── P2 Recording selection
        └── P3 Edition surah browsing
            └── P4 Continuous playback and the persistent player bar
                └── P5 Read-along reader
                    ├── P6 Library search and filtering
                    ├── P7 Recently played and resume
                    ├── P8 Collections, favorites and ayah bookmarks
                    └── P9 Offline downloads and storage
                        └── P10 Accessibility and failure recovery
                            └── P11 Five-platform release parity
```

P6 to P9 depend on the durable library store proved in `TECH.md` phase T2. They may run in parallel after P5.

### P0 — Lock the v1 product contract

Status: reopened on 2026-09-22 by the accepted redesign. Every content decision below still stands. The interaction contract now has to cover eight screens, the persistent player bar and the library destinations, so the open items at the end of this section block P3 and later.

Outcome: implementation teams have one unambiguous eight-screen product to build.

Tasks:

- [x] Record the bundled Quran text edition, historical source attribution, revision, checksum and display name; retain the owner-confirmed free license for use as-is (2026-09-21).
- [x] Define the initial rule: bundled text is Hafs only (`rewaya_id = 1`); unknown and other provider riwayat stay audio-only.
- [x] Verify the featured-reciter names and preferred editions against live provider data without guessing IDs (2026-09-15; mapping below).
- [x] Define canonical English and Arabic terminology below.
- [x] Define the v1 labels and offline states below.
- [x] Confirm that untimed audio remains fully playable with no highlighted ayah.
- [x] Confirm that incompatible text editions are clearly audio-only.
- [x] Confirm reflowing Unicode text as the only v1 Quran renderer.
- [x] Select a Quran font under the SIL Open Font License 1.1. Amiri Quran was selected here. The redesign names Scheherazade New first, so the open item below decides the primary face.
- [x] Define compact, expanded and desktop arrangements in the canonical screens and platform expression checklist.
- [x] Adopt the redesign as the canonical macOS direction and record it under Design source (2026-09-22).
- [x] Define the three exclusive capability badges: Verse Sync, Full Audio and Audio only.
- [ ] Confirm the primary Quran font: Scheherazade New, which the redesign names first, or Amiri Quran, which P0 selected. Both are SIL OFL 1.1.
- [ ] Define the default storage budget and the range the user may set.
- [ ] Define history retention: a session cap, an age cap or neither.
- [ ] Define what the heard percentage counts, and when a session is complete.
- [ ] Define the shuffle rule for an edition and for a collection.
- [ ] Confirm the Arabic terms added to the table below.

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
| Recently Played | المشغّل مؤخرًا |
| Downloads | التنزيلات |
| Collections | المجموعات |
| Favorites | المفضلة |
| Ayah bookmark | علامة آية |
| Resume | متابعة |
| Play All | تشغيل الكل |
| Shuffle | تشغيل عشوائي |
| On Device | على الجهاز |
| Storage budget | حد التخزين |
| No results | لا نتائج |

The rows from Recently Played down are proposed. The product owner confirms them in P0 before any application ships them.

A successful empty list is an empty state, not a connection failure. A failed request presents the shared safe message and retry eligibility. Compatible bundled text remains readable without timing; incompatible riwayat show Audio Only, and the reader is disabled for them. Offline playback requires a locally verified file, with missing/partial/corrupt files removed from ready state. Compact layouts use native stacked destinations and a compact player bar that expands into the primary playback surface; expanded and desktop layouts use the native sidebar, the reader overlay and the persistent player bar as defined above.

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

Font: [Amiri Quran upstream](https://github.com/aliftype/amiri), [SIL OFL 1.1 notice](https://github.com/aliftype/amiri/blob/main/OFL.txt). The license family is established. The primary face is an open P0 item, and binary bundling with visual verification is P5 work.

The existing text's JSON and compiled verses match exactly. The product owner confirmed on 2026-09-21 that the license is free and the file may be used as-is. Retain the existing bytes and checksum. Exact upstream URL and license identifier remain unrecorded metadata, not a further approval prerequisite for using this file.

Technical dependency: T0 and the content portion of T1.

### P1 — Reciter discovery

Outcome: a user can reliably find and select a human reciter.

Tasks:

- [ ] Present featured reciters first without hiding the rest of the catalog.
- [ ] Show English and Arabic names together with an initial-letter avatar.
- [ ] Show a Verse Sync badge on a reciter with verified timing.
- [ ] Show the shown-of-total count beside the section header.
- [ ] Use a native grid where space supports it and a native list or adaptive grid where it does not.
- [ ] Build the sidebar with its Library and Collections groups and live counts.
- [ ] Give each interactive item clear hover, focus, pressed and selected behavior appropriate to the platform.
- [ ] Provide initial loading, successful content, empty catalog, offline failure and retry states.
- [ ] Preserve the latest selection when a stale request completes.
- [ ] Make the complete list reachable by keyboard, touch, pointer and screen reader.

Acceptance:

- Selecting a reciter always opens that reciter's details.
- A failed first request can be retried without relaunching.
- English and Arabic names remain readable at supported text sizes.
- Featured ordering is editorial data, not hard-coded UI duplication.
- Sidebar counts match the real contents of each destination.

Technical dependency: T1, followed by the relevant platform phase.

### P2 — Recording selection

Outcome: a user understands and selects the precise recitation they will hear.

Tasks:

- [ ] Show the selected reciter's English and Arabic identity and the summary line.
- [ ] Group editions by riwayah, then by style.
- [ ] Show available-surah count and one exclusive capability badge per style.
- [ ] State riwayah/text compatibility in plain language on each riwayah header.
- [ ] Mark only a verified preferred edition as featured.
- [ ] Offer the two hero actions: play the first available surah, and open the reader.
- [ ] Keep a one-riwayah, one-style reciter simple and immediately understandable.
- [ ] Explain unavailable or incompatible content without exposing provider implementation details.
- [ ] Return naturally to the reciter library using the platform's navigation convention.

Acceptance:

- Selecting an edition opens its surah list.
- Verse Sync, Full Audio and Audio only editions are visually distinguishable, and never combined.
- No selection can generate playback for a surah absent from that edition.

Technical dependency: T1, followed by the relevant platform phase.

### P3 — Edition surah browsing

Outcome: a user can see and start any surah inside one chosen edition.

Tasks:

- [ ] Show the edition hero with style, reciter, riwayah, surah count, ayah count, total duration and bitrate.
- [ ] List every surah with index, Arabic-Indic number, English name, Arabic name, ayah count, offline state and duration.
- [ ] Load the remaining surahs of a long edition progressively without blocking the first screen.
- [ ] Provide play all, shuffle and download all.
- [ ] Show the verified-timing badge only when timing is verified for that edition.
- [ ] Provide mushaf-order sorting and surah search inside the edition.
- [ ] Provide loading, empty, offline, unavailable and retry states.

Acceptance:

- Every listed surah either starts playback or explains why it cannot.
- The offline column matches the durable download record for that edition and surah.
- Phones show the same information as a native list without a horizontal table.

Technical dependency: T1 and T3, then T4 to T7.

### P4 — Continuous playback and the persistent player bar

Outcome: continuous listening works as one stable, native activity that survives all navigation.

Tasks:

- [ ] Make the player bar present on every screen, including the reader.
- [ ] Show the current surah, reciter, style and observed playback state in the bar.
- [ ] Load one continuous file for the selected surah.
- [ ] Implement play/pause, previous, next, seek, elapsed time, duration and volume.
- [ ] Show timing-aware seek markers for timed recordings, and a plain scrubber otherwise.
- [ ] Show the ayah-position chip, and hide the position for an untimed recording.
- [ ] Keep playback running while navigating anywhere in the application.
- [ ] Implement play all and shuffle for an edition and a collection.
- [ ] Show preparing, buffering, playing, paused, interrupted, ended and failed states from the actual player.
- [ ] Continue to the next available surah after completion.
- [ ] Expose now-playing information and transport controls through the native operating-system surface.

Acceptance:

- Playback does not create gaps between ayat by switching files.
- Changing screens never destroys playback.
- The interface never says "playing" merely because the play button was pressed.
- Previous and next never select an unavailable surah.

Technical dependency: T1 and T3, then T4 to T7.

### P5 — Read-along reader

Outcome: the muṣḥaf is a read-along surface that the player bar opens and closes.

Tasks:

- [ ] Open and close the reader from the player-bar chip only.
- [ ] Fill the chip with the interaction accent while the reader is open.
- [ ] Never interrupt, pause or restart audio when opening or closing the reader.
- [ ] Render the Quran surface with the surah heading, classification, ayah count, ayah markers and Arabic-Indic numbers.
- [ ] Emphasize the current ayah only when compatible timing exists.
- [ ] Add reader text-size decrease and increase, independent of the system text size.
- [ ] Add focus mode, which hides the sidebar and surah pane while audio continues.
- [ ] Add the surah pane with total and offline counts, the jump field and the all/offline/recent filters.
- [ ] Disable the reader for an `Audio only` recording and explain why.

Acceptance:

- Opening and closing the reader ten times leaves the media position unchanged.
- The jump field accepts a number, a transliteration and Arabic.
- Focus mode never pauses audio.
- No incompatible text is ever shown.

Technical dependency: T1 and T3, then T4 to T7.

### P6 — Library search and filtering

Outcome: a user finds any entity in the library by name.

Tasks:

- [ ] Search reciters, edition surahs, history, downloads and collection items.
- [ ] Match English names, Arabic names and transliterations using normalized text.
- [ ] Keep display text verbatim and never normalize what is shown.
- [ ] Filter reciters by riwayah, recitation style and Verse Sync, with combining filters.
- [ ] Clear all filters in one action.
- [ ] Show a no-results state that is visually distinct from a failure state.
- [ ] Keep search responsive while a catalog request is still running.

Acceptance:

- An Arabic query and an English query find the same reciter.
- No result is a no-results state, never an error or an empty screen.
- Clearing the filters restores the full catalog without a new request failure.

Technical dependency: T1 and T2, then the relevant platform phase.

### P7 — Recently played and resume

Outcome: a user returns to what they were listening to.

Tasks:

- [ ] Record a session per recording edition and surah.
- [ ] Store media position, derived ayah, heard fraction and last-played time.
- [ ] Update an existing session on replay instead of adding a duplicate.
- [ ] Show the continue-listening card with the stopped position, remaining time and a resume action.
- [ ] Group history by day, newest first, with a session count.
- [ ] Remove one session, and clear the whole history.
- [ ] Survive application restart.

Acceptance:

- Resume restores the same recording and seeks to the stored position.
- Stopping mid-surah, quitting and relaunching still offers the correct resume point.
- Clearing history removes every durable record, not only the visible list.

Technical dependency: T2, then the relevant platform phase.

### P8 — Collections, favorites and ayah bookmarks

Outcome: a user keeps chosen recitations and ayat together.

Tasks:

- [ ] Provide a pinned Favorites collection that cannot be renamed, reordered or deleted.
- [ ] Create, rename, reorder, edit and delete user collections.
- [ ] Add and remove recordings, and keep a user collection's manual order.
- [ ] Store a collection item as edition plus surah, never as a bare surah number.
- [ ] Create ayah bookmarks holding edition, surah, ayah and media position.
- [ ] Open a bookmark into the reader at that ayah, and start audio at the stored position.
- [ ] Show per-collection duration, reciter count and offline coverage.
- [ ] Keep an item visible and clearly unavailable when its recording leaves the catalog.
- [ ] Survive application restart.

Acceptance:

- Playing a collection plays its items in its manual order.
- A bookmark reopens the same ayah in the same recording after restart.
- Deleting a user collection never deletes the underlying downloads.

Technical dependency: T2, then the relevant platform phase.

### P9 — Offline downloads and storage

Outcome: downloads and playback work reliably without a network, and the user controls disk use.

Tasks:

- [ ] Show not-downloaded, downloading, downloaded and failed states.
- [ ] Keep the download associated with its exact recording edition and surah.
- [ ] Download a single surah, a whole edition and a whole collection.
- [ ] Prefer a verified local file before contacting the network.
- [ ] Reconcile incomplete, missing and corrupt files.
- [ ] Preserve completed downloads and their metadata through application restart.
- [ ] Record byte size and bitrate per file.
- [ ] Show the storage budget with used size, reserved size, file and reciter counts, and per-reciter usage.
- [ ] Let the user set the reserved size.
- [ ] Stop new downloads at the limit and explain why, instead of deleting files.
- [ ] Group by reciter, and filter by all, downloading and on-device.

Acceptance:

- Download, quit, disable network, relaunch and play succeeds.
- A damaged file is not shown as ready and offers a recoverable action.
- Reported usage matches the real bytes on disk after reconciliation.
- Reaching the budget never removes a file the user downloaded.

Technical dependency: T1, T2 and each platform's native player and download implementation.

### P10 — Accessibility and failure recovery

Outcome: the whole product remains understandable and operable beyond the happy path.

Tasks:

- [ ] Provide accessible names, roles, state and value for every interactive control, including the player-bar chip.
- [ ] Preserve logical focus order in RTL and LTR interface contexts.
- [ ] Support native text scaling without clipping player metadata, table columns or controls.
- [ ] Support keyboard operation on desktop and external-keyboard operation where expected on mobile.
- [ ] Announce loading completion, playback failure, download completion and reader open and close.
- [ ] Verify text contrast over every translucent material in both the light appearance and the platform's increased-contrast setting.
- [ ] Make retry available for recoverable catalog, edition, timing, playback and download failures.
- [ ] Preserve cancellation so navigating away does not produce a delayed error or stale screen.
- [ ] Use respectful, plain-language error copy without exposing URLs, exception names or provider internals.

Acceptance:

- Every acceptance-journey step completes with the platform screen reader.
- The desktop journey completes without a pointer.
- Large text does not hide the selected reciter, edition or primary playback control.
- Reduced-transparency and increased-contrast settings keep every label readable.
- A recoverable failure never requires an application restart.

Technical dependency: included in T3 to T8, not deferred to a post-v1 cleanup phase.

### P11 — Five-platform release parity

Outcome: users receive the same Tilawa v1 product through five native experiences.

Tasks:

- [ ] Record the macOS reference journey and state screenshots after P1 to P10 pass.
- [ ] Verify equivalent Android behavior on compact and expanded widths.
- [ ] Verify equivalent iOS behavior on iPhone and iPad layouts.
- [ ] Verify equivalent Windows behavior from the installed x64 package.
- [ ] Verify equivalent Linux behavior from the installed x64 Flatpak.
- [ ] Compare labels, catalog ordering, content identity, selected edition, capability badges and error meanings across platforms.
- [ ] Verify that history, collections, bookmarks and download records survive restart on every platform.
- [ ] Verify each platform uses native navigation and controls rather than macOS-shaped replacements.
- [ ] Close every v1 parity gap or remove the unsupported feature from all v1 applications.

Acceptance:

- Every step in the version 1 acceptance journey passes on all five platforms.
- All version 1 feature-list checkboxes are supported by evidence.
- Quran text and content validation and licenses are complete.
- No later-feature control is visible.

Technical dependency: T8.

## Platform expression checklist

| Product element | macOS reference | Android expression | iOS expression | Windows expression | Linux expression |
|---|---|---|---|---|---|
| Library navigation | Translucent sidebar with grouped destinations and counts | Adaptive navigation: bar on compact, rail or drawer when wide | `NavigationSplitView` sidebar, tab bar on compact iPhone | `NavigationView` pane with grouped menu items | Adwaita navigation split view |
| Reciter browsing | Spacious native grid of translucent cards | Adaptive Material grid/list | SwiftUI adaptive grid/list | WinUI adaptive grid | GTK/libadwaita adaptive grid/list |
| Recording hierarchy | Detail screen with riwayah sections | Native destination and sections | Native destination and sections | Native page and grouped items | Adwaita navigation page and groups |
| Edition surah list | SwiftUI `Table` with sortable columns | `LazyColumn` rows with secondary text | `List` rows, `Table` on iPad | WinUI `ListView` or `DataGrid` | Adwaita list rows or a column view |
| Persistent player | Bottom bar in the window, always visible | Compact bar above the navigation bar, expandable to a full sheet | Compact bar above the tab bar, expandable to a full sheet | Bottom bar in the window frame | Bottom bar in the Adwaita toolbar view |
| Reader | Overlay opened from the player-bar chip | Full-screen destination opened from the expanded player | Full-screen cover or sheet from the expanded player | Overlay page from the bar | Adwaita navigation page from the bar |
| Surah pane | Trailing pane inside the reader | Bottom sheet or side pane by width | Sheet on iPhone, trailing column on iPad | Inline pane | Adwaita sidebar or sheet |
| Recently played | Grouped list with a continue-listening card | Grouped `LazyColumn` with a hero card | Sectioned `List` with a hero card | Grouped `ListView` with a hero card | Adwaita preference-style groups |
| Downloads and storage | Budget bar, per-reciter groups | Same content with Material progress and groups | Same content with SwiftUI progress and sections | Same content with WinUI `ProgressBar` and expanders | Same content with Adwaita groups and level bars |
| Collections | Sidebar entries plus a collection screen | Sidebar/drawer entries plus a destination | Sidebar or tab entries plus a screen | Menu entries plus a page | Sidebar rows plus a page |
| Search and filter | `.searchable` field plus filter chips | `SearchBar` plus `FilterChip` | `.searchable` plus a filter menu | `AutoSuggestBox` plus filter controls | `Adw.EntryRow` search plus toggle filters |
| Material and depth | Translucent blurred chrome over a window wall | Material 3 surfaces and tonal elevation | System materials | Mica and acrylic | Adwaita styles; opaque where no equivalent exists |
| System playback | Apple Now Playing and media keys | Media notification and system session | Control Center and lock screen | Windows media controls | MPRIS desktop controls |

This table defines equivalent product roles, not component dimensions or pixel specifications.

## Version 1 release gates

Release is blocked by any of the following:

- Incorrect, unidentified or unlicensed Quran text.
- Text displayed for an incompatible riwayah or recording without an Audio only label.
- False ayah highlighting caused by invalid timing or an independent clock.
- Downloads reported as ready but unavailable after restart.
- Playback tied to a disposable screen lifecycle.
- Opening or closing the reader disturbing playback.
- A player bar missing from any screen, or showing state the engine did not report.
- History, collections, bookmarks or download records lost on restart.
- Reported storage usage that does not match the bytes on disk.
- An automatic deletion of a user's download.
- Missing native media controls or interruption handling.
- A primary flow that cannot recover from a transient network failure.
- A supported platform missing a v1 feature without an explicit product-scope change.
- An inaccessible primary action, an unreadable scaled layout, or text that fails contrast over a translucent material.
- An inert control advertising a later feature.

## Later-feature freeze

Repeat modes, verified seamless surah transitions, Quran text search, copy and share, fixed-page Mushaf rendering, word-level timing, translations, tafsir, additional providers, dark appearance, accounts and synchronization remain in the later backlog until P11 and T8 pass. Their models, controls and infrastructure are not created during v1 unless required to remove a correctness or data-loss risk.

Favorites, bookmarks, history, saved progress, shuffle, search and the downloads manager left this freeze on 2026-09-22. The accepted redesign makes them version 1 scope.
