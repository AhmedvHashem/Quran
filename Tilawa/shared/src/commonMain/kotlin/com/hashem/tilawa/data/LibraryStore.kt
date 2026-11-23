package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.Document
import com.hashem.tilawa.data.local.FileDocument
import com.hashem.tilawa.domain.model.CollectionItem
import com.hashem.tilawa.domain.model.ListeningSession
import com.hashem.tilawa.domain.model.RecitationCollection
import com.hashem.tilawa.domain.model.RecitationCollection.Companion.FAVORITES_ID
import com.hashem.tilawa.domain.model.SurahRecording
import kotlinx.serialization.json.Json
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid

/**
 * Listening history and collections, each one durable document rewritten on
 * every change. Times come from the caller so the rules stay pure.
 */
internal class LibraryStore(
    private val sessionsDocument: Document = FileDocument("sessions.json"),
    private val collectionsDocument: Document = FileDocument("collections.json"),
) {
    private val json = Json { ignoreUnknownKeys = true }

    private var sessions: List<ListeningSession> = sessionsDocument.decode<List<ListeningSession>>().orEmpty()

    private var collections: List<RecitationCollection> =
        collectionsDocument.decode<List<RecitationCollection>>().orEmpty().withFavoritesFirst()

    // MARK: history

    fun sessions(): List<ListeningSession> = sessions.sortedByDescending { it.lastPlayedAtMs }

    /** Replaying a surah updates its one session instead of adding another. */
    fun recordSession(recording: SurahRecording, positionMs: Long, durationMs: Long, ayah: Int?, playedAtMs: Long) {
        if (durationMs <= 0) return
        val position = positionMs.coerceIn(0, durationMs)
        val previous = sessions.firstOrNull { it.recording.sameAs(recording) }
        // ponytail: "heard" is the furthest point reached; revisit when P0 defines it.
        val heard = maxOf(previous?.heardFraction ?: 0.0, position.toDouble() / durationMs)
        val session = ListeningSession(recording, position, durationMs, ayah, heard.coerceIn(0.0, 1.0), playedAtMs)
        sessions = sessions.filterNot { it.recording.sameAs(recording) } + session
        sessionsDocument.write(json.encodeToString(sessions))
    }

    fun removeSession(editionId: Int, chapterId: Int) {
        sessions = sessions.filterNot { it.recording.editionId == editionId && it.recording.chapterId == chapterId }
        sessionsDocument.write(json.encodeToString(sessions))
    }

    fun clearHistory() {
        sessions = emptyList()
        sessionsDocument.write(json.encodeToString(sessions))
    }

    // MARK: collections

    fun collections(): List<RecitationCollection> = collections

    @OptIn(ExperimentalUuidApi::class)
    fun createCollection(name: String, nowMs: Long): RecitationCollection? {
        val trimmed = name.trim().takeIf { it.isNotEmpty() } ?: return null
        val created = RecitationCollection(Uuid.random().toString(), trimmed, emptyList(), nowMs)
        save(collections + created)
        return created
    }

    fun renameCollection(id: String, name: String, nowMs: Long): Boolean {
        val trimmed = name.trim().takeIf { it.isNotEmpty() } ?: return false
        return update(id, userOnly = true) { it.copy(name = trimmed, updatedAtMs = nowMs) }
    }

    fun deleteCollection(id: String): Boolean {
        if (id == FAVORITES_ID || collections.none { it.id == id }) return false
        save(collections.filterNot { it.id == id })
        return true
    }

    /** Moves a user collection to [toIndex] among the user collections; Favorites stays first. */
    fun moveCollection(id: String, toIndex: Int): Boolean {
        val users = collections.filterNot { it.isFavorites }.toMutableList()
        val from = users.indexOfFirst { it.id == id }.takeIf { it >= 0 } ?: return false
        val moved = users.removeAt(from)
        users.add(toIndex.coerceIn(0, users.size), moved)
        save(listOf(favorites()) + users)
        return true
    }

    /** Adding a recording the collection already holds changes nothing. */
    fun addToCollection(id: String, recording: SurahRecording, nowMs: Long): Boolean = update(id) { collection ->
        if (collection.items.any { it.recording.sameAs(recording) }) collection
        else collection.copy(items = collection.items + CollectionItem(recording, nowMs), updatedAtMs = nowMs)
    }

    fun removeFromCollection(id: String, editionId: Int, chapterId: Int, nowMs: Long): Boolean = update(id) { collection ->
        collection.copy(
            items = collection.items.filterNot { it.recording.editionId == editionId && it.recording.chapterId == chapterId },
            updatedAtMs = nowMs,
        )
    }

    fun moveCollectionItem(id: String, fromIndex: Int, toIndex: Int, nowMs: Long): Boolean = update(id) { collection ->
        if (fromIndex !in collection.items.indices) return@update collection
        val items = collection.items.toMutableList()
        val moved = items.removeAt(fromIndex)
        items.add(toIndex.coerceIn(0, items.size), moved)
        collection.copy(items = items, updatedAtMs = nowMs)
    }

    private fun favorites() = collections.first { it.isFavorites }

    private fun update(
        id: String,
        userOnly: Boolean = false,
        change: (RecitationCollection) -> RecitationCollection,
    ): Boolean {
        if (userOnly && id == FAVORITES_ID) return false
        val current = collections.firstOrNull { it.id == id } ?: return false
        save(collections.map { if (it.id == id) change(current) else it })
        return true
    }

    private fun save(updated: List<RecitationCollection>) {
        collections = updated.withFavoritesFirst()
        collectionsDocument.write(json.encodeToString(collections))
    }

    private inline fun <reified T> Document.decode(): T? =
        read()?.let { runCatching { json.decodeFromString<T>(it) }.getOrNull() }
}

private fun SurahRecording.sameAs(other: SurahRecording) =
    editionId == other.editionId && chapterId == other.chapterId

/** Favorites always exists and always comes first. */
private fun List<RecitationCollection>.withFavoritesFirst(): List<RecitationCollection> {
    val favorites = firstOrNull { it.isFavorites }
        ?: RecitationCollection(FAVORITES_ID, "Favorites", emptyList(), 0)
    return listOf(favorites) + filterNot { it.isFavorites }
}
