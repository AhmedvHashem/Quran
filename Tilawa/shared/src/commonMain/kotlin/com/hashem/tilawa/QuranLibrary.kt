package com.hashem.tilawa.api

import com.hashem.tilawa.data.QuranRepositoryImpl
import com.hashem.tilawa.data.defaultDownloadStore
import com.hashem.tilawa.data.emptyRecord
import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.ContentManifest
import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
import com.hashem.tilawa.domain.model.verseNumberAt
import kotlin.coroutines.cancellation.CancellationException

/** The single shared composition root exposed to every native application. */
class QuranLibrary {
    private val localTextSource = LocalQuranTextSource()
    private val downloadStore = defaultDownloadStore()
    private val repository = QuranRepositoryImpl(
        Mp3QuranApi(Mp3QuranApi.defaultClient()),
        localTextSource,
        downloadStore,
    )

    fun contentManifest(): ContentManifest = localTextSource.manifest

    @Throws(Exception::class, CancellationException::class)
    suspend fun reciters(): List<Reciter> = repository.reciters()

    @Throws(Exception::class, CancellationException::class)
    suspend fun editions(reciterId: Int): List<RecitationEdition> = repository.editions(reciterId)

    suspend fun chapters(): List<Chapter> = repository.chapters()

    suspend fun verses(chapterId: Int): List<Verse> = repository.verses(chapterId)

    @Throws(Exception::class, CancellationException::class)
    suspend fun surah(chapterId: Int, editionId: Int): PlaybackTrack =
        repository.playbackTrack(chapterId, editionId)

    fun verseAt(positionMs: Long, timing: List<VerseTiming>): Int? =
        verseNumberAt(positionMs, timing)

    fun download(editionId: Int, chapterId: Int): DownloadRecord =
        downloadStore.record(editionId, chapterId)

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
}
