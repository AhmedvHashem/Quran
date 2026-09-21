@file:OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)

package com.hashem.tilawa.data.local

import kotlinx.cinterop.toKString
import kotlinx.io.files.Path
import platform.posix.getenv

internal actual fun tilawaStateDirectory(): Path {
    val base = sequenceOf("LOCALAPPDATA", "APPDATA", "USERPROFILE")
        .mapNotNull { getenv(it)?.toKString() }
        .firstOrNull { it.isNotBlank() } ?: "."
    return Path(base, "Tilawa")
}
