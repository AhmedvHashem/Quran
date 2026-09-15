package com.hashem.tilawa.data

import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.hashem.tilawa.domain.model.RecordingIdentity
import com.russhwolf.settings.MapSettings
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class DownloadStoreTest {
    @Test
    fun `download metadata survives a new store instance`() {
        val settings = MapSettings()
        val expected = DownloadRecord(
            editionId = 101,
            chapterId = 1,
            status = DownloadStatus.DOWNLOADED,
            localPath = "file:///path/001.mp3",
            checksumSha256 = "a".repeat(64),
            byteCount = 42,
        )

        SettingsDownloadStore(settings).set(expected)

        assertEquals(expected, SettingsDownloadStore(settings).record(101, 1))
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
        val settings = MapSettings()
        val store = SettingsDownloadStore(settings)
        val ready = DownloadRecord(101, 1, DownloadStatus.DOWNLOADED,
            "file:///001.mp3", "a".repeat(64), 42,
            RecordingIdentity("mp3quran.net", 101, 1, 1, "Murattal", "revision-1"))
        store.set(ready)
        assertEquals(listOf(ready), SettingsDownloadStore(settings).all())
        assertEquals(ready, store.reconcile(101, 1, true, "a".repeat(64), 42))
        for (bad in listOf(ready.copy(checksumSha256 = null), ready.copy(byteCount = 0),
            ready.copy(identity = null), ready.copy(identity = ready.identity!!.copy(editionId = 102)),
            ready.copy(checksumSha256 = "b".repeat(64)), ready.copy(byteCount = 43))) {
            store.set(bad)
            assertEquals(DownloadStatus.NOT_DOWNLOADED, store.reconcile(101, 1, true, "a".repeat(64), 42).status)
        }
        assertEquals(emptyList(), SettingsDownloadStore(settings).all())
    }

    @Test
    fun `abandoned transfer becomes retryable after restart`() {
        val settings = MapSettings()
        SettingsDownloadStore(settings).set(DownloadRecord(101, 1, DownloadStatus.DOWNLOADING))
        val restarted = SettingsDownloadStore(settings)
        assertEquals(DownloadStatus.DOWNLOADING, restarted.all().single().status)
        assertEquals(DownloadStatus.FAILED, restarted.reconcile(101, 1, false, null, null).status)
        assertEquals(DownloadStatus.FAILED, SettingsDownloadStore(settings).record(101, 1).status)
    }

    @Test
    fun `corrupt or mismatched stored keys cannot select another recording`() {
        val settings = MapSettings()
        settings.putString("download_101_1", """{"editionId":102,"chapterId":1,"status":"DOWNLOADING"}""")
        settings.putString("download_101_2", "broken json")
        val store = SettingsDownloadStore(settings)
        assertEquals(DownloadStatus.NOT_DOWNLOADED, store.record(101, 1).status)
        assertEquals(emptyList(), store.all())
    }

}
