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

/** One playable surah: exactly one audio file, plus timing only when the edition has it. */
@Serializable
data class PlaybackTrack(
    val trackUrl: String,
    val verses: List<Verse>,
    val timing: List<VerseTiming>?,
)
