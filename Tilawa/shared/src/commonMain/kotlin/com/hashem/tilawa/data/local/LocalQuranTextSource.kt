package com.hashem.tilawa.data.local

import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.ContentManifest
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
    val manifest: ContentManifest = CONTENT_MANIFEST,
) {
    fun chapters(): List<Chapter> = chaptersList

    fun verses(chapterId: Int): List<Verse> = versesProvider(chapterId)

    companion object {
        val CONTENT_MANIFEST = ContentManifest(
            textEditionId = "uthmani-hafs-v1",
            displayName = "Uthmani Quran text (Hafs)",
            source = "Bundled Uthmani Hafs dataset; historical QUL attribution, exact upstream resource pending verification",
            revision = "tilawa-bundle-2026-09-13",
            checksumSha256 = "8d7ecf45e8c7ce6f796102b33081aca53b1e5d46eb6ff31ff6bd553c73523899",
            license = "Pending exact upstream resource verification",
            notices = "Enabled for the v1 Hafs reader by product-owner approval. Bytes are checksum-locked; confirm upstream attribution and redistribution terms before release.",
            supportedRiwayahIds = setOf(1),
            isVerified = true,
        )

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
                manifest = CONTENT_MANIFEST.copy(
                    textEditionId = "unverified-import",
                    source = "Imported JSON; provenance unverified",
                    checksumSha256 = "",
                    isVerified = false,
                ),
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
