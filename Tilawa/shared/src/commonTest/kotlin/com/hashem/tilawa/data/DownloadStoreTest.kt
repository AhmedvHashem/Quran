package com.hashem.tilawa.data

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class DownloadStoreTest {

    private val store: DownloadStore = InMemoryDownloadStore()

    @Test
    fun `default status is NOT_DOWNLOADED and localPath is null`() {
        assertEquals(DownloadStatus.NOT_DOWNLOADED, store.status(101, 1))
        assertNull(store.localPath(101, 1))
    }

    @Test
    fun `updates status and local path`() {
        store.setStatus(101, 1, DownloadStatus.DOWNLOADING)
        assertEquals(DownloadStatus.DOWNLOADING, store.status(101, 1))
        assertNull(store.localPath(101, 1))

        store.setStatus(101, 1, DownloadStatus.DOWNLOADED, "file:///path/to/001.mp3")
        assertEquals(DownloadStatus.DOWNLOADED, store.status(101, 1))
        assertEquals("file:///path/to/001.mp3", store.localPath(101, 1))
    }

    @Test
    fun `removes download entry`() {
        store.setStatus(101, 1, DownloadStatus.DOWNLOADED, "file:///path/to/001.mp3")
        store.remove(101, 1)

        assertEquals(DownloadStatus.NOT_DOWNLOADED, store.status(101, 1))
        assertNull(store.localPath(101, 1))
    }
}
