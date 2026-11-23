package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.Document
import com.hashem.tilawa.domain.model.RecitationCollection.Companion.FAVORITES_ID
import com.hashem.tilawa.domain.model.SurahRecording
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

private class MemoryDocument(private var text: String? = null) : Document {
    override fun read(): String? = text
    override fun write(text: String) {
        this.text = text
    }
}

private fun recording(chapterId: Int, editionId: Int = 123) =
    SurahRecording(editionId, chapterId, reciterId = 123, reciterName = "Alafasy", style = "Murattal", riwayah = "Hafs")

class LibraryStoreTest {
    private val sessions = MemoryDocument()
    private val collections = MemoryDocument()
    private fun store() = LibraryStore(sessions, collections)

    @Test
    fun `a replayed surah updates one session newest first across instances`() {
        store().apply {
            recordSession(recording(1), positionMs = 30_000, durationMs = 60_000, ayah = 3, playedAtMs = 1)
            recordSession(recording(2), positionMs = 10_000, durationMs = 100_000, ayah = null, playedAtMs = 2)
            recordSession(recording(1), positionMs = 6_000, durationMs = 60_000, ayah = 1, playedAtMs = 3)
        }

        val loaded = store().sessions()
        assertEquals(listOf(1, 2), loaded.map { it.recording.chapterId })
        assertEquals(6_000, loaded[0].positionMs)
        assertEquals(0.5, loaded[0].heardFraction, "heard keeps the furthest point reached")
    }

    @Test
    fun `removing and clearing history is durable`() {
        store().apply {
            recordSession(recording(1), 1_000, 60_000, null, 1)
            recordSession(recording(2), 1_000, 60_000, null, 2)
            removeSession(123, 1)
        }
        assertEquals(listOf(2), store().sessions().map { it.recording.chapterId })
        store().clearHistory()
        assertTrue(store().sessions().isEmpty())
    }

    @Test
    fun `favorites always exists and cannot be renamed moved or deleted`() {
        val store = store()
        assertEquals(FAVORITES_ID, store.collections().single().id)
        assertFalse(store.renameCollection(FAVORITES_ID, "Mine", 1))
        assertFalse(store.deleteCollection(FAVORITES_ID))
        assertFalse(store.moveCollection(FAVORITES_ID, 1))

        val night = store.createCollection("Night", 1)!!
        store.moveCollection(night.id, 0)
        assertEquals(FAVORITES_ID, store().collections().first().id)
    }

    @Test
    fun `a collection keeps its manual order and ignores duplicates across instances`() {
        val id = store().createCollection("  Night recitation ", 1)!!.id
        store().apply {
            addToCollection(id, recording(67), 2)
            addToCollection(id, recording(36), 3)
            addToCollection(id, recording(67), 4)
            moveCollectionItem(id, fromIndex = 1, toIndex = 0, nowMs = 5)
        }

        val loaded = store().collections().first { it.id == id }
        assertEquals("Night recitation", loaded.name)
        assertEquals(listOf(36, 67), loaded.items.map { it.recording.chapterId })
        assertEquals(5, loaded.updatedAtMs)
    }

    @Test
    fun `user collections can be renamed reordered and deleted`() {
        val store = store()
        val a = store.createCollection("A", 1)!!
        val b = store.createCollection("B", 2)!!
        assertFalse(store.createCollection("   ", 3) != null)

        assertTrue(store.moveCollection(b.id, 0))
        assertTrue(store.renameCollection(a.id, "Renamed", 4))
        assertEquals(listOf("Favorites", "B", "Renamed"), store().collections().map { it.name })

        assertTrue(store.deleteCollection(b.id))
        assertEquals(listOf("Favorites", "Renamed"), store().collections().map { it.name })
    }
}
