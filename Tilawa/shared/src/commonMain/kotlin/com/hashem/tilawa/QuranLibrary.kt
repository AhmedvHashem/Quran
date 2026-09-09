package com.hashem.tilawa

import com.hashem.tilawa.data.DownloadStatus
import com.hashem.tilawa.data.DownloadStore
import com.hashem.tilawa.data.InMemoryDownloadStore
import com.hashem.tilawa.data.QuranRepositoryImpl
import com.hashem.tilawa.data.SettingsDownloadStore
import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.domain.QuranRepository
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.usecase.GetChapters
import com.hashem.tilawa.domain.usecase.GetRecitationEditions
import com.hashem.tilawa.domain.usecase.GetReciters
import com.hashem.tilawa.domain.usecase.GetSurah
import com.hashem.tilawa.domain.usecase.GetVerses

/**
 * Composition root and the whole public surface the native apps see: it wires
 * data → domain and re-exposes the use cases. Everything behind it is internal,
 * so the Apple/C bridges only ever see these calls and the domain models.
 */
class QuranLibrary internal constructor(
    repository: QuranRepository,
    private val downloadStore: DownloadStore,
) {

    constructor(
        downloadStore: DownloadStore,
    ) : this(
        repository = QuranRepositoryImpl(
            api = Mp3QuranApi(Mp3QuranApi.defaultClient()),
            localTextSource = LocalQuranTextSource(),
            downloadStore = downloadStore,
        ),
        downloadStore = downloadStore,
    )

    constructor() : this(InMemoryDownloadStore())

    private val getReciters = GetReciters(repository)
    private val getRecitationEditions = GetRecitationEditions(repository)
    private val getChapters = GetChapters(repository)
    private val getVerses = GetVerses(repository)
    private val getSurah = GetSurah(repository)

    @Throws(Exception::class)
    suspend fun reciters(): List<Reciter> = getReciters()

    @Throws(Exception::class)
    suspend fun editions(reciterId: Int): List<RecitationEdition> = getRecitationEditions(reciterId)

    @Throws(Exception::class)
    suspend fun chapters(): List<Chapter> = getChapters()

    @Throws(Exception::class)
    suspend fun verses(chapterId: Int): List<Verse> = getVerses(chapterId)

    @Throws(Exception::class)
    suspend fun surah(chapterId: Int, editionId: Int): PlaybackTrack = getSurah(chapterId, editionId)

    fun downloadStatus(editionId: Int, chapterId: Int): DownloadStatus =
        downloadStore.status(editionId, chapterId)

    fun markDownloaded(editionId: Int, chapterId: Int, localPath: String) =
        downloadStore.setStatus(editionId, chapterId, DownloadStatus.DOWNLOADED, localPath)

    fun setDownloadStatus(editionId: Int, chapterId: Int, status: DownloadStatus) =
        downloadStore.setStatus(editionId, chapterId, status)

    fun removeDownload(editionId: Int, chapterId: Int) =
        downloadStore.remove(editionId, chapterId)
}
