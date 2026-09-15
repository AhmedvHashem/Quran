package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.data.remote.Mp3QuranMoshafDto
import com.hashem.tilawa.data.remote.Mp3QuranReciterDto
import com.hashem.tilawa.data.remote.Mp3QuranTimedReadDto
import com.hashem.tilawa.domain.QuranRepository
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.PlaybackTrack
import com.hashem.tilawa.domain.model.QuranErrorCode
import com.hashem.tilawa.domain.model.QuranException
import com.hashem.tilawa.domain.model.RecitationEdition
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.RecordingIdentity
import com.hashem.tilawa.domain.model.Riwayah
import com.hashem.tilawa.domain.model.TextAvailability
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
import com.hashem.tilawa.domain.model.validatedTiming
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

internal class QuranRepositoryImpl(
    private val api: Mp3QuranApi,
    private val localTextSource: LocalQuranTextSource = LocalQuranTextSource(),
    private val downloadStore: DownloadStore,
) : QuranRepository {
    private val mutex = Mutex()
    private var cachedReciters: Pair<List<Mp3QuranReciterDto>, List<Mp3QuranReciterDto>>? = null
    private var cachedRiwayat: Map<Int, String>? = null
    private var cachedTimedReads: List<Mp3QuranTimedReadDto>? = null

    companion object {
        private const val PROVIDER = "mp3quran.net"
        private val FEATURED_RECITER_ORDER = listOf(123, 54, 31, 118, 112, 51, 30, 74, 102, 92)
        private val FEATURED_EDITION_IDS = setOf(123, 54, 31, 118, 112, 51, 30, 74, 102, 92)
    }

    override suspend fun reciters(): List<Reciter> {
        val (english, arabic) = loadRecitersData()
        val arabicNames = arabic.associate { it.id to it.name }
        return english.sortedWith(compareBy {
            FEATURED_RECITER_ORDER.indexOf(it.id).takeIf { index -> index >= 0 } ?: Int.MAX_VALUE
        }).map {
            Reciter(it.id, it.name, arabicNames[it.id] ?: it.name)
        }
    }

    override suspend fun editions(reciterId: Int): List<RecitationEdition> {
        val reciter = loadRecitersData().first.find { it.id == reciterId } ?: return emptyList()
        val riwayat = loadRiwayat()
        val timedReads = loadTimedReads()
        return reciter.moshaf.map { it.toEdition(reciterId, riwayat, timedReads) }
    }

    override suspend fun chapters(): List<Chapter> = localTextSource.chapters()

    override suspend fun verses(chapterId: Int): List<Verse> = localTextSource.verses(chapterId)

    override suspend fun playbackTrack(chapterId: Int, editionId: Int): PlaybackTrack {
        if (chapterId !in 1..114) {
            throw QuranException(QuranErrorCode.SURAH_UNAVAILABLE, false, "Invalid surah $chapterId")
        }
        val downloaded = downloadStore.record(editionId, chapterId)
        if (downloaded.hasCompleteMetadata()) {
            val identity = checkNotNull(downloaded.identity)
            val compatible = downloaded.textEditionId == localTextSource.manifest.textEditionId &&
                isTextCompatible(identity)
            val verses = if (compatible) localTextSource.verses(chapterId) else emptyList()
            return PlaybackTrack(
                identity = identity,
                chapterId = chapterId,
                trackUrl = checkNotNull(downloaded.localPath),
                verses = verses,
                timing = if (compatible) downloaded.timing.validatedTiming(verses.size) else null,
                textAvailability = if (compatible) TextAvailability.VERIFIED else TextAvailability.AUDIO_ONLY,
            )
        }

        val reciter = loadRecitersData().first.firstOrNull { item -> item.moshaf.any { it.id == editionId } }
            ?: throw QuranException(QuranErrorCode.EDITION_NOT_FOUND, false, "Recording edition $editionId was not found")
        val moshaf = reciter.moshaf.first { it.id == editionId }
        val availableSurahs = moshaf.availableSurahs()
        if (chapterId !in availableSurahs) {
            throw QuranException(
                QuranErrorCode.SURAH_UNAVAILABLE,
                false,
                "Surah $chapterId is unavailable in recording edition $editionId",
            )
        }

        val (riwayah, style) = deriveRiwayahAndStyle(moshaf, loadRiwayat())
        val baseUrl = moshaf.server.withTrailingSlash()
        val identity = RecordingIdentity(
            provider = PROVIDER,
            editionId = editionId,
            reciterId = reciter.id,
            riwayahId = riwayah.id,
            style = style,
            revision = "$PROVIDER:$editionId:${baseUrl.trimEnd('/')}",
        )
        val compatible = isTextCompatible(identity)
        val verses = if (compatible) localTextSource.verses(chapterId) else emptyList()
        val timing = if (compatible && moshaf.matchesTiming(loadTimedReads())) {
            try {
                remote { api.timing(chapterId, editionId) }
                    .map { VerseTiming(it.ayah, it.startTime, it.endTime) }
                    .validatedTiming(verses.size)
            } catch (_: QuranException) {
                null
            }
        } else {
            null
        }

        return PlaybackTrack(
            identity = identity,
            chapterId = chapterId,
            trackUrl = "$baseUrl${chapterId.toString().padStart(3, '0')}.mp3",
            verses = verses,
            timing = timing,
            textAvailability = if (compatible) TextAvailability.VERIFIED else TextAvailability.AUDIO_ONLY,
        )
    }

    private fun isTextCompatible(identity: RecordingIdentity): Boolean =
        localTextSource.manifest.isVerified && identity.riwayahId in localTextSource.manifest.supportedRiwayahIds

    private suspend fun loadRecitersData(): Pair<List<Mp3QuranReciterDto>, List<Mp3QuranReciterDto>> = mutex.withLock {
        cachedReciters?.let { return@withLock it }
        val loaded = remote {
            coroutineScope {
                val english = async { api.reciters("eng") }
                val arabic = async { api.reciters("ar") }
                english.await() to arabic.await()
            }
        }
        cachedReciters = loaded
        loaded
    }

    private suspend fun loadRiwayat(): Map<Int, String> = mutex.withLock {
        cachedRiwayat?.let { return@withLock it }
        remote { api.riwayat("eng") }.associate { it.id to it.name }.also { cachedRiwayat = it }
    }

    private suspend fun loadTimedReads(): List<Mp3QuranTimedReadDto> = try {
        mutex.withLock {
            cachedTimedReads?.let { return@withLock it }
            remote { api.timedReads() }.also { cachedTimedReads = it }
        }
    } catch (_: QuranException) {
        // Timing is optional; do not cache an outage as a successful empty response.
        emptyList()
    }

    private suspend fun <T> remote(block: suspend () -> T): T = try {
        block()
    } catch (cancelled: CancellationException) {
        throw cancelled
    } catch (failure: QuranException) {
        throw failure
    } catch (failure: Exception) {
        throw QuranException(QuranErrorCode.NETWORK, true, failure.message ?: "Network request failed")
    }

    internal fun deriveRiwayahAndStyle(
        moshaf: Mp3QuranMoshafDto,
        riwayatMap: Map<Int, String>,
    ): Pair<Riwayah, String> {
        val canonicalName = moshaf.rewayaId?.let(riwayatMap::get)
        if (canonicalName != null) {
            val cleaned = cleanRiwayahName(canonicalName)
            return Riwayah(moshaf.rewayaId, cleaned) to extractStyle(moshaf.name, canonicalName, cleaned)
        }

        for ((id, name) in riwayatMap) {
            val cleaned = cleanRiwayahName(name)
            if (moshaf.name.contains(name, true) || moshaf.name.contains(cleaned, true)) {
                return Riwayah(id, cleaned) to extractStyle(moshaf.name, name, cleaned)
            }
        }

        return Riwayah(null, "Unspecified") to moshaf.name.trim().ifBlank { "Murattal" }
    }

    private fun Mp3QuranMoshafDto.toEdition(
        reciterId: Int,
        riwayatMap: Map<Int, String>,
        timedReads: List<Mp3QuranTimedReadDto>,
    ): RecitationEdition {
        val (riwayah, style) = deriveRiwayahAndStyle(this, riwayatMap)
        return RecitationEdition(
            id = id,
            reciterId = reciterId,
            riwayah = riwayah,
            style = style,
            serverBaseUrl = server.withTrailingSlash(),
            availableSurahs = availableSurahs(),
            hasTiming = riwayah.id in localTextSource.manifest.supportedRiwayahIds &&
                localTextSource.manifest.isVerified && matchesTiming(timedReads),
            isFeatured = id in FEATURED_EDITION_IDS,
        )
    }

    private fun Mp3QuranMoshafDto.availableSurahs(): Set<Int> =
        surahList.split(',').mapNotNull { it.trim().toIntOrNull() }.filter { it in 1..114 }.toSet()

    private fun Mp3QuranMoshafDto.matchesTiming(reads: List<Mp3QuranTimedReadDto>): Boolean =
        reads.any { it.id == id && it.folderUrl?.trimEnd('/') == server.trimEnd('/') }

    private fun String.withTrailingSlash() = if (endsWith('/')) this else "$this/"

    private fun cleanRiwayahName(rawName: String) =
        rawName.replace(Regex("^Rewayat\\s+", RegexOption.IGNORE_CASE), "").trim()

    private fun extractStyle(moshafName: String, canonicalName: String, cleanedName: String): String =
        moshafName
            .replace(canonicalName, "", ignoreCase = true)
            .replace(cleanedName, "", ignoreCase = true)
            .replace(Regex("^Rewayat\\s+", RegexOption.IGNORE_CASE), "")
            .trim().trim('-', '/', '–').trim()
            .ifBlank { "Murattal" }
}
