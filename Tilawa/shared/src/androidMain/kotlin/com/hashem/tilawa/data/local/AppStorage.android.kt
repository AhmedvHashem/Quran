package com.hashem.tilawa.data.local

import android.content.Context
import androidx.startup.Initializer
import kotlinx.io.files.Path

private var stateDirectory: Path? = null

internal actual fun tilawaStateDirectory(): Path = checkNotNull(stateDirectory) {
    "Tilawa storage is not initialized. TilawaStorageInitializer runs through androidx.startup."
}

/** Captures the application's private files directory at process start. */
internal class TilawaStorageInitializer : Initializer<Unit> {
    override fun create(context: Context) {
        stateDirectory = Path(context.applicationContext.filesDir.absolutePath, "state")
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}
