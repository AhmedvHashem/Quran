package com.hashem.tilawa

import kotlinx.cinterop.*
import kotlin.experimental.ExperimentalNativeApi
import kotlin.native.CName

// C-export façade for the GTK shell (see .opencode/skills/kmp-c-abi).
// Ownership: returned strings are nativeHeap-allocated and must be released
// by the caller via tilawaStringFree.

@OptIn(ExperimentalNativeApi::class, ExperimentalForeignApi::class)
@CName("tilawa_abi_version")
fun tilawaAbiVersion(): Int = 1

@OptIn(ExperimentalNativeApi::class, ExperimentalForeignApi::class)
@CName("tilawa_greet")
fun tilawaGreet(): CPointer<ByteVar> {
    val bytes = Greeting().greet().encodeToByteArray()
    val out = nativeHeap.allocArray<ByteVar>(bytes.size + 1)
    if (bytes.isNotEmpty()) {
        bytes.usePinned { platform.posix.memcpy(out, it.addressOf(0), bytes.size.convert()) }
    }
    out[bytes.size] = 0
    return out
}

@OptIn(ExperimentalNativeApi::class, ExperimentalForeignApi::class)
@CName("tilawa_string_free")
fun tilawaStringFree(value: CPointer<ByteVar>?) {
    value?.let { nativeHeap.free(it.rawValue) }
}
