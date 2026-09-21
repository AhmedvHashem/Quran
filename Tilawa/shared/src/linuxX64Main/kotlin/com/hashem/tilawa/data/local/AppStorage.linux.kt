@file:OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)

package com.hashem.tilawa.data.local

import kotlinx.cinterop.toKString
import kotlinx.io.files.Path
import platform.posix.getenv

internal actual fun tilawaStateDirectory(): Path {
    val xdgState = getenv("XDG_STATE_HOME")?.toKString()
    if (!xdgState.isNullOrBlank()) return Path(xdgState, "tilawa")
    val home = getenv("HOME")?.toKString()?.takeIf { it.isNotBlank() } ?: "."
    return Path("$home/.local/state", "tilawa")
}
