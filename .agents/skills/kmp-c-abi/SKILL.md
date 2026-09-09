---
name: kmp-c-abi
description: Rules for the Kotlin/Native C ABI exported to Windows and Linux. Use when editing cApiMain, mingwX64Main, linuxX64Main, the C-export façade (SharedCApi.kt), generated *_api.h headers, or anything touching @CName, StableRef, staticCFunction, or the abi/ snapshots.
---

# Kotlin/Native C ABI (Windows + Linux)

Governing contract: the project's architecture plan ("Interop design principles") when present. The C header is the portability boundary — never expose arbitrary Kotlin classes.

## Allowed ABI shapes

- Opaque handles (`void*`) for stateful objects — wrap Kotlin refs with `StableRef.create()`, dispose with `.dispose()`
- Fixed-width numerics (`int32_t`, `int64_t`, `double`)
- UTF-8 `const char*` strings with one documented owner
- Pointer + length pairs for binary data
- Plain enums / int status codes
- Callback function pointers + opaque `void* context`
- Explicit cancellation handles

## Hard rules

1. **No exception crosses the ABI.** Catch everything at the Kotlin edge; return `{ code, message_utf8 }` error structs. Cancellation gets its own code, distinct from failure.
2. **One owner per allocation.** Document borrowed (callback-scoped), transferred (caller must free), or released-by-named-function for every pointer.
3. **Every handle has an explicit dispose.** `shared_create` ↔ `shared_dispose`, `shared_operation_*` ↔ `shared_operation_dispose`.
4. **Payloads are kotlinx.serialization JSON in UTF-8 strings.** This collapses collections, nullables, and nested models into one shape. Copy first; zero-copy only after benchmarks.
5. **Callbacks are async and may arrive on any thread.** UI dispatch belongs to the host (WinUI dispatcher / GLib main context) — never dispatch from shared code.
6. **Cancellation is real.** Every async export returns an operation handle; `shared_operation_cancel` must cancel the underlying coroutine, not just detach.
7. **Version the façade.** Export `shared_abi_version()` and `shared_version()`; evolve names/layouts compatibly.

## Kotlin-side mechanics

- All exports use the `shared_*` prefix via `@CName("shared_...")`, in ONE façade file (`SharedCApi.kt`) in the `cApiMain` source set shared by `mingwX64Main` and `linuxX64Main` — never per-target copies.
- `staticCFunction` lambdas must not capture; pass state through the `void* context` as a `StableRef`.
- Keep the exported surface tiny: core handle lifecycle, a handful of use-case operations, subscribe/cancel/dispose.

## ABI drift gate

Committed snapshots live in `abi/mingwX64/` and `abi/linuxX64/`. After changing any export:

```bash
.agents/scripts/abi-export.sh   # rebuilds libs, refreshes snapshots
.agents/scripts/abi-check.sh    # diffs generated header vs snapshot, fails on drift
```

CI runs `abi-check.sh`; a failing diff means the C#/C++ adapters must be updated in the same change.
