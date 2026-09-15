package com.hashem.tilawa.data

import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.russhwolf.settings.Settings
import kotlinx.serialization.json.Json

internal interface DownloadStore {
    fun all(): List<DownloadRecord>
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
        if (record.status == DownloadStatus.DOWNLOADING) {
            return record.copy(status = DownloadStatus.FAILED, failureMessage = "Download interrupted. Retry to continue.")
                .also(::set)
        }
        if (record.status != DownloadStatus.DOWNLOADED) return record

        val valid = fileExists && record.hasCompleteMetadata() &&
            record.checksumSha256.equals(actualChecksumSha256, ignoreCase = true) &&
            record.byteCount == actualByteCount
        if (valid) return record

        remove(editionId, chapterId)
        return emptyRecord(editionId, chapterId)
    }
}

internal class InMemoryDownloadStore : DownloadStore {
    private val records = mutableMapOf<Pair<Int, Int>, DownloadRecord>()

    override fun all(): List<DownloadRecord> = records.values.toList()

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
    override fun all(): List<DownloadRecord> = settings.keys.filter { it.startsWith("download_") }
        .mapNotNull { storedKey ->
            settings.getStringOrNull(storedKey)?.let {
                runCatching { json.decodeFromString<DownloadRecord>(it) }.getOrNull()
            }?.takeIf { storedKey == key(it.editionId, it.chapterId) }
        }

    override fun record(editionId: Int, chapterId: Int): DownloadRecord =
        settings.getStringOrNull(key(editionId, chapterId))
            ?.let { runCatching { json.decodeFromString<DownloadRecord>(it) }.getOrNull() }
            ?.takeIf { it.editionId == editionId && it.chapterId == chapterId }
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

internal fun DownloadRecord.hasCompleteMetadata(): Boolean =
    status == DownloadStatus.DOWNLOADED && chapterId in 1..114 && editionId > 0 &&
        !localPath.isNullOrBlank() &&
        checksumSha256?.matches(Regex("[0-9a-fA-F]{64}")) == true &&
        (byteCount ?: 0) > 0 && identity?.editionId == editionId &&
        !identity.revision.isBlank() && !identity.provider.isBlank()
