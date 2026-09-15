package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.domain.model.RevelationPlace
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class LocalQuranTextSourceTest {

    private val source = LocalQuranTextSource()

    @Test
    fun `loads all 114 chapters offline`() {
        val chapters = source.chapters()
        assertEquals(114, chapters.size)

        val fatihah = chapters.first()
        assertEquals(1, fatihah.id)
        assertEquals("Al-Fatihah", fatihah.name)
        assertEquals("The Opener", fatihah.translatedName)
        assertEquals("الفاتحة", fatihah.arabicName)
        assertEquals(7, fatihah.versesCount)
        assertEquals(RevelationPlace.MAKKAH, fatihah.revelationPlace)

        val baqarah = chapters[1]
        assertEquals(2, baqarah.id)
        assertEquals("Al-Baqarah", baqarah.name)
        assertEquals(286, baqarah.versesCount)
        assertEquals(RevelationPlace.MADINAH, baqarah.revelationPlace)

        val nas = chapters.last()
        assertEquals(114, nas.id)
        assertEquals("An-Nas", nas.name)
        assertEquals(6, nas.versesCount)
    }

    @Test
    fun `loads verses for a chapter offline`() {
        val verses = source.verses(1)
        assertEquals(7, verses.size)
        assertEquals(1, verses.first().number)
        assertTrue(verses.first().text.isNotBlank())
        assertEquals(7, verses.last().number)
    }

    @Test
    fun `total verse count across all chapters is 6236`() {
        val total = (1..114).sumOf { source.verses(it).size }
        assertEquals(6236, total)
    }

    @Test
    fun `bundled Hafs text is enabled and checksum pinned`() {
        assertTrue(source.manifest.isVerified)
        assertEquals(setOf(1), source.manifest.supportedRiwayahIds)
        assertEquals(64, source.manifest.checksumSha256.length)
    }

    @Test
    fun `parses from custom JSON payload correctly`() {
        val json = """
            {
              "chapters": [
                {
                  "id": 1,
                  "name": "Al-Fatihah",
                  "translatedName": "The Opener",
                  "arabicName": "الفاتحة",
                  "versesCount": 2,
                  "revelationPlace": "MAKKAH"
                }
              ],
              "surahs": {
                "1": [
                  { "number": 1, "text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ" },
                  { "number": 2, "text": "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ" }
                ]
              }
            }
        """.trimIndent()

        val customSource = LocalQuranTextSource.fromJson(json)
        assertFalse(customSource.manifest.isVerified)
        assertEquals(1, customSource.chapters().size)
        assertEquals(2, customSource.verses(1).size)
        assertEquals("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", customSource.verses(1).first().text)
    }
}
