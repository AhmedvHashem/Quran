package com.hashem.tilawa.data

import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.russhwolf.settings.Settings
import kotlinx.serialization.json.Json

internal interface DownloadStore {
    fun record(editionId: Int, chapterId: Int): DownloadRecord
    fun set(record: DownloadRecord)
    fun remove(editionId: Int, chapterId: Int)

    fun reconcile(
        editionId: Int,
        chapterId: Int,
        fileExists: Boolean,
        actualChecksumSha256: String?,
        actualByteCount: Long?,
    ): DownloadRecord {
        val record = record(editionId, chapterId)
        if (record.status != DownloadStatus.DOWNLOADED) return record

        val valid = fileExists &&
            !record.localPath.isNullOrBlank() &&
            (record.checksumSha256 == null || record.checksumSha256.equals(actualChecksumSha256, ignoreCase = true)) &&
            (record.byteCount == null || record.byteCount == actualByteCount)
        if (valid) return record

        remove(editionId, chapterId)
        return emptyRecord(editionId, chapterId)
    }
}

internal class InMemoryDownloadStore : DownloadStore {
    private val records = mutableMapOf<Pair<Int, Int>, DownloadRecord>()

    override fun record(editionId: Int, chapterId: Int): DownloadRecord =
        records[editionId to chapterId] ?: emptyRecord(editionId, chapterId)

    override fun set(record: DownloadRecord) {
        records[record.editionId to record.chapterId] = record
    }

    override fun remove(editionId: Int, chapterId: Int) {
        records.remove(editionId to chapterId)
    }
}

internal class SettingsDownloadStore(
    private val settings: Settings,
    private val json: Json = Json { ignoreUnknownKeys = true },
) : DownloadStore {
    override fun record(editionId: Int, chapterId: Int): DownloadRecord =
        settings.getStringOrNull(key(editionId, chapterId))
            ?.let { runCatching { json.decodeFromString<DownloadRecord>(it) }.getOrNull() }
            ?: emptyRecord(editionId, chapterId)

    override fun set(record: DownloadRecord) {
        settings.putString(key(record.editionId, record.chapterId), json.encodeToString(record))
    }

    override fun remove(editionId: Int, chapterId: Int) {
        settings.remove(key(editionId, chapterId))
    }

    private fun key(editionId: Int, chapterId: Int) = "download_${editionId}_$chapterId"
}

internal fun emptyRecord(editionId: Int, chapterId: Int) = DownloadRecord(
    editionId = editionId,
    chapterId = chapterId,
    status = DownloadStatus.NOT_DOWNLOADED,
)

internal expect fun defaultDownloadStore(): DownloadStore
