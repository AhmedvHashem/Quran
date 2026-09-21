package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.Document
import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.hashem.tilawa.domain.model.RecordingIdentity
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

/** Stands in for a file on disk: what one store writes, the next store reads. */
private class FakeDocument(private var text: String? = null) : Document {
    override fun read(): String? = text
    override fun write(text: String) {
        this.text = text
    }
}

class DownloadStoreTest {
    @Test
    fun `download metadata survives a new store instance`() {
        val document = FakeDocument()
        val expected = DownloadRecord(
            editionId = 101,
            chapterId = 1,
            status = DownloadStatus.DOWNLOADED,
            localPath = "file:///path/001.mp3",
            checksumSha256 = "a".repeat(64),
            byteCount = 42,
        )

        DocumentDownloadStore(document).set(expected)

        assertEquals(expected, DocumentDownloadStore(document).record(101, 1))
    }

    @Test
    fun `missing or corrupt file clears durable metadata`() {
        val store: DownloadStore = InMemoryDownloadStore()
        store.set(
            DownloadRecord(
                editionId = 101,
                chapterId = 1,
                status = DownloadStatus.DOWNLOADED,
                localPath = "file:///path/001.mp3",
                checksumSha256 = "a".repeat(64),
                byteCount = 42,
            )
        )

        val result = store.reconcile(101, 1, fileExists = false, actualChecksumSha256 = null, actualByteCount = null)

        assertEquals(DownloadStatus.NOT_DOWNLOADED, result.status)
        assertNull(store.record(101, 1).localPath)
    }

    @Test
    fun `reconciliation requires complete matching integrity and identity metadata`() {
        val document = FakeDocument()
        val store = DocumentDownloadStore(document)
        val ready = DownloadRecord(101, 1, DownloadStatus.DOWNLOADED,
            "file:///001.mp3", "a".repeat(64), 42,
            RecordingIdentity("mp3quran.net", 101, 1, 1, "Murattal", "revision-1"))
        store.set(ready)
        assertEquals(listOf(ready), DocumentDownloadStore(document).all())
        assertEquals(ready, store.reconcile(101, 1, true, "a".repeat(64), 42))
        for (bad in listOf(ready.copy(checksumSha256 = null), ready.copy(byteCount = 0),
            ready.copy(identity = null), ready.copy(identity = ready.identity!!.copy(editionId = 102)),
            ready.copy(checksumSha256 = "b".repeat(64)), ready.copy(byteCount = 43))) {
            store.set(bad)
            assertEquals(DownloadStatus.NOT_DOWNLOADED, store.reconcile(101, 1, true, "a".repeat(64), 42).status)
        }
        assertEquals(emptyList(), DocumentDownloadStore(document).all())
    }

    @Test
    fun `abandoned transfer becomes retryable after restart`() {
        val document = FakeDocument()
        DocumentDownloadStore(document).set(DownloadRecord(101, 1, DownloadStatus.DOWNLOADING))
        val restarted = DocumentDownloadStore(document)
        assertEquals(DownloadStatus.DOWNLOADING, restarted.all().single().status)
        assertEquals(DownloadStatus.FAILED, restarted.reconcile(101, 1, false, null, null).status)
        assertEquals(DownloadStatus.FAILED, DocumentDownloadStore(document).record(101, 1).status)
    }

    @Test
    fun `a corrupt document reads as empty instead of failing`() {
        val document = FakeDocument("not json at all")
        val store = DocumentDownloadStore(document)

        assertEquals(emptyList(), store.all())
        assertEquals(DownloadStatus.NOT_DOWNLOADED, store.record(101, 1).status)

        store.set(DownloadRecord(101, 1, DownloadStatus.DOWNLOADING))
        assertEquals(DownloadStatus.DOWNLOADING, DocumentDownloadStore(document).record(101, 1).status)
    }

    @Test
    fun `records keep separate identities in one document`() {
        val document = FakeDocument()
        val store = DocumentDownloadStore(document)
        store.set(DownloadRecord(101, 1, DownloadStatus.DOWNLOADING))
        store.set(DownloadRecord(102, 1, DownloadStatus.FAILED))

        val reopened = DocumentDownloadStore(document)
        assertEquals(DownloadStatus.DOWNLOADING, reopened.record(101, 1).status)
        assertEquals(DownloadStatus.FAILED, reopened.record(102, 1).status)
        assertEquals(DownloadStatus.NOT_DOWNLOADED, reopened.record(101, 2).status)

        reopened.remove(101, 1)
        assertEquals(1, DocumentDownloadStore(document).all().size)
    }
}
