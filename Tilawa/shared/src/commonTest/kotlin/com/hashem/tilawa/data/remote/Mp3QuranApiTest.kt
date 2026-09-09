package com.hashem.tilawa.data.remote

import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals

class Mp3QuranApiTest {

    private fun createApi(vararg routes: Pair<String, String>): Mp3QuranApi =
        Mp3QuranApi(
            HttpClient(
                MockEngine { request ->
                    val path = request.url.encodedPath
                    val matching = routes.firstOrNull { path.endsWith(it.first) }
                        ?: error("No mock response for path: $path")
                    respond(
                        matching.second,
                        headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
                    )
                }
            ) {
                install(ContentNegotiation) {
                    json(Json {
                        ignoreUnknownKeys = true
                        coerceInputValues = true
                    })
                }
            }
        )

    @Test
    fun `parses reciters and nested moshaf list`() = runTest {
        val api = createApi(
            "/reciters" to """
                {
                  "reciters": [
                    {
                      "id": 1,
                      "name": "Ibrahim Al-Akdar",
                      "letter": "I",
                      "moshaf": [
                        {
                          "id": 1,
                          "name": "Rewayat Hafs A'n Assem - Murattal",
                          "rewaya_id": 1,
                          "server": "https://server6.mp3quran.net/akdr/",
                          "surah_total": 114,
                          "moshaf_type": 11,
                          "surah_list": "1,2,3"
                        }
                      ]
                    }
                  ]
                }
            """
        )

        val reciters = api.reciters("eng")
        assertEquals(1, reciters.size)
        assertEquals(1, reciters[0].id)
        assertEquals("Ibrahim Al-Akdar", reciters[0].name)
        assertEquals(1, reciters[0].moshaf.size)
        assertEquals(1, reciters[0].moshaf[0].id)
        assertEquals("Rewayat Hafs A'n Assem - Murattal", reciters[0].moshaf[0].name)
        assertEquals(1, reciters[0].moshaf[0].rewayaId)
        assertEquals("https://server6.mp3quran.net/akdr/", reciters[0].moshaf[0].server)
    }

    @Test
    fun `parses canonical riwayat list`() = runTest {
        val api = createApi(
            "/riwayat" to """
                {
                  "riwayat": [
                    { "id": 1, "name": "Rewayat Hafs A'n Assem" },
                    { "id": 2, "name": "Rewayat Warsh A'n Nafi'" }
                  ]
                }
            """
        )

        val riwayat = api.riwayat("eng")
        assertEquals(2, riwayat.size)
        assertEquals(1, riwayat[0].id)
        assertEquals("Rewayat Hafs A'n Assem", riwayat[0].name)
        assertEquals(2, riwayat[1].id)
        assertEquals("Rewayat Warsh A'n Nafi'", riwayat[1].name)
    }

    @Test
    fun `parses timed reads list`() = runTest {
        val api = createApi(
            "/ayat_timing/reads" to """
                [
                  {
                    "id": 1,
                    "name": "Ibrahim Al-Akdar",
                    "rewaya": "Hafs A'n Assem",
                    "folder_url": "https://server6.mp3quran.net/akdr/",
                    "soar_count": 114
                  },
                  {
                    "id": 5,
                    "name": "Ahmed Al-Ajmy",
                    "rewaya": "Hafs A'n Assem",
                    "folder_url": "https://server10.mp3quran.net/ajm/",
                    "soar_count": 114
                  }
                ]
            """
        )

        val reads = api.timedReads()
        assertEquals(2, reads.size)
        assertEquals(1, reads[0].id)
        assertEquals(5, reads[1].id)
    }

    @Test
    fun `parses ayah timing list`() = runTest {
        val api = createApi(
            "/ayat_timing" to """
                [
                  { "ayah": 0, "start_time": 0, "end_time": 5000 },
                  { "ayah": 1, "start_time": 5000, "end_time": 12000 },
                  { "ayah": 2, "start_time": 12000, "end_time": 18500 }
                ]
            """
        )

        val timing = api.timing(surahId = 1, readId = 1)
        assertEquals(3, timing.size)
        assertEquals(0, timing[0].ayah)
        assertEquals(0L, timing[0].startTime)
        assertEquals(5000L, timing[0].endTime)
        assertEquals(1, timing[1].ayah)
        assertEquals(5000L, timing[1].startTime)
        assertEquals(12000L, timing[1].endTime)
    }
}
