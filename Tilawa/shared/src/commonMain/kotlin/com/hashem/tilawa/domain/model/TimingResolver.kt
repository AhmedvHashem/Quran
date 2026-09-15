package com.hashem.tilawa.domain.model

internal fun List<VerseTiming>?.validatedTiming(verseCount: Int): List<VerseTiming>? {
    val allSegments = this?.sortedBy { it.startMs } ?: return null
    if (allSegments.any { it.verseNumber !in 0..verseCount || it.startMs < 0 || it.endMs <= it.startMs }) return null
    if (allSegments.zipWithNext().any { (current, next) -> current.endMs > next.startMs }) return null
    val segments = allSegments.filter { it.verseNumber > 0 }
    if (segments.isEmpty()) return null
    if (segments.map { it.verseNumber }.toSet() != (1..verseCount).toSet()) return null
    return segments
}

internal fun verseNumberAt(positionMs: Long, timing: List<VerseTiming>): Int? =
    timing.firstOrNull { positionMs >= it.startMs && positionMs < it.endMs }?.verseNumber?.takeIf { it > 0 }
