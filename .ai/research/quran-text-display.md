# How Quran apps display Quran text

Researched 2026-09-13 through web search of popular open- and closed-source Quran apps.

## Spectrum

```
      Fidelity to the printed Mushaf  ◄──────────────►  Flexibility (reflow, size, styling)
 ┌──────────────┬──────────────┬─────────────────┬──────────────────┬───────────────────┐
 │ 1 Page images│ 2 Page SVG   │ 3 Per-page      │ 4 Justifying     │ 5 Unicode text +  │
 │   + bbox DB  │   + ayah     │   glyph fonts   │   variable font  │   one Quran font  │
 │              │   polygons   │   (QCF) + layout│   (DigitalKhatt) │   (reflowable)    │
 └──────────────┴──────────────┴─────────────────┴──────────────────┴───────────────────┘
       6 Tajweed colouring is layered on top of 1, 3, 4 or 5.
```

## 1. Page images plus a coordinate database

A raster image of each of the 604 pages, plus a SQLite "ayahinfo" table storing the bounding box of every word or ayah, which is what makes highlighting and tapping possible.

- **Used by:** Quran for Android (`quran/quran_android`, open), Quran.com iOS / QuranEngine (`quran/quran-ios`, open), Ayat by King Saud University (KFGQPC images, Tanzil text). Greentech Quran probably uses images for its non-Unicode Mushafs (Warsh, Qaloon, Shemerly, 1405, 1440); unconfirmed.
- **How it's made:** `quran/quran.com-images` renders the KFGQPC fonts into PNGs at widths 1024, 1260 and 1920 and records each glyph's bounds. `quran/ayah-detection` detects ayah markers in other editions' images (tested on Shamerly, Qaloon and Warsh).
- **Pros:** exactly matches the print, simplest to build, works for any riwayah and for scanned editions.
- **Cons:** large downloads, blurry when zoomed, no reflow, no per-letter styling.

## 2. Vector (SVG) pages with clickable ayah regions

Same idea as #1, but each page is an SVG and the ayah hit areas are paths.

- `quranpedia/quran-svg`: Hafs, Warsh, Qalun, Douri, Shu'bah; about 31k ayah polygons; about 5.3 GB full clone (sparse checkout per Mushaf); data CC BY 4.0, tools MIT. The Itqan CMS reader switched from DB-driven HTML text to this.
- `batoulapps/quran-svg`: MIT, batch-converted with Inkscape from the Complex's Adobe Illustrator files. Batoul Apps publishes the **Ayah** iOS app, but it is unconfirmed whether Ayah uses these files.
- `mushafdatabase/MushafDatabase-Ligature-Based-SVG`: 1441H edition, addressable down to lines, words, sub-words, diacritics and markers.
- `quran-ws/quran-engine`: native vector-page engine (QVP format) for web, iOS, Android, Flutter and React Native. Beta, unpublished.
- **Pros:** sharp at any size, keeps print fidelity. **Cons:** still fixed pages, heavy data, no text-level styling.

## 3. Per-page glyph fonts (QCF / QPC) plus layout data

Each page has its own font, and each word is a single glyph in it (604 fonts for V1 and V2; V4 packs them into 47 files).

- **Used by:** Quran.com web and the Quran Foundation API (`code_v1`, `code_v2`; V2 is the recommended "pixel-perfect" option), plus many apps built on QUL data.
- **Versions:**
  - V1: 1405H print (Uthman Taha).
  - V2: 1421/1423H print.
  - V4: 1441H print with built-in tajweed colours (COLRv1 with CSS `font-palette`; OT-SVG files for Firefox dark mode).
- **Layout table (QUL):** `page_number, line_number, line_type (ayah | surah_name | basmallah), is_centered, first_word_id, last_word_id, surah_number`. About 9,046 rows for the 604-page Madinah Mushaf. QUL ships 12 layouts: KFGQPC V1–V4, IndoPak 9/13/15/16-line, QPC Hafs, Uthmani.
- **Implementation notes:**
  - Fetch the glyph codes together with `text_qpc_hafs` and show the Unicode text as a fallback while a page's font loads.
  - Verse-end markers (`char_type_name == "end"`) render in the Unicode font.
  - Preload the current page's font and prefetch the neighbouring pages.
- **Pros:** real text (word-level tap, highlight, select), small, sharp, matches the print exactly.
- **Cons:** 604 fonts to load and cache, Hafs/Madani only, no reflow.

## 4. Unicode text with a justifying variable font

Real Unicode text laid out to Mushaf line breaks. Lines are fitted by stretching letters (kashida and stretchable parts) rather than by adding spaces.

- **Used by:** Tarteel (closed source; its data is open via QUL). It separates the problem into data, fonts and presentation layers, and renders to a Skia canvas.
  1. Pick the font size from the screen dimensions.
  2. Render each line iteratively with the justification algorithm.
  3. Apply character- and word-level styling.
  4. Record word coordinates for touch.
  - Workarounds: patched Skia for right-to-left Arabic, horizontal compression for extra-wide lines, and very long ayahs split across several canvases to stay under iOS Metal's texture height limit.
- **Font:** DigitalKhatt (open, Metafont-based, VisualMetaFont design tool, HarfBuzz fork that extends OpenType for Arabic justification). Digital Khatt V2 matches the 1420H Madani Mushaf.
- **Pros:** letter-level styling, animation, small assets, page layout preserved.
- **Cons:** the hardest to build, because stock HarfBuzz/CoreText don't do this kind of Arabic justification.

## 5. Unicode text in a single Quran font (reflowable)

An ordinary text view showing Tanzil or Quran.com Uthmani / IndoPak text in one font.

- **Used by:**
  - Muslim Pro (closed). Android offers IndoPak, Uthmani, no diacritics, Indonesian standard Mushaf and "compatible"; iOS drops "compatible".
  - Quran Majeed by Pakdata (closed). Uthmanic and IndoPak, 4 layouts.
  - Greentech's "Mushaf Unicode Text", and iQuran.
  - The translation and verse-by-verse screens of nearly every app, Quran.com included.
- **Common fonts:**
  - KFGQPC Uthmanic Script HAFS (most common; KFGQPC says it is for showing verses, not whole Mushaf pages)
  - KFGQPC Uthman Taha Naskh
  - me_quran
  - Scheherazade (SIL)
  - Amiri Quran
  - PDMS Saleem
  - IndoPak Nastaleeq / QuranWBW IndoPak
- **IndoPak variant:** Greentech and Quran.com fit IndoPak text into 13-, 15- and 16-line page layouts, which is #3's layout table applied to a Unicode font. The 15-line "Hafizi" Mushaf ends every page on a complete ayah.
- **Pros:** trivial to build, adjustable font size, and search, copy and accessibility come for free.
- **Cons:** not a Mushaf page, so it loses the spatial memory that people memorising the Quran depend on.

## 6. Tajweed colouring (added on top of another approach)

| Technique | Used by |
|---|---|
| Pre-coloured page images | Ayat (Tajweed Mushaf), 13- and 16-line tajweed apps |
| COLRv1 colour glyph fonts (QCF V4) | Quran.com |
| Tajweed-tagged Unicode text parsed into coloured spans | Muslim Pro (IndoPak, Uthmani, Indonesian scripts), Tarteel, Greentech, RecitID |

No general-purpose Unicode tajweed colour font exists (see `fawazahmed0/quran-api#12`), so apps parse tajweed metadata instead.

## Which apps use which approach

| App | Open source? | Main Mushaf view | Text / translation view |
|---|---|---|---|
| Quran for Android | ✅ | 1 Images + ayahinfo DB | 5 |
| Quran.com iOS (QuranEngine) | ✅ | 1 Images + ayahinfo DB | 5 |
| Quran.com web | ✅ | 3 QCF V1 / V2 / V4 | 5 |
| Tarteel | ❌ (data open via QUL) | 4 DigitalKhatt-style on Skia | 4 / 5 |
| Ayat (KSU) | ❌ | 1 KFGQPC images | 5 (Tanzil) |
| Greentech Quran | ❌ | 1 (probably) + IndoPak layouts | 5 |
| Ayah (Batoul) | ❌ | Madinah Mushaf pages (possibly 2 SVG; unconfirmed) | — |
| Muslim Pro | ❌ | 5 | 5 + 6 |
| Quran Majeed (Pakdata) | ❌ | 5 in Madina / IndoPak layouts | 5 |
| Itqan / Quranpedia | ✅ | 2 SVG + polygons | — |

## Recommendation for Tilawa (native apps on five platforms)

- **Mushaf view:** QCF V2/V4 plus the QUL layout table (#3). It works through each platform's native text stack, gives word-level interaction, is a few MB instead of hundreds, and V4 brings tajweed for free. Hafs/Madani only.
- **Translation and verse lists:** Unicode text with KFGQPC HAFS (#5).
- **Other riwayat (Warsh, Qalun):** images or quranpedia SVG (#1 or #2), since no glyph fonts exist for them.
- **Later:** a DigitalKhatt-style justifying renderer (#4). It gives the best results but means building a justification engine on every platform; only after #3 is working.

## Sources

- [Tarteel: From Page to Screen](https://tarteel.ai/blog/from-page-to-screen-rethinking-quran-rendering-for-the-digital-age/)
- [Tarteel: New Mushaf Layouts](https://tarteel.ai/blog/new-mushaf-layouts-now-available-on-tarteel-ai/)
- [Quran Foundation: Font Rendering](https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/)
- [Quran Foundation: Page Layout](https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/)
- [QUL: Glyph-based fonts](https://qul.tarteel.ai/docs/glyph-based)
- [QUL: Mushaf layout](https://qul.tarteel.ai/docs/mushaf-layout)
- [QUL fonts](https://qul.tarteel.ai/resources/font)
- [quran-qcf4](https://github.com/MohamadHajjRabee/quran-qcf4)
- [nuqayah/qpc-fonts](https://github.com/nuqayah/qpc-fonts)
- [quran_android](https://github.com/quran/quran_android)
- [quran-ios](https://github.com/quran/quran-ios)
- [quran.com-images](https://github.com/quran/quran.com-images)
- [ayah-detection](https://github.com/quran/ayah-detection)
- [quran-android-images-helper](https://github.com/murtraja/quran-android-images-helper)
- [DigitalKhatt](https://github.com/DigitalKhatt)
- [DigitalKhatt TUG paper](https://digitalkhatt.org/assets/TUG2021_preprint.pdf)
- [quranpedia/quran-svg](https://github.com/quranpedia/quran-svg)
- [batoulapps/quran-svg](https://github.com/batoulapps/quran-svg)
- [MushafDatabase SVG](https://github.com/mushafdatabase/MushafDatabase-Ligature-Based-SVG)
- [quran-ws/quran-engine](https://github.com/quran-ws/quran-engine)
- [Itqan SVG switch PR](https://github.com/Itqan-community/cms-frontend/pull/238)
- [Greentech Mushaf feature](https://gtaf.org/blog/mushaf-feature-in-quran-app/)
- [Greentech Tajweed colours](https://gtaf.org/blog/tajweed-colour-code-in-quran-app/)
- [Muslim Pro: Arabic text options](https://support.muslimpro.com/hc/en-us/articles/360028179412-How-to-change-Arabic-text-for-Quran)
- [Muslim Pro: Tajweed](https://support.muslimpro.com/hc/en-us/articles/115002005787-How-to-activate-the-coloured-Tajweed-for-Quran)
- [Ayat KSU](https://quran.ksu.edu.sa/index.php?ui=1&l=en)
- [Ayah on App Store](https://apps.apple.com/us/app/ayah-quran-app/id706037876)
- [Quran Majeed on App Store](https://apps.apple.com/us/app/quran-majeed-%D8%A7%D9%84%D9%82%D8%B1%D8%A7%D9%86-%D8%A7%D9%84%D9%83%D8%B1%D9%8A%D9%85/id365557665)
- [Tanzil Quranic fonts](https://tanzil.net/docs/quranic_fonts)
- [IndoPak Quran text](https://github.com/marwan/indopak-quran-text)
- [Quran Portal rendering blog](https://quranportal.io/blog/rendering-the-quran-mushaf-digitally)
- [fonts.quran.ws](https://fonts.quran.ws/)
- [Tajweed colour font issue](https://github.com/fawazahmed0/quran-api/issues/12)
