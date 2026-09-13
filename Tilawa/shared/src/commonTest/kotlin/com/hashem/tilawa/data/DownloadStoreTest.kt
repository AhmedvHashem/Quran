package com.hashem.tilawa.data

import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
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
}
