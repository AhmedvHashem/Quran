package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.data.remote.Mp3QuranMoshafDto
import com.hashem.tilawa.data.remote.Mp3QuranReciterDto
import com.hashem.tilawa.data.remote.Mp3QuranRiwayahDto
import com.hashem.tilawa.domain.QuranRepository
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.Riwayah
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

/**
 * Maps mp3quran.net remote DTOs and local bundled text onto domain models.
 */
internal class QuranRepositoryImpl(
    private val api: Mp3QuranApi,
    private val localTextSource: LocalQuranTextSource = LocalQuranTextSource(),
    private val downloadStore: DownloadStore = InMemoryDownloadStore(),
) : QuranRepository {

    private val mutex = Mutex()
    private var cachedReciters: List<Mp3QuranReciterDto>? = null
    private var cachedArabicNames: Map<Int, String>? = null
    private var cachedRiwayat: Map<Int, String>? = null
    private var cachedTimedReadIds: Set<Int>? = null

    companion object {
        private val FEATURED_RECITER_ORDER = listOf(123, 54, 31, 118, 112, 51, 30, 74, 102, 92)
        private val FEATURED_EDITION_IDS = setOf(123, 54, 31, 118, 112, 53, 30, 74, 102, 92)
    }

    override suspend fun reciters(): List<Reciter> {
        val (engReciters, arReciters) = loadRecitersData()
        val arNameMap = arReciters.associate { it.id to it.name }
        val sorted = engReciters.sortedWith(
            compareBy {
                val idx = FEATURED_RECITER_ORDER.indexOf(it.id)
                if (idx >= 0) idx else Int.MAX_VALUE
            }
        )
        return sorted.map { reciter ->
            Reciter(
                id = reciter.id,
                name = reciter.name,
                arabicName = arNameMap[reciter.id] ?: reciter.name,
            )
        }
    }

    override suspend fun editions(reciterId: Int): List<RecitationEdition> {
        val (engReciters, _) = loadRecitersData()
        val riwayatMap = loadRiwayat()
        val timedReadIds = loadTimedReadIds()

        val reciter = engReciters.find { it.id == reciterId } ?: return emptyList()

        return reciter.moshaf.map { moshaf ->
            val (riwayah, style) = deriveRiwayahAndStyle(moshaf, riwayatMap)
            val availableSurahs = moshaf.surahList
                .split(',')
                .mapNotNull { it.trim().toIntOrNull() }
                .toSet()

            val baseUrl = if (moshaf.server.endsWith('/')) moshaf.server else "${moshaf.server}/"

            RecitationEdition(
                id = moshaf.id,
                reciterId = reciterId,
                riwayah = riwayah,
                style = style,
                serverBaseUrl = baseUrl,
                availableSurahs = availableSurahs,
                hasTiming = timedReadIds.contains(moshaf.id),
                isFeatured = FEATURED_EDITION_IDS.contains(moshaf.id),
            )
        }
    }

    override suspend fun chapters(): List<Chapter> = localTextSource.chapters()

    override suspend fun verses(chapterId: Int): List<Verse> = localTextSource.verses(chapterId)

    override suspend fun playbackTrack(chapterId: Int, editionId: Int): PlaybackTrack {
        val (engReciters, _) = loadRecitersData()
        val timedReadIds = loadTimedReadIds()

        var matchingMoshaf: Mp3QuranMoshafDto? = null
        for (reciter in engReciters) {
            val found = reciter.moshaf.find { it.id == editionId }
            if (found != null) {
                matchingMoshaf = found
                break
            }
        }

        val downloadedPath = if (downloadStore.status(editionId, chapterId) == DownloadStatus.DOWNLOADED) {
            downloadStore.localPath(editionId, chapterId)
        } else {
            null
        }

        val trackUrl = if (!downloadedPath.isNullOrBlank()) {
            downloadedPath
        } else {
            val server = matchingMoshaf?.server?.let { if (it.endsWith('/')) it else "$it/" } ?: ""
            val paddedSurah = chapterId.toString().padStart(3, '0')
            "$server$paddedSurah.mp3"
        }
        val verses = localTextSource.verses(chapterId)

        val hasTiming = timedReadIds.contains(editionId)
        val timing: List<VerseTiming>? = if (hasTiming) {
            try {
                val timingDtos = api.timing(surahId = chapterId, readId = editionId)
                val mapped = timingDtos
                    .filter { it.ayah > 0 }
                    .map { VerseTiming(verseNumber = it.ayah, startMs = it.startTime, endMs = it.endTime) }
                if (mapped.isNotEmpty()) mapped else null
            } catch (e: Exception) {
                null
            }
        } else {
            null
        }

        return PlaybackTrack(
            trackUrl = trackUrl,
            verses = verses,
            timing = timing,
        )
    }

    private suspend fun loadRecitersData(): Pair<List<Mp3QuranReciterDto>, List<Mp3QuranReciterDto>> =
        mutex.withLock {
            val cachedEng = cachedReciters
            val cachedAr = cachedArabicNames
            if (cachedEng != null && cachedAr != null) {
                return@withLock (cachedEng to cachedAr.map { Mp3QuranReciterDto(it.key, it.value) })
            }

            coroutineScope {
                val engDeferred = async {
                    try {
                        api.reciters(language = "eng")
                    } catch (e: Exception) {
                        emptyList()
                    }
                }
                val arDeferred = async {
                    try {
                        api.reciters(language = "ar")
                    } catch (e: Exception) {
                        emptyList()
                    }
                }
                val eng = engDeferred.await()
                val ar = arDeferred.await()
                cachedReciters = eng
                cachedArabicNames = ar.associate { it.id to it.name }
                eng to ar
            }
        }

    private suspend fun loadRiwayat(): Map<Int, String> = mutex.withLock {
        cachedRiwayat?.let { return@withLock it }
        val list = try {
            api.riwayat(language = "eng")
        } catch (e: Exception) {
            emptyList()
        }
        val map = list.associate { it.id to it.name }
        cachedRiwayat = map
        map
    }

    private suspend fun loadTimedReadIds(): Set<Int> = mutex.withLock {
        cachedTimedReadIds?.let { return@withLock it }
        val list = try {
            api.timedReads()
        } catch (e: Exception) {
            emptyList()
        }
        val set = list.map { it.id }.toSet()
        cachedTimedReadIds = set
        set
    }

    internal fun deriveRiwayahAndStyle(
        moshaf: Mp3QuranMoshafDto,
        riwayatMap: Map<Int, String>,
    ): Pair<Riwayah, String> {
        val rewayaId = moshaf.rewayaId
        val canonicalName = if (rewayaId != null) riwayatMap[rewayaId] else null

        if (canonicalName != null) {
            val cleanedRiwayahName = cleanRiwayahName(canonicalName)
            val style = extractStyle(moshaf.name, canonicalName, cleanedRiwayahName)
            return Riwayah(id = rewayaId, name = cleanedRiwayahName) to style
        }

        // Try matching name in moshaf.name
        for ((id, name) in riwayatMap) {
            val cleanedName = cleanRiwayahName(name)
            if (moshaf.name.contains(name, ignoreCase = true) || moshaf.name.contains(cleanedName, ignoreCase = true)) {
                val style = extractStyle(moshaf.name, name, cleanedName)
                return Riwayah(id = id, name = cleanedName) to style
            }
        }

        // Fallback to Unspecified
        val fallbackStyle = moshaf.name.trim().ifBlank { "Murattal" }
        return Riwayah(id = null, name = "Unspecified") to fallbackStyle
    }

    private fun cleanRiwayahName(rawName: String): String =
        rawName.replace(Regex("^Rewayat\\s+", RegexOption.IGNORE_CASE), "").trim()

    private fun extractStyle(moshafName: String, canonicalName: String, cleanedName: String): String {
        var rem = moshafName
        rem = rem.replace(canonicalName, "", ignoreCase = true)
        rem = rem.replace(cleanedName, "", ignoreCase = true)
        rem = rem.replace(Regex("^Rewayat\\s+", RegexOption.IGNORE_CASE), "")
        rem = rem.trim().trim('-', '/', '–').trim()
        return rem.ifBlank { "Murattal" }
    }
}
