package com.hashem.tilawa

import kotlinx.cinterop.*
import kotlin.experimental.ExperimentalNativeApi
import kotlin.native.CName

// C-export façade for the Windows/Linux shells (see .agents/skills/kmp-c-abi).
// Shared by mingwX64Main and linuxX64Main via the cApiMain source set.
// Ownership: returned strings are nativeHeap-allocated and must be released
// by the caller via shared_string_free.

@OptIn(ExperimentalNativeApi::class, ExperimentalForeignApi::class)
@CName("shared_abi_version")
fun sharedAbiVersion(): Int = 1

@OptIn(ExperimentalNativeApi::class, ExperimentalForeignApi::class)
@CName("shared_greet")
fun sharedGreet(): CPointer<ByteVar> {
    val bytes = Greeting().greet().encodeToByteArray()
    val out = nativeHeap.allocArray<ByteVar>(bytes.size + 1)
    if (bytes.isNotEmpty()) {
        bytes.usePinned { platform.posix.memcpy(out, it.addressOf(0), bytes.size.convert()) }
    }
    out[bytes.size] = 0
    return out
}

@OptIn(ExperimentalNativeApi::class, ExperimentalForeignApi::class)
@CName("shared_string_free")
fun sharedStringFree(value: CPointer<ByteVar>?) {
    value?.let { nativeHeap.free(it.rawValue) }
}
