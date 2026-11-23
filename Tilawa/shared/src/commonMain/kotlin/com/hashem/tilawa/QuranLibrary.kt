package com.hashem.tilawa.api

import com.hashem.tilawa.data.LibraryStore
import com.hashem.tilawa.data.QuranRepositoryImpl
import com.hashem.tilawa.data.defaultDownloadStore
import com.hashem.tilawa.data.emptyRecord
import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.ContentManifest
import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.hashem.tilawa.domain.model.ListeningSession
import com.hashem.tilawa.domain.model.RecitationCollection
import com.hashem.tilawa.domain.model.SurahRecording
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
import com.hashem.tilawa.domain.model.verseNumberAt
import com.hashem.tilawa.domain.model.RecitersResult
import com.hashem.tilawa.domain.model.EditionsResult
import com.hashem.tilawa.domain.model.SurahResult
import com.hashem.tilawa.domain.model.QuranFailure
import com.hashem.tilawa.domain.model.QuranException
import com.hashem.tilawa.domain.model.QuranErrorCode
import kotlin.coroutines.cancellation.CancellationException

/** The single shared composition root exposed to every native application. */
class QuranLibrary {
    private val localTextSource = LocalQuranTextSource()
    private val downloadStore = defaultDownloadStore()
    private val libraryStore = LibraryStore()
    private val repository = QuranRepositoryImpl(
        Mp3QuranApi(Mp3QuranApi.defaultClient()),
        localTextSource,
        downloadStore,
    )

    fun contentManifest(): ContentManifest = localTextSource.manifest

    @Throws(Exception::class, CancellationException::class)
    suspend fun reciters(): RecitersResult {
        val (value, failure) = quranRequest { repository.reciters() }
        return RecitersResult(value.orEmpty(), failure)
    }

    @Throws(Exception::class, CancellationException::class)
    suspend fun editions(reciterId: Int): EditionsResult {
        val (value, failure) = quranRequest { repository.editions(reciterId) }
        return EditionsResult(value.orEmpty(), failure)
    }

    /** Every edition in the catalog, for browsing and filtering reciters by riwayah, style and timing. */
    @Throws(Exception::class, CancellationException::class)
    suspend fun allEditions(): EditionsResult {
        val (value, failure) = quranRequest { repository.allEditions() }
        return EditionsResult(value.orEmpty(), failure)
    }

    suspend fun chapters(): List<Chapter> = repository.chapters()

    suspend fun verses(chapterId: Int): List<Verse> = repository.verses(chapterId)

    @Throws(Exception::class, CancellationException::class)
    suspend fun surah(chapterId: Int, editionId: Int): SurahResult {
        val (value, failure) = quranRequest { repository.playbackTrack(chapterId, editionId) }
        return SurahResult(value, failure)
    }

    fun verseAt(positionMs: Long, timing: List<VerseTiming>): Int? =
        verseNumberAt(positionMs, timing)

    fun download(editionId: Int, chapterId: Int): DownloadRecord =
        downloadStore.record(editionId, chapterId)

    /** Enumerate persisted records before any catalog request, including interrupted transfers. */
    fun downloads(): List<DownloadRecord> = downloadStore.all()

    fun beginDownload(editionId: Int, chapterId: Int) {
        downloadStore.set(emptyRecord(editionId, chapterId).copy(status = DownloadStatus.DOWNLOADING))
    }

    fun completeDownload(
        chapterId: Int,
        track: PlaybackTrack,
        localPath: String,
        checksumSha256: String,
        byteCount: Long,
    ) {
        require(track.chapterId == chapterId) { "The downloaded chapter does not match the playback track" }
        require(localPath.isNotBlank()) { "A downloaded file path is required" }
        require(checksumSha256.matches(Regex("[0-9a-fA-F]{64}"))) { "A SHA-256 checksum is required" }
        require(byteCount > 0) { "A downloaded file must not be empty" }
        downloadStore.set(
            DownloadRecord(
                editionId = track.identity.editionId,
                chapterId = chapterId,
                status = DownloadStatus.DOWNLOADED,
                localPath = localPath,
                checksumSha256 = checksumSha256.lowercase(),
                byteCount = byteCount,
                identity = track.identity,
                textEditionId = localTextSource.manifest.textEditionId.takeIf {
                    track.verses.isNotEmpty()
                },
                timing = track.timing,
            )
        )
    }

    fun failDownload(editionId: Int, chapterId: Int, message: String) {
        downloadStore.set(
            emptyRecord(editionId, chapterId).copy(
                status = DownloadStatus.FAILED,
                failureMessage = message.takeIf { it.isNotBlank() },
            )
        )
    }

    /** Call after the native transfer service confirms this record has no active transfer. */
    fun reconcileDownload(
        editionId: Int,
        chapterId: Int,
        fileExists: Boolean,
        actualChecksumSha256: String?,
        actualByteCount: Long?,
    ): DownloadRecord = downloadStore.reconcile(
        editionId,
        chapterId,
        fileExists,
        actualChecksumSha256,
        actualByteCount,
    )

    fun removeDownload(editionId: Int, chapterId: Int) {
        downloadStore.remove(editionId, chapterId)
    }

    // Listening history. Newest first; one session per edition and surah.

    fun sessions(): List<ListeningSession> = libraryStore.sessions()

    fun recordSession(recording: SurahRecording, positionMs: Long, durationMs: Long, ayah: Int?, playedAtMs: Long) =
        libraryStore.recordSession(recording, positionMs, durationMs, ayah, playedAtMs)

    fun removeSession(editionId: Int, chapterId: Int) = libraryStore.removeSession(editionId, chapterId)

    fun clearHistory() = libraryStore.clearHistory()

    // Collections. Favorites always exists and always comes first.

    fun collections(): List<RecitationCollection> = libraryStore.collections()

    /** Returns null for a blank name. */
    fun createCollection(name: String, nowMs: Long): RecitationCollection? = libraryStore.createCollection(name, nowMs)

    /** False for Favorites, an unknown collection or a blank name. */
    fun renameCollection(id: String, name: String, nowMs: Long): Boolean = libraryStore.renameCollection(id, name, nowMs)

    /** False for Favorites or an unknown collection. Never touches audio files. */
    fun deleteCollection(id: String): Boolean = libraryStore.deleteCollection(id)

    fun moveCollection(id: String, toIndex: Int): Boolean = libraryStore.moveCollection(id, toIndex)

    fun addToCollection(id: String, recording: SurahRecording, nowMs: Long): Boolean =
        libraryStore.addToCollection(id, recording, nowMs)

    fun removeFromCollection(id: String, editionId: Int, chapterId: Int, nowMs: Long): Boolean =
        libraryStore.removeFromCollection(id, editionId, chapterId, nowMs)

    fun moveCollectionItem(id: String, fromIndex: Int, toIndex: Int, nowMs: Long): Boolean =
        libraryStore.moveCollectionItem(id, fromIndex, toIndex, nowMs)
}

internal suspend fun <T> quranRequest(block: suspend () -> T): Pair<T?, QuranFailure?> = try {
    block() to null
} catch (failure: QuranException) {
    null to QuranFailure(
        failure.code, failure.retryable, when (failure.code) {
            QuranErrorCode.NETWORK -> "Could not connect. Please try again."
            QuranErrorCode.EDITION_NOT_FOUND -> "This recording is no longer available."
            QuranErrorCode.SURAH_UNAVAILABLE -> "This surah is unavailable in the selected recording."
        }
    )
}
