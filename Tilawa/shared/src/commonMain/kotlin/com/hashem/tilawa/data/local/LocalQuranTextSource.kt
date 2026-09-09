package com.hashem.tilawa.data.local

import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.Verse
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/**
 * Provides Quran text and chapter metadata locally without requiring any network calls.
 * Backed by bundled Uthmani text and chapter metadata.
 */
internal class LocalQuranTextSource(
    private val chaptersList: List<Chapter> = QuranTextData.chapters,
    private val versesProvider: (Int) -> List<Verse> = { QuranTextData.versesForChapter(it) },
) {
    fun chapters(): List<Chapter> = chaptersList

    fun verses(chapterId: Int): List<Verse> = versesProvider(chapterId)

    companion object {
        fun fromJson(jsonString: String, json: Json = Json { ignoreUnknownKeys = true }): LocalQuranTextSource {
            val payload = json.decodeFromString<QuranTextPayloadDto>(jsonString)
            val chapters = payload.chapters.map { dto ->
                Chapter(
                    id = dto.id,
                    name = dto.name,
                    translatedName = dto.translatedName,
                    arabicName = dto.arabicName,
                    versesCount = dto.versesCount,
                    revelationPlace = dto.revelationPlace,
                )
            }
            val surahsMap = payload.surahs.mapNotNull { (key, versesDto) ->
                key.toIntOrNull()?.let { surahId ->
                    surahId to versesDto.map { Verse(it.number, it.text) }
                }
            }.toMap()

            return LocalQuranTextSource(
                chaptersList = chapters,
                versesProvider = { surahsMap[it].orEmpty() },
            )
        }
    }
}

@Serializable
internal data class QuranTextPayloadDto(
    val chapters: List<ChapterPayloadDto>,
    val surahs: Map<String, List<VersePayloadDto>>,
)

@Serializable
internal data class ChapterPayloadDto(
    val id: Int,
    val name: String,
    val translatedName: String,
    val arabicName: String,
    val versesCount: Int,
    val revelationPlace: com.hashem.tilawa.domain.model.RevelationPlace,
)

@Serializable
internal data class VersePayloadDto(
    val number: Int,
    val text: String,
)
