package com.hashem.tilawa.data.local

import kotlinx.io.buffered
import kotlinx.io.files.Path
import kotlinx.io.files.SystemFileSystem
import kotlinx.io.readString
import kotlinx.io.writeString

/** Directory holding Tilawa's durable library state on this platform. */
internal expect fun tilawaStateDirectory(): Path

/** One durable text document. Reading an absent or unreadable document yields null. */
internal interface Document {
    fun read(): String?
    fun write(text: String)
}

/**
 * A document stored as a file. Writes land in a temporary file first and then
 * atomically replace the target, so a crash mid-write never leaves a partial
 * document behind.
 */
internal class FileDocument(
    name: String,
    private val directory: Path = tilawaStateDirectory(),
) : Document {
    private val file = Path(directory, name)
    private val temporary = Path(directory, "$name.tmp")

    override fun read(): String? {
        if (!SystemFileSystem.exists(file)) return null
        return runCatching {
            SystemFileSystem.source(file).buffered().use { it.readString() }
        }.getOrNull()
    }

    override fun write(text: String) {
        SystemFileSystem.createDirectories(directory)
        SystemFileSystem.sink(temporary).buffered().use { it.writeString(text) }
        SystemFileSystem.atomicMove(temporary, file)
    }
}
