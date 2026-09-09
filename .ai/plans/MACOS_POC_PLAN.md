# macOS PoC — Reciter Grid → Player

Source of truth: Figma `Tilawa App` (`6HAE3faqlNALYfTRcvQTAM`)
- `26:2` — Home – Reciter Grid
- `7:2` — macOS — SwiftUI / AppKit (sidebar + reading + player)
- `26:166` — annotation: *"Selecting a card navigates to the existing main screen
  (sidebar + reading + player), with this reciter pre-selected."*

Goal: pick a reciter → player screen opens on Al-Fatihah with verse 1 selected;
verses play, surah text renders.

## Split (per `AGENTS.md` / `.agents/skills/kmp-core`)

| Layer | Owns |
|---|---|
| `:shared` commonMain | quran.com API v4, domain models, verse+audio join |
| `macosApp` Swift | SwiftUI views, navigation, AVPlayer, theming |

Nothing UI-shaped crosses into `:shared`. Audio playback is Apple-side.

## Shared — clean architecture

```
commonMain/com/hashem/tilawa/
├── domain/
│   ├── model/QuranModels.kt     Reciter, Chapter, Verse, RevelationPlace
│   ├── QuranRepository.kt       the port; knows nothing about HTTP
│   └── usecase/QuranUseCases.kt GetReciters, GetChapters, GetSurah
├── data/
│   ├── remote/QuranApi.kt       Ktor + DTOs (internal)
│   └── QuranRepositoryImpl.kt   DTO → domain mapping
└── QuranLibrary.kt              composition root + the only public surface
```

`QuranLibrary` is the whole exported API — everything below it is `internal`, so
the Apple and C bridges see three calls and the domain models, nothing else.
`GetSurah` holds the one real piece of orchestration: text and recitation are
separate resources that the player needs as one ordered list.

Tests: `GetSurahTest` runs the join against a fake repository with no HTTP at
all; `QuranRepositoryImplTest` covers DTO mapping over Ktor's MockEngine.

Endpoints (verified Aug 2026, `per_page=300` returns full surahs):
- `/resources/recitations?language=ar` → English `reciter_name` + Arabic `translated_name`
- `/chapters?language=en`
- `/verses/by_chapter/{id}?fields=text_uthmani&per_page=300`
- `/recitations/{reciterId}/by_chapter/{id}?per_page=300` → paths under `https://verses.quran.com/`

## Swift — `macosApp/Sources/TilawaMac/`

```
App/            TilawaMacApp (composition root), AppRouter
DesignSystem/   Theme (Figma tokens), Glass (Liquid Glass seam)
Playback/       VersePlayer — one track at a time, no domain knowledge
Features/
  Reciters/     RecitersViewModel + ReciterGridView        (26:2)
  Player/       PlayerViewModel + PlayerScreen, ChapterSidebar,
                ReadingPane, PlayerBar                     (7:2)
```

`QuranLibrary` is built once in the app and injected into the view models; no
feature constructs its own. The verse cursor lives in `PlayerViewModel`, the
AVPlayer in `VersePlayer` — neither knows the other's job.

## Liquid Glass

All of it goes through `Surface` / `SurfaceGroup` in `DesignSystem/Glass.swift`,
the single `#available(macOS 26, *)` seam, so the package floor stays at
macOS 13 and older systems get the flat Figma fills. Applied to the reciter
cards (interactive, tinted on hover), the player bar, the play button and the
verse chip. No other file names a `Glass` type.

## Deliberate cuts

- Seek bar segments each verse **equally** — real widths need a per-verse
  duration prefetch (286 assets for Al-Baqarah). Marked `ponytail:` in code.
- Light mode only; the design has no dark variant.
- Shuffle / favourite toggle state only. Volume and repeat are wired.
- Errors surface as Swift `async throws` rather than a sealed domain type —
  sealed hierarchies don't cross the Obj-C bridge cleanly without SKIE.
- `Amiri Quran` via `Font.custom` — falls back to the system Arabic face when
  the font isn't installed.

## Verify

```bash
./gradlew :shared:allTests && ./gradlew :shared:assembleSharedReleaseXCFramework
cd macosApp && swift run
```
