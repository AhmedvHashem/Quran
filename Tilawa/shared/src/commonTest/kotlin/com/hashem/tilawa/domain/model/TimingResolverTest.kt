package com.hashem.tilawa.domain.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class TimingResolverTest {
    private val timing = listOf(
        VerseTiming(1, 1_000, 2_000),
        VerseTiming(2, 3_000, 4_000),
        VerseTiming(1, 5_000, 6_000),
    )

    @Test
    fun `uses half-open bounds and leaves intro gaps and ending unlabeled`() {
        assertNull(verseNumberAt(999, timing))
        assertEquals(1, verseNumberAt(1_000, timing))
        assertNull(verseNumberAt(2_000, timing))
        assertNull(verseNumberAt(2_500, timing))
        assertEquals(2, verseNumberAt(3_000, timing))
        assertEquals(1, verseNumberAt(5_500, timing))
        assertNull(verseNumberAt(6_000, timing))
    }

    @Test
    fun `rejects partial overlapping and missing timing`() {
        assertNull(null.validatedTiming(2))
        assertNull(listOf(VerseTiming(1, 0, 1_000)).validatedTiming(2))
        assertNull(listOf(VerseTiming(1, 0, 2_000), VerseTiming(2, 1_000, 3_000)).validatedTiming(2))
    }
}
