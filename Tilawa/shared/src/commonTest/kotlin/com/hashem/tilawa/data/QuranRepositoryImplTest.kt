package com.hashem.tilawa.data

import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.RevelationPlace
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
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
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

private data class MockRoute(
    val pathSuffix: String,
    val querySubstring: String? = null,
    val responseJson: String,
)

class QuranRepositoryImplTest {

    private fun createRepository(
        routes: List<MockRoute>,
        customTextSource: LocalQuranTextSource? = null,
        customDownloadStore: DownloadStore? = null,
    ): QuranRepositoryImpl {
        val http = HttpClient(
            MockEngine { request ->
                val path = request.url.encodedPath
                val query = request.url.encodedQuery
                val matched = routes.firstOrNull { route ->
                    path.endsWith(route.pathSuffix) &&
                        (route.querySubstring == null || query.contains(route.querySubstring))
                } ?: error("No route matching: $path?$query")
                respond(
                    matched.responseJson,
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
        return QuranRepositoryImpl(
            api = Mp3QuranApi(http),
            localTextSource = customTextSource ?: LocalQuranTextSource(),
            downloadStore = customDownloadStore ?: InMemoryDownloadStore(),
        )
    }

    @Test
    fun `reciters pairs english and arabic names`() = runTest {
        val repo = createRepository(
            listOf(
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=eng",
                    responseJson = """
                        {
                          "reciters": [
                            { "id": 1, "name": "Ibrahim Al-Akdar", "moshaf": [] },
                            { "id": 3, "name": "Abdur-Rahman As-Sudais", "moshaf": [] }
                          ]
                        }
                    """,
                ),
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=ar",
                    responseJson = """
                        {
                          "reciters": [
                            { "id": 1, "name": "إبراهيم الأخضر", "moshaf": [] },
                            { "id": 3, "name": "عبد الرحمن السديس", "moshaf": [] }
                          ]
                        }
                    """,
                ),
            )
        )

        val reciters = repo.reciters()
        assertEquals(
            listOf(
                Reciter(1, "Ibrahim Al-Akdar", "إبراهيم الأخضر"),
                Reciter(3, "Abdur-Rahman As-Sudais", "عبد الرحمن السديس"),
            ),
            reciters,
        )
    }

    @Test
    fun `editions derives riwayah and style and resolves hasTiming`() = runTest {
        val repo = createRepository(
            listOf(
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=eng",
                    responseJson = """
                        {
                          "reciters": [
                            {
                              "id": 1,
                              "name": "Ibrahim Al-Akdar",
                              "moshaf": [
                                {
                                  "id": 101,
                                  "name": "Rewayat Hafs A'n Assem - Murattal",
                                  "rewaya_id": 1,
                                  "server": "https://server6.mp3quran.net/akdr/",
                                  "surah_list": "1,2,3"
                                },
                                {
                                  "id": 102,
                                  "name": "Warsh A'n Nafi' - Al-Musshaf Al-Moa'lim",
                                  "rewaya_id": 2,
                                  "server": "https://server6.mp3quran.net/akdr_warsh/",
                                  "surah_list": "1,114"
                                },
                                {
                                  "id": 103,
                                  "name": "Special Reading Unknown",
                                  "rewaya_id": 999,
                                  "server": "https://server6.mp3quran.net/special/",
                                  "surah_list": "1"
                                }
                              ]
                            }
                          ]
                        }
                    """,
                ),
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=ar",
                    responseJson = """{ "reciters": [] }""",
                ),
                MockRoute(
                    pathSuffix = "/riwayat",
                    responseJson = """
                        {
                          "riwayat": [
                            { "id": 1, "name": "Rewayat Hafs A'n Assem" },
                            { "id": 2, "name": "Rewayat Warsh A'n Nafi'" }
                          ]
                        }
                    """,
                ),
                MockRoute(
                    pathSuffix = "/ayat_timing/reads",
                    responseJson = """
                        [
                          { "id": 101, "name": "Ibrahim Al-Akdar" }
                        ]
                    """,
                ),
            )
        )

        val editions = repo.editions(1)
        assertEquals(3, editions.size)

        val e1 = editions[0]
        assertEquals(101, e1.id)
        assertEquals("Hafs A'n Assem", e1.riwayah.name)
        assertEquals(1, e1.riwayah.id)
        assertEquals("Murattal", e1.style)
        assertEquals(setOf(1, 2, 3), e1.availableSurahs)
        assertTrue(e1.hasTiming)

        val e2 = editions[1]
        assertEquals(102, e2.id)
        assertEquals("Warsh A'n Nafi'", e2.riwayah.name)
        assertEquals(2, e2.riwayah.id)
        assertEquals("Al-Musshaf Al-Moa'lim", e2.style)
        assertFalse(e2.hasTiming)

        val e3 = editions[2]
        assertEquals(103, e3.id)
        assertEquals("Unspecified", e3.riwayah.name)
        assertNull(e3.riwayah.id)
        assertEquals("Special Reading Unknown", e3.style)
        assertFalse(e3.hasTiming)
    }

    @Test
    fun `playbackTrack returns track with timing when available`() = runTest {
        val repo = createRepository(
            listOf(
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=eng",
                    responseJson = """
                        {
                          "reciters": [
                            {
                              "id": 1,
                              "name": "Ibrahim Al-Akdar",
                              "moshaf": [
                                {
                                  "id": 101,
                                  "name": "Rewayat Hafs A'n Assem - Murattal",
                                  "server": "https://server6.mp3quran.net/akdr/",
                                  "surah_list": "1"
                                }
                              ]
                            }
                          ]
                        }
                    """,
                ),
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=ar",
                    responseJson = """{ "reciters": [] }""",
                ),
                MockRoute(
                    pathSuffix = "/riwayat",
                    responseJson = """{ "riwayat": [] }""",
                ),
                MockRoute(
                    pathSuffix = "/ayat_timing/reads",
                    responseJson = """[ { "id": 101 } ]""",
                ),
                MockRoute(
                    pathSuffix = "/ayat_timing",
                    responseJson = """
                        [
                          { "ayah": 0, "start_time": 0, "end_time": 3000 },
                          { "ayah": 1, "start_time": 3000, "end_time": 8000 },
                          { "ayah": 2, "start_time": 8000, "end_time": 14000 }
                        ]
                    """,
                ),
            )
        )

        val track = repo.playbackTrack(chapterId = 1, editionId = 101)
        assertEquals("https://server6.mp3quran.net/akdr/001.mp3", track.trackUrl)
        assertEquals(7, track.verses.size)
        assertEquals(
            listOf(
                VerseTiming(1, 3000, 8000),
                VerseTiming(2, 8000, 14000),
            ),
            track.timing,
        )
    }

    @Test
    fun `playbackTrack prefers local path when chapter is downloaded`() = runTest {
        val downloadStore = InMemoryDownloadStore()
        downloadStore.setStatus(101, 1, DownloadStatus.DOWNLOADED, "file:///local/cache/001.mp3")

        val repo = createRepository(
            listOf(
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=eng",
                    responseJson = """{ "reciters": [] }""",
                ),
                MockRoute(
                    pathSuffix = "/reciters",
                    querySubstring = "language=ar",
                    responseJson = """{ "reciters": [] }""",
                ),
                MockRoute(
                    pathSuffix = "/riwayat",
                    responseJson = """{ "riwayat": [] }""",
                ),
                MockRoute(
                    pathSuffix = "/ayat_timing/reads",
                    responseJson = """[]""",
                ),
            ),
            customDownloadStore = downloadStore,
        )

        val track = repo.playbackTrack(chapterId = 1, editionId = 101)
        assertEquals("file:///local/cache/001.mp3", track.trackUrl)
    }
}
