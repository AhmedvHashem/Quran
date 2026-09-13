package com.hashem.tilawa.domain.model

import kotlinx.serialization.Serializable

/** A human reciter (e.g. Mishary Rashid Alafasy). */
@Serializable
data class Reciter(
    val id: Int,
    val name: String,
    val arabicName: String,
)

/** A canonical narration method (e.g. Hafs A'n Assem, Warsh A'n Nafi'). */
@Serializable
data class Riwayah(
    val id: Int?,
    val name: String,
)

/** A specific recording edition by a reciter in a riwayah and style. */
@Serializable
data class RecitationEdition(
    val id: Int,
    val reciterId: Int,
    val riwayah: Riwayah,
    val style: String,
    val serverBaseUrl: String,
    val availableSurahs: Set<Int>,
    val hasTiming: Boolean,
    val isFeatured: Boolean = false,
)

/** Stable identity for one provider recording revision. */
@Serializable
data class RecordingIdentity(
    val provider: String,
    val editionId: Int,
    val reciterId: Int,
    val riwayahId: Int?,
    val style: String,
    val revision: String,
)

/** Provenance and compatibility contract for the bundled Quran text. */
@Serializable
data class ContentManifest(
    val textEditionId: String,
    val displayName: String,
    val source: String,
    val revision: String,
    val checksumSha256: String,
    val license: String,
    val notices: String,
    val supportedRiwayahIds: Set<Int>,
    val isVerified: Boolean,
)

@Serializable
data class Chapter(
    val id: Int,
    val name: String,
    val translatedName: String,
    val arabicName: String,
    val versesCount: Int,
    val revelationPlace: RevelationPlace,
)

enum class RevelationPlace { MAKKAH, MADINAH }

/** One ayah text. */
@Serializable
data class Verse(
    val number: Int,
    val text: String,
)

/** Ayah start and end timestamps in milliseconds inside a gapless surah audio track. */
@Serializable
data class VerseTiming(
    val verseNumber: Int,
    val startMs: Long,
    val endMs: Long,
)

enum class TextAvailability { VERIFIED, AUDIO_ONLY }

enum class DownloadStatus { NOT_DOWNLOADED, DOWNLOADING, DOWNLOADED, FAILED }

@Serializable
data class DownloadRecord(
    val editionId: Int,
    val chapterId: Int,
    val status: DownloadStatus,
    val localPath: String? = null,
    val checksumSha256: String? = null,
    val byteCount: Long? = null,
    val identity: RecordingIdentity? = null,
    val textEditionId: String? = null,
    val timing: List<VerseTiming>? = null,
    val failureMessage: String? = null,
)

internal enum class QuranErrorCode { NETWORK, EDITION_NOT_FOUND, SURAH_UNAVAILABLE }

internal class QuranException(
    val code: QuranErrorCode,
    val retryable: Boolean,
    message: String,
) : Exception(message)

/** One playable surah: exactly one audio file, plus timing only when the edition has it. */
@Serializable
data class PlaybackTrack(
    val identity: RecordingIdentity,
    val chapterId: Int,
    val trackUrl: String,
    val verses: List<Verse>,
    val timing: List<VerseTiming>?,
    val textAvailability: TextAvailability,
)
