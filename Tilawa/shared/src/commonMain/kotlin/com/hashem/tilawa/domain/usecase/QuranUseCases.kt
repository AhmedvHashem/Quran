package com.hashem.tilawa.domain.usecase

import com.hashem.tilawa.domain.QuranRepository
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.Verse

internal class GetReciters(private val repository: QuranRepository) {
    suspend operator fun invoke(): List<Reciter> = repository.reciters()
}

internal class GetRecitationEditions(private val repository: QuranRepository) {
    suspend operator fun invoke(reciterId: Int): List<RecitationEdition> = repository.editions(reciterId)
}

internal class GetChapters(private val repository: QuranRepository) {
    suspend operator fun invoke(): List<Chapter> = repository.chapters()
}

internal class GetVerses(private val repository: QuranRepository) {
    suspend operator fun invoke(chapterId: Int): List<Verse> = repository.verses(chapterId)
}

internal class GetSurah(private val repository: QuranRepository) {
    suspend operator fun invoke(chapterId: Int, editionId: Int): PlaybackTrack =
        repository.playbackTrack(chapterId, editionId)
}
