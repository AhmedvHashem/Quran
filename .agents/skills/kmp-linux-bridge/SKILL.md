---
name: kmp-linux-bridge
description: Building the Linux C++ adapter over the Kotlin/Native shared library and GTK 4/libadwaita app code. Use when editing the Linux app (linuxApp/**), C++ files, RAII wrappers around the C ABI, GLib main-context dispatch, or GTK view code consuming the shared core.
---

# Linux Bridge (GTK 4 / libadwaita / C++)

Governing contract: the project's architecture plan when present. Kotlin/Native emits `libShared.so` + C header (see `kmp-c-abi`); this skill is the C++ side of that boundary. GTK 4 + libadwaita is the GNOME-oriented UI choice; use gtkmm-4.0 for idiomatic C++ over the raw GTK C API.

## Layering

```
GTK widget → C++ client (RAII, value types) → thin ABI wrapper → libShared.so
```

No raw ABI call, handle, or `void*` context may appear in GTK view code.

## Adapter conventions

- **RAII everywhere**: every native handle in a move-only wrapper class whose destructor calls the native dispose. No `new`/`delete` of handles in view code.
- **Errors**: `{ code, message }` → `std::expected<T, CoreError>` (or a small Result type). Cancellation is its own error value.
- **Callbacks → async**: native callbacks land on arbitrary Kotlin/Native worker threads. Copy payload data inside the callback (buffers are callback-scoped — never store borrowed pointers), then hand off with `g_idle_add` (one-shot) or a `Glib::Dispatcher` (streams) before touching any GTK state.
- **Streams**: subscription handle wrapped in RAII; destructor cancels and disposes. Slow-consumer policy (conflate vs buffer) is set at subscribe time and documented per use case.
- **Cancellation**: one cancel function per operation handle; idempotent and race-safe with completion.
- **Payloads**: UTF-8 JSON from the ABI → deserialize with nlohmann/json (or the project's existing JSON lib) into C++ structs.
- **Lifetime**: the callback's `void* context` owns a heap object holding the completion target; it is freed exactly once — on completion, on cancel-acknowledged, or on subscription dispose, whichever the ABI contract states.

## Verify

- Build the Linux app after any ABI change; run `.agents/scripts/abi-check.sh` — drift means this adapter updates in the same change.
- Stress: repeated open/close of a streaming screen under `valgrind --tool=memcheck` (or ASAN) — no leaked handles, no use-after-dispose.
