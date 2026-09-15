@file:OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)

package com.hashem.tilawa.data

import com.hashem.tilawa.domain.model.DownloadRecord
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.convert
import kotlinx.cinterop.toKString
import kotlinx.cinterop.usePinned
import kotlinx.serialization.json.Json
import platform.posix.SEEK_END
import platform.posix.fclose
import platform.posix.fflush
import platform.posix.fopen
import platform.posix.fread
import platform.posix.fseek
import platform.posix.ftell
import platform.posix.fwrite
import platform.posix.getenv
import platform.posix.mkdir
import platform.posix.rename
import platform.posix.rewind

internal actual fun defaultDownloadStore(): DownloadStore = LinuxFileDownloadStore()

private class LinuxFileDownloadStore(
    private val json: Json = Json { ignoreUnknownKeys = true },
) : DownloadStore {
    private val path = storagePath()
    private val records = readText(path)
        ?.let { runCatching { json.decodeFromString<List<DownloadRecord>>(it) }.getOrNull() }
        .orEmpty()
        .associateByTo(mutableMapOf()) { it.editionId to it.chapterId }

    override fun all(): List<DownloadRecord> = records.values.toList()

    override fun record(editionId: Int, chapterId: Int): DownloadRecord =
        records[editionId to chapterId] ?: emptyRecord(editionId, chapterId)

    override fun set(record: DownloadRecord) {
        records[record.editionId to record.chapterId] = record
        persist()
    }

    override fun remove(editionId: Int, chapterId: Int) {
        records.remove(editionId to chapterId)
        persist()
    }

    private fun persist() {
        val temporary = "$path.tmp"
        writeText(temporary, json.encodeToString(records.values.toList()))
        check(rename(temporary, path) == 0) { "Could not replace Tilawa download metadata" }
    }
}

private fun storagePath(): String {
    val xdg = getenv("XDG_STATE_HOME")?.toKString()
    if (!xdg.isNullOrBlank()) {
        mkdir("$xdg/tilawa", 448u)
        return "$xdg/tilawa/downloads.json"
    }

    val home = getenv("HOME")?.toKString() ?: "."
    mkdir("$home/.local", 448u)
    mkdir("$home/.local/state", 448u)
    mkdir("$home/.local/state/tilawa", 448u)
    return "$home/.local/state/tilawa/downloads.json"
}

private fun readText(path: String): String? {
    val file = fopen(path, "rb") ?: return null
    return try {
        check(fseek(file, 0, SEEK_END) == 0)
        val size = ftell(file)
        if (size <= 0) return ""
        rewind(file)
        val bytes = ByteArray(size.toInt())
        val read = bytes.usePinned { fread(it.addressOf(0), 1.convert(), bytes.size.convert(), file) }
        check(read.toLong() == size)
        bytes.decodeToString()
    } finally {
        fclose(file)
    }
}

private fun writeText(path: String, text: String) {
    val file = checkNotNull(fopen(path, "wb")) { "Could not write Tilawa download metadata" }
    try {
        val bytes = text.encodeToByteArray()
        val written = bytes.usePinned { fwrite(it.addressOf(0), 1.convert(), bytes.size.convert(), file) }
        check(written.toInt() == bytes.size)
        check(fflush(file) == 0)
    } finally {
        fclose(file)
    }
}
