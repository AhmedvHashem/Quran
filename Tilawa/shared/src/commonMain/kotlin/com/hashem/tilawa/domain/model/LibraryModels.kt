package com.hashem.tilawa.domain.model

import kotlinx.serialization.Serializable

/**
 * One surah in one recording edition: what history and collections hold.
 * The names are a snapshot, so an item stays readable when its edition
 * leaves the catalog or the catalog cannot be reached.
 */
@Serializable
data class SurahRecording(
    val editionId: Int,
    val chapterId: Int,
    val reciterId: Int,
    val reciterName: String,
    val style: String,
    val riwayah: String,
)

/** The last place the user reached in one recording of one surah. */
@Serializable
data class ListeningSession(
    val recording: SurahRecording,
    val positionMs: Long,
    val durationMs: Long,
    /** The ayah at [positionMs], only for a timed recording. */
    val ayah: Int? = null,
    /** The furthest point reached, as a fraction of the surah. */
    val heardFraction: Double,
    val lastPlayedAtMs: Long,
)

@Serializable
data class CollectionItem(
    val recording: SurahRecording,
    val addedAtMs: Long,
)

@Serializable
data class RecitationCollection(
    val id: String,
    val name: String,
    val items: List<CollectionItem>,
    val updatedAtMs: Long,
) {
    /** Favorites is pinned: it cannot be renamed, moved or deleted. */
    val isFavorites: Boolean get() = id == FAVORITES_ID

    companion object {
        const val FAVORITES_ID = "favorites"
    }
}
