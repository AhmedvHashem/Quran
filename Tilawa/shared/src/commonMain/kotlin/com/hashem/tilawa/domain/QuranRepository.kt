package com.hashem.tilawa.domain

import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.Verse

/**
 * The domain's port onto the Quran catalogue. Implemented in `data`, so nothing
 * below this interface knows about HTTP, JSON, or external APIs.
 */
interface QuranRepository {
    suspend fun reciters(): List<Reciter>
    suspend fun editions(reciterId: Int): List<RecitationEdition>
    suspend fun chapters(): List<Chapter>
    suspend fun verses(chapterId: Int): List<Verse>
    suspend fun playbackTrack(chapterId: Int, editionId: Int): PlaybackTrack
}
