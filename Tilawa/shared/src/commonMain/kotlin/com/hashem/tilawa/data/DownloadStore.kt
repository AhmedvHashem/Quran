package com.hashem.tilawa.data

import com.russhwolf.settings.Settings
import kotlinx.serialization.Serializable

@Serializable
enum class DownloadStatus {
    NOT_DOWNLOADED,
    DOWNLOADING,
    DOWNLOADED,
}

/**
 * Narrow interface for tracking and querying per-edition surah downloads.
 */
interface DownloadStore {
    fun status(editionId: Int, chapterId: Int): DownloadStatus
    fun localPath(editionId: Int, chapterId: Int): String?
    fun setStatus(editionId: Int, chapterId: Int, status: DownloadStatus, localPath: String? = null)
    fun remove(editionId: Int, chapterId: Int)
}

/**
 * In-memory implementation of DownloadStore.
 */
class InMemoryDownloadStore : DownloadStore {
    private val statuses = mutableMapOf<Pair<Int, Int>, DownloadStatus>()
    private val paths = mutableMapOf<Pair<Int, Int>, String>()

    override fun status(editionId: Int, chapterId: Int): DownloadStatus =
        statuses[editionId to chapterId] ?: DownloadStatus.NOT_DOWNLOADED

    override fun localPath(editionId: Int, chapterId: Int): String? =
        paths[editionId to chapterId]

    override fun setStatus(editionId: Int, chapterId: Int, status: DownloadStatus, localPath: String?) {
        statuses[editionId to chapterId] = status
        if (localPath != null) {
            paths[editionId to chapterId] = localPath
        } else if (status == DownloadStatus.NOT_DOWNLOADED) {
            paths.remove(editionId to chapterId)
        }
    }

    override fun remove(editionId: Int, chapterId: Int) {
        statuses.remove(editionId to chapterId)
        paths.remove(editionId to chapterId)
    }
}

/**
 * Implementation backed by multiplatform-settings.
 */
class SettingsDownloadStore(
    private val settings: Settings,
) : DownloadStore {

    override fun status(editionId: Int, chapterId: Int): DownloadStatus {
        val raw = settings.getStringOrNull(statusKey(editionId, chapterId)) ?: return DownloadStatus.NOT_DOWNLOADED
        return try {
            DownloadStatus.valueOf(raw)
        } catch (e: Exception) {
            DownloadStatus.NOT_DOWNLOADED
        }
    }

    override fun localPath(editionId: Int, chapterId: Int): String? {
        return settings.getStringOrNull(pathKey(editionId, chapterId))
    }

    override fun setStatus(editionId: Int, chapterId: Int, status: DownloadStatus, localPath: String?) {
        settings.putString(statusKey(editionId, chapterId), status.name)
        if (localPath != null) {
            settings.putString(pathKey(editionId, chapterId), localPath)
        } else if (status == DownloadStatus.NOT_DOWNLOADED) {
            settings.remove(pathKey(editionId, chapterId))
        }
    }

    override fun remove(editionId: Int, chapterId: Int) {
        settings.remove(statusKey(editionId, chapterId))
        settings.remove(pathKey(editionId, chapterId))
    }

    private fun statusKey(editionId: Int, chapterId: Int) = "download_status_${editionId}_$chapterId"
    private fun pathKey(editionId: Int, chapterId: Int) = "download_path_${editionId}_$chapterId"
}
