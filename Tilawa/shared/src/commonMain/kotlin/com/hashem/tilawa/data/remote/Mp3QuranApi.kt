package com.hashem.tilawa.data.remote

import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/**
 * Transport for mp3quran.net API v3. Speaks DTOs only — no domain types here.
 */
internal class Mp3QuranApi(private val http: HttpClient) {

    suspend fun reciters(language: String = "eng"): List<Mp3QuranReciterDto> =
        http.get("$BASE/reciters") {
            url.parameters.append("language", language)
        }.body<Mp3QuranRecitersDto>().reciters

    suspend fun riwayat(language: String = "eng"): List<Mp3QuranRiwayahDto> =
        http.get("$BASE/riwayat") {
            url.parameters.append("language", language)
        }.body<Mp3QuranRiwayatDto>().riwayat

    suspend fun timedReads(): List<Mp3QuranTimedReadDto> =
        http.get("$BASE/ayat_timing/reads")
            .body<List<Mp3QuranTimedReadDto>>()

    suspend fun timing(surahId: Int, readId: Int): List<Mp3QuranAyahTimingDto> =
        http.get("$BASE/ayat_timing") {
            url.parameters.append("surah", surahId.toString())
            url.parameters.append("read", readId.toString())
        }.body<List<Mp3QuranAyahTimingDto>>()

    companion object {
        private const val BASE = "https://www.mp3quran.net/api/v3"

        fun defaultClient() = HttpClient {
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true
                    coerceInputValues = true
                })
            }
        }
    }
}

@Serializable
internal data class Mp3QuranRecitersDto(
    val reciters: List<Mp3QuranReciterDto> = emptyList(),
)

@Serializable
internal data class Mp3QuranReciterDto(
    val id: Int,
    val name: String,
    val letter: String? = null,
    val moshaf: List<Mp3QuranMoshafDto> = emptyList(),
)

@Serializable
internal data class Mp3QuranMoshafDto(
    val id: Int,
    val name: String,
    @SerialName("rewaya_id") val rewayaId: Int? = null,
    val server: String,
    @SerialName("surah_total") val surahTotal: Int = 0,
    @SerialName("moshaf_type") val moshafType: Int = 0,
    @SerialName("surah_list") val surahList: String = "",
)

@Serializable
internal data class Mp3QuranRiwayatDto(
    val riwayat: List<Mp3QuranRiwayahDto> = emptyList(),
)

@Serializable
internal data class Mp3QuranRiwayahDto(
    val id: Int,
    val name: String,
)

@Serializable
internal data class Mp3QuranTimedReadDto(
    val id: Int,
    val name: String? = null,
    val rewaya: String? = null,
    @SerialName("folder_url") val folderUrl: String? = null,
    @SerialName("soar_count") val soarCount: Int? = null,
    @SerialName("soar_link") val soarLink: String? = null,
)

@Serializable
internal data class Mp3QuranAyahTimingDto(
    val ayah: Int,
    @SerialName("start_time") val startTime: Long,
    @SerialName("end_time") val endTime: Long,
    val polygon: String? = null,
    val page: String? = null,
)
