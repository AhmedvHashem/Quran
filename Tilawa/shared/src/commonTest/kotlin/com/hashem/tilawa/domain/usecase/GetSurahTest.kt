package com.hashem.tilawa.domain.usecase

import com.hashem.tilawa.domain.QuranRepository
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.Riwayah
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

private class FakeRepository(
    private val editionsList: List<RecitationEdition> = emptyList(),
    private val track: PlaybackTrack = PlaybackTrack("", emptyList(), null),
) : QuranRepository {
    override suspend fun reciters(): List<Reciter> = emptyList()
    override suspend fun editions(reciterId: Int): List<RecitationEdition> = editionsList
    override suspend fun chapters(): List<Chapter> = emptyList()
    override suspend fun verses(chapterId: Int): List<Verse> = track.verses
    override suspend fun playbackTrack(chapterId: Int, editionId: Int): PlaybackTrack = track
}

class GetSurahTest {

    @Test
    fun `returns playback track for surah and edition`() = runTest {
        val expectedTrack = PlaybackTrack(
            trackUrl = "https://server6.mp3quran.net/akdr/001.mp3",
            verses = listOf(Verse(1, "بِسْمِ ٱللَّهِ"), Verse(2, "ٱلْحَمْدُ لِلَّهِ")),
            timing = listOf(VerseTiming(1, 0, 5000), VerseTiming(2, 5000, 10000)),
        )
        val getSurah = GetSurah(FakeRepository(track = expectedTrack))

        val result = getSurah(chapterId = 1, editionId = 101)
        assertEquals(expectedTrack, result)
    }

    @Test
    fun `returns playback track without timing when untimed`() = runTest {
        val expectedTrack = PlaybackTrack(
            trackUrl = "https://server6.mp3quran.net/akdr/001.mp3",
            verses = listOf(Verse(1, "بِسْمِ ٱللَّهِ")),
            timing = null,
        )
        val getSurah = GetSurah(FakeRepository(track = expectedTrack))

        val result = getSurah(chapterId = 1, editionId = 102)
        assertEquals("https://server6.mp3quran.net/akdr/001.mp3", result.trackUrl)
        assertNull(result.timing)
    }

    @Test
    fun `GetRecitationEditions returns editions for reciter`() = runTest {
        val editions = listOf(
            RecitationEdition(
                id = 1,
                reciterId = 10,
                riwayah = Riwayah(1, "Hafs A'n Assem"),
                style = "Murattal",
                serverBaseUrl = "https://server.mp3quran.net/10/",
                availableSurahs = setOf(1, 2, 3),
                hasTiming = true,
            )
        )
        val getEditions = GetRecitationEditions(FakeRepository(editionsList = editions))

        val result = getEditions(10)
        assertEquals(editions, result)
    }
}
