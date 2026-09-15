package com.hashem.tilawa.data

import com.hashem.tilawa.api.quranRequest

import com.hashem.tilawa.data.local.LocalQuranTextSource
import com.hashem.tilawa.data.remote.Mp3QuranApi
import com.hashem.tilawa.domain.model.Chapter
import com.hashem.tilawa.domain.model.DownloadRecord
import com.hashem.tilawa.domain.model.DownloadStatus
import com.hashem.tilawa.domain.model.Reciter
import com.hashem.tilawa.domain.model.RecordingIdentity
import com.hashem.tilawa.domain.model.RevelationPlace
import com.hashem.tilawa.domain.model.QuranErrorCode
import com.hashem.tilawa.domain.model.QuranException
import com.hashem.tilawa.domain.model.TextAvailability
import com.hashem.tilawa.domain.model.Verse
import com.hashem.tilawa.domain.model.VerseTiming
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.CancellationException
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.test.assertFailsWith

private data class MockRoute(
    val pathSuffix: String,
    val querySubstring: String? = null,
    val responseJson: String,
    val status: HttpStatusCode = HttpStatusCode.OK,
    var failuresRemaining: Int = 0,
    var failure: Throwable? = null,
    var attempts: Int = 0,
)

class QuranRepositoryImplTest {

    @Test
    fun `native result preserves failure code retryability and cancellation without leaking provider details`() = runTest {
        val (empty, noFailure) = quranRequest { emptyList<Reciter>() }
        assertEquals(emptyList(), empty)
        assertNull(noFailure)
        val (value, failure) = quranRequest<Reciter> {
            throw QuranException(QuranErrorCode.NETWORK, true, "https://provider/internal")
        }
        assertNull(value)
        assertEquals(QuranErrorCode.NETWORK, failure?.code)
        assertEquals(true, failure?.retryable)
        assertFalse(failure!!.message.contains("provider"))
        assertFailsWith<CancellationException> { quranRequest { throw CancellationException("cancelled") } }
    }

    private fun verifiedTextSource() = LocalQuranTextSource(
        manifest = LocalQuranTextSource.CONTENT_MANIFEST.copy(isVerified = true),
    )

    private fun unverifiedTextSource() = LocalQuranTextSource(
        manifest = LocalQuranTextSource.CONTENT_MANIFEST.copy(isVerified = false),
    )

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
                matched.attempts++
                matched.failure?.let { throw it }
                if (matched.failuresRemaining > 0) {
                    matched.failuresRemaining--
                    error("offline")
                }
                respond(
                    matched.responseJson,
                    status = matched.status,
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
                          { "id": 101, "name": "Ibrahim Al-Akdar", "folder_url": "https://server6.mp3quran.net/akdr/" }
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
                                  "rewaya_id": 1,
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
                    responseJson = """{ "riwayat": [{ "id": 1, "name": "Rewayat Hafs A'n Assem" }] }""",
                ),
                MockRoute(
                    pathSuffix = "/ayat_timing/reads",
                    responseJson = """[ { "id": 101, "folder_url": "https://server6.mp3quran.net/akdr/" } ]""",
                ),
                MockRoute(
                    pathSuffix = "/ayat_timing",
                    responseJson = """
                        [
                          { "ayah": 0, "start_time": 0, "end_time": 3000 },
                          { "ayah": 1, "start_time": 3000, "end_time": 8000 },
                          { "ayah": 2, "start_time": 8000, "end_time": 14000 },
                          { "ayah": 3, "start_time": 14000, "end_time": 20000 },
                          { "ayah": 4, "start_time": 20000, "end_time": 26000 },
                          { "ayah": 5, "start_time": 26000, "end_time": 32000 },
                          { "ayah": 6, "start_time": 32000, "end_time": 38000 },
                          { "ayah": 7, "start_time": 38000, "end_time": 44000 }
                        ]
                    """,
                ),
            ),
            customTextSource = verifiedTextSource(),
        )

        val track = repo.playbackTrack(chapterId = 1, editionId = 101)
        assertEquals("https://server6.mp3quran.net/akdr/001.mp3", track.trackUrl)
        assertEquals(7, track.verses.size)
        assertEquals(
            listOf(
                VerseTiming(1, 3000, 8000),
                VerseTiming(2, 8000, 14000),
                VerseTiming(3, 14000, 20000),
                VerseTiming(4, 20000, 26000),
                VerseTiming(5, 26000, 32000),
                VerseTiming(6, 32000, 38000),
                VerseTiming(7, 38000, 44000),
            ),
            track.timing,
        )
    }

    @Test
    fun `playbackTrack prefers local path when chapter is downloaded`() = runTest {
        val downloadStore = InMemoryDownloadStore()
        downloadStore.set(
            DownloadRecord(
                editionId = 101,
                chapterId = 1,
                status = DownloadStatus.DOWNLOADED,
                localPath = "file:///local/cache/001.mp3",
                checksumSha256 = "a".repeat(64),
                byteCount = 42,
                identity = RecordingIdentity("mp3quran.net", 101, 1, 1, "Murattal", "revision-1"),
            )
        )

        val repo = createRepository(
            emptyList(),
            customDownloadStore = downloadStore,
        )

        val track = repo.playbackTrack(chapterId = 1, editionId = 101)
        assertEquals("file:///local/cache/001.mp3", track.trackUrl)
    }

    @Test
    fun `playbackTrack rejects a surah absent from the edition`() = runTest {
        val repo = createRepository(
            listOf(
                MockRoute(
                    "/reciters",
                    "language=eng",
                    """{ "reciters": [{ "id": 1, "name": "Reciter", "moshaf": [{ "id": 101, "name": "Hafs", "rewaya_id": 1, "server": "https://audio/", "surah_list": "1" }] }] }""",
                ),
                MockRoute("/reciters", "language=ar", """{ "reciters": [] }"""),
            )
        )

        val failure = assertFailsWith<QuranException> { repo.playbackTrack(2, 101) }

        assertEquals(QuranErrorCode.SURAH_UNAVAILABLE, failure.code)
        assertFalse(failure.retryable)
    }

    @Test
    fun `unverified text returns an explicit audio-only track`() = runTest {
        val repo = createRepository(
            listOf(
                MockRoute(
                    "/reciters",
                    "language=eng",
                    """{ "reciters": [{ "id": 1, "name": "Reciter", "moshaf": [{ "id": 101, "name": "Hafs", "rewaya_id": 1, "server": "https://audio/", "surah_list": "1" }] }] }""",
                ),
                MockRoute("/reciters", "language=ar", """{ "reciters": [] }"""),
                MockRoute("/riwayat", responseJson = """{ "riwayat": [{ "id": 1, "name": "Rewayat Hafs" }] }"""),
            ),
            customTextSource = unverifiedTextSource(),
        )

        val track = repo.playbackTrack(1, 101)

        assertEquals(TextAvailability.AUDIO_ONLY, track.textAvailability)
        assertTrue(track.verses.isEmpty())
        assertNull(track.timing)
    }

    @Test
    fun `failed catalog request is not cached and can retry`() = runTest {
        val english = MockRoute(
            "/reciters",
            "language=eng",
            """{ "reciters": [{ "id": 1, "name": "Reciter" }] }""",
            failuresRemaining = 1,
        )
        val repo = createRepository(
            listOf(english, MockRoute("/reciters", "language=ar", """{ "reciters": [] }"""))
        )

        val failure = assertFailsWith<QuranException> { repo.reciters() }
        assertTrue(failure.retryable)
        assertEquals(listOf(Reciter(1, "Reciter", "Reciter")), repo.reciters())
        assertEquals(2, english.attempts)
    }

    @Test
    fun `catalog cancellation remains cancellation`() = runTest {
        val repo = createRepository(
            listOf(
                MockRoute(
                    "/reciters",
                    "language=eng",
                    "",
                    failure = CancellationException("cancelled"),
                ),
                MockRoute("/reciters", "language=ar", """{ "reciters": [] }"""),
            )
        )

        assertFailsWith<CancellationException> { repo.reciters() }
    }
    private fun playbackRoutes(timedReads: MockRoute) = listOf(
        MockRoute("/reciters", "language=eng", """{"reciters":[{"id":1,"name":"Reciter","moshaf":[{"id":101,"name":"Hafs","rewaya_id":1,"server":"https://audio/","surah_list":"0,1,115,bad"}]}]}"""),
        MockRoute("/reciters", "language=ar", """{"reciters":[]}"""),
        MockRoute("/riwayat", responseJson = """{"riwayat":[{"id":1,"name":"Rewayat Hafs"}]}"""),
        timedReads,
        MockRoute("/ayat_timing", responseJson = "[]"),
    )

    @Test
    fun `timing discovery failure degrades and retries without blocking editions or audio`() = runTest {
        val reads = MockRoute("/ayat_timing/reads", responseJson = """[{"id":101,"folder_url":"https://audio/"}]""", failuresRemaining = 2)
        val repo = createRepository(playbackRoutes(reads))
        assertFalse(repo.editions(1).single().hasTiming)
        val track = repo.playbackTrack(1, 101)
        assertEquals("https://audio/001.mp3", track.trackUrl)
        assertNull(track.timing)
        assertTrue(repo.editions(1).single().hasTiming)
        assertEquals(3, reads.attempts)
    }

    @Test
    fun `timing requires matching recording folder and unavailable surahs are filtered`() = runTest {
        val routes = playbackRoutes(MockRoute("/ayat_timing/reads", responseJson = """[{"id":101,"folder_url":"https://different-recording/"}]"""))
        val repo = createRepository(routes)
        val edition = repo.editions(1).single()
        assertEquals(setOf(1), edition.availableSurahs)
        assertFalse(edition.hasTiming)
        assertNull(repo.playbackTrack(1, 101).timing)
        assertEquals(0, routes.last().attempts)
        assertFailsWith<QuranException> { repo.playbackTrack(115, 101) }
    }

    @Test
    fun `timing cancellation propagates and does not poison retry`() = runTest {
        val reads = MockRoute("/ayat_timing/reads", responseJson = "[]", failure = CancellationException("cancelled"))
        val repo = createRepository(playbackRoutes(reads))
        assertFailsWith<CancellationException> { repo.playbackTrack(1, 101) }
        reads.failure = null
        assertNull(repo.playbackTrack(1, 101).timing)
        assertEquals(2, reads.attempts)
    }

    @Test
    fun `incompatible riwayah has no text or timing even when the timing service supports it`() = runTest {
        val routes = playbackRoutes(MockRoute("/ayat_timing/reads", responseJson = "[]"))
        val incompatible = LocalQuranTextSource(manifest = LocalQuranTextSource.CONTENT_MANIFEST.copy(supportedRiwayahIds = setOf(2)))
        val track = createRepository(routes, customTextSource = incompatible).playbackTrack(1, 101)
        assertEquals(TextAvailability.AUDIO_ONLY, track.textAvailability)
        assertTrue(track.verses.isEmpty())
        assertNull(track.timing)
        assertEquals(0, routes[3].attempts)
    }

    @Test
    fun `successful empty catalog is cached but cancelled catalog can retry`() = runTest {
        val english = MockRoute("/reciters", "language=eng", """{"reciters":[]}""", failure = CancellationException("cancelled"))
        val repo = createRepository(listOf(english, MockRoute("/reciters", "language=ar", """{"reciters":[]}""")))
        assertFailsWith<CancellationException> { repo.reciters() }
        english.failure = null
        assertTrue(repo.reciters().isEmpty())
        assertTrue(repo.reciters().isEmpty())
        assertEquals(2, english.attempts)
    }

}
