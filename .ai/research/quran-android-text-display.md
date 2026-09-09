# How quran_android displays Quran text

Source: [quran/quran_android](https://github.com/quran/quran_android) (`main`, reviewed 2026-09-07).

quran_android does **not** typeset the mushaf from Unicode at runtime for the main reading view. The printed page look is pre-rendered images. Arabic as real text only appears in translation/tafsir mode.

If Tilawa wants the same mushaf look: page or line images plus an ayah-bounds DB. Use a Uthmanic font + Arabic database only for searchable / translation / share text.

## Three display modes

The pager (`QuranPageAdapter`) switches between:

- **Arabic mushaf page** — `QuranPageFragment` (phone) or `TabletFragment` in Arabic mode
- **Translation/text page** — `TranslationFragment` (or tablet translation/split)
- **Line-by-line mushaf** — injected via `PageViewFactory` (`feature/linebyline`) when the selected page type is `PageContentType.Line`

`PageProvider.getPageContentType()` is `Image` by default (Madani) or `Line(ratio, lineHeight, allowOverlap)`.

| What you see | How it is drawn |
|---|---|
| Mushaf page | Pre-rendered PNG + overlay geometry |
| Line-by-line mushaf | 15 ALPHA_8 line PNGs + Compose overlays |
| Translation screen | `TextView` + Uthmanic (or other) font from `quran.ar.db` |
| Night mushaf | Invert/tint the **image**, not a font color |
| Ayah tap / audio follow | `ayahinfo` (or line-by-line bounds DB), not text layout |

## 1. Full-page mushaf images (default Madani)

This is the classic Quran for Android view.

- Pages are **PNGs of a typeset mushaf** (Madani images from [quran.com-images](https://github.com/quran/quran.com-images); other flavors use licensed naskh/qaloon/warsh sets).
- Files are named `page001.png` … `page604.png`.
- They are stored by screen width, e.g. `width1260/page003.png`, and fetched from `https://android.quran.com/data/width{width}/…` if missing locally (`QuranFileUtils` / `QuranDisplayHelper.getQuranPage`).
- `QuranPageLoader` loads bitmaps off the UI thread and puts them in `HighlightingImageView` (an `AppCompatImageView`).
- **Night mode** inverts the bitmap with a `ColorMatrixColorFilter` (not a separate dark asset).
- Sura name, juz/hizb, and page number are **drawn as overlay text** on top of the image (`overlayText`), using the UthmanTN header font — they are not part of the PNG.

The Arabic on the page is pixels, so taps/highlights cannot use `TextView` selection. Instead:

- A matching SQLite DB `ayahinfo{width}.db` is downloaded (`ayahinfo_1260.db`, etc.).
- `AyahInfoDatabaseHandler` reads a `glyphs` table: `page_number, line_number, sura_number, ayah_number, position, min_x/min_y/max_x/max_y`, plus optional `glyph_type`.
- Glyphs on the same line of the same ayah are merged into `AyahBounds`. Optional glyph-level data builds `PageGlyphsCoords` for **word-level** audio highlight.
- Extra tables: `ayah_markers` (ayah-number glyph positions) and `sura_headers`.
- `HighlightsDrawer` paints those rects **on top of the image** with modes:
  - `HIGHLIGHT` — translucent box on the ayah
  - `BACKGROUND` — full-line wash
  - `UNDERLINE`
  - `COLOR` / `HIDE` — color-filter or clip the image **before** `super.onDraw()` so individual words can be tinted or hidden
- Audio can “float” the highlight between ayahs with a `ValueAnimator`.

Highlighting works because geometry is stored separately from the picture, then scaled with the image matrix.

### Key files

- `app/.../view/HighlightingImageView.java` — night-mode filter, overlay text, highlight draw order
- `app/.../ui/fragment/QuranPageFragment.kt` — page UI, presenter, tap → `AyahTrackerPresenter`
- `app/.../ui/helpers/QuranPageLoader.kt` — async bitmap load + OOM / alternate-width fallback
- `app/.../ui/helpers/QuranDisplayHelper.java` — SD then web fetch
- `app/.../util/QuranFileUtils.kt` — `page###.png`, `ayahinfo{width}.db` / `.zip` URLs
- `app/.../data/AyahInfoDatabaseHandler.java` — glyph/ayah/sura-header bounds
- `pages/madani/.../MadaniPageProvider.kt` — image version 8, `https://android.quran.com/data`
- `common/data/.../PageProvider.kt`, `PageContentType.kt`

## 2. Line-by-line images (Compose)

Same idea, sliced into **15 line PNGs per page** instead of one full page:

- Path: `{imagesDir}/{pageNumber}/{1..15}.png`
- Loaded in `QuranLineByLinePresenter.linesForPage()`, decoded as `ALPHA_8` (`extractAlpha()`) so the ink can be tinted for night mode
- `QuranLine` draws each line `ImageBitmap` on a Compose `Canvas`, stacked with a fixed width/height ratio (`PageContentType.Line.ratio`)
- Sura headers, ayah markers, selection/audio/bookmark highlights, and optional sideline images are separate Compose overlays
- If a line file is missing, it throws `MissingLineByLineImagesException` and can **fall back** to the full-page image type

This still is not live Arabic layout — it is cropped mushaf line art plus coordinate overlays.

### Key files

- `feature/linebyline/.../ui/QuranLine.kt`, `QuranPage.kt`
- `feature/linebyline/.../presenter/QuranLineByLinePresenter.kt`
- `feature/linebyline/.../model/LineModel.kt`, `PageInfo.kt`
- `feature/linebyline/.../resource/ImageBitmapUtil.kt`

## 3. Translation view (actual Arabic text)

When translation mode is on, the app **does** render Unicode:

- `TranslationAdapter` is a `RecyclerView` of rows: sura header, basmallah, **Quran Arabic**, translator name, translation/tafsir, verse number, spacer
- Arabic comes from SQLite `quran.ar.db` via `ArabicDatabaseUtils` / `DatabaseHandler` (README: QuranEnc, King Saud University, some Tanzil)
- That string is shown in a `TextView` with an `UthmaniSpan` → `TypefaceManager.getUthmaniTypeface()`
- Default Madani font: `uthmanic_hafs_ver12.otf` (Warsh/Qaloon/Noor Hayah flavors swap the asset)
- Basmallah is stripped from ayah 1 when the DB already prefixed it
- Translations/tafsir are normal text (Arabic tafsir uses `kitab.ttf`; optional OpenDyslexic)
- Highlighting here is row background color, not glyph boxes

### Fonts (`TypefaceManager`)

| Constant | Asset |
|---|---|
| Default (Hafs) | `uthmanic_hafs_ver12.otf` |
| Noor Hayah | `noorehira.ttf` |
| Warsh | `uthmanic_warsh_ver09.ttf` |
| Qaloon | `uthmanic_qaloon_ver21.ttf` |
| Tafsir | `kitab.ttf` |
| Dyslexic | `OpenDyslexic.otf` |
| Header/footer | `UthmanTN1Ver10.otf` |

### Key files

- `app/.../ui/translation/TranslationAdapter.kt`, `TranslationView.java`, `TranslationViewRow.kt`
- `app/.../ui/helpers/UthmaniSpan.kt`
- `app/.../ui/util/TypefaceManager.kt`
- `app/.../model/translation/ArabicDatabaseUtils.kt`

## Implications for Tilawa

- Matching a printed mushaf page means shipping (or downloading) **images + bounds**, not laying out Unicode with a font.
- Unicode + Uthmanic font is the right path for translation, search, share, and any non-mushaf reading mode.
- Night mode for mushaf is image invert/tint (`ColorMatrix` or ALPHA_8 recolor), not text color.
- Ayah tap, selection, and audio follow need a coordinate database aligned to the image set and width.
