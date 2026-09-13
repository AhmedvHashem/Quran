package com.hashem.tilawa.domain.model

internal fun List<VerseTiming>?.validatedTiming(verseCount: Int): List<VerseTiming>? {
    val segments = this?.filter { it.verseNumber > 0 }?.sortedBy { it.startMs } ?: return null
    if (segments.isEmpty() || segments.any { it.startMs < 0 || it.endMs <= it.startMs }) return null
    if (segments.zipWithNext().any { (current, next) -> current.endMs > next.startMs }) return null
    if (segments.map { it.verseNumber }.toSet() != (1..verseCount).toSet()) return null
    return segments
}

internal fun verseNumberAt(positionMs: Long, timing: List<VerseTiming>): Int? =
    timing.firstOrNull { positionMs >= it.startMs && positionMs < it.endMs }?.verseNumber
