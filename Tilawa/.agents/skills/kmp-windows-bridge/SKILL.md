---
name: kmp-windows-bridge
description: Building the Windows C# adapter over the Kotlin/Native DLL and WinUI 3 app code. Use when editing the WinUI/C# project (windowsApp/**), P/Invoke declarations, SafeHandle wrappers, Task/IAsyncEnumerable adapters, or WinUI view models consuming the shared core.
---

# Windows Bridge (WinUI 3 / C#)

Governing contract: the project's architecture plan ("Windows adapter and the remaining C# challenge") when present. Kotlin/Native emits a DLL + C header (see `kmp-c-abi`); this skill is the managed side of that boundary.

## Layering

```
WinUI view model → Shared.cs (idiomatic C#) → P/Invoke declarations (internal) → Shared.dll
```

No P/Invoke type, `IntPtr`, or delegate lifetime concern may leak into WinUI code. WinUI consumes an ordinary C# interface.

## Adapter conventions

- **Handles**: every native handle wrapped in a `SafeHandle` subclass whose `ReleaseHandle` calls the native dispose. Deterministic disposal; finalizer is only a safety net.
- **P/Invoke**: `[LibraryImport]` (source-generated) in one `internal static partial class NativeMethods`. Nothing else touches interop.
- **suspend → Task**: native completion callback + `TaskCompletionSource<T>` (`RunContinuationsAsynchronously`). Exactly-once completion for success / typed error / cancellation. Handle synchronous startup failure before the operation handle exists.
- **Flow → streams**: default shape is `IAsyncEnumerable<T>` (cancellation-token in, subscription handle underneath; stops native collection on dispose). `IObservable<T>` only if a screen needs replay/multicast semantics.
- **Delegates**: pin (`GCHandle`) every callback delegate for the full native lifetime; free it only after the operation/subscription is disposed. Pass the `GCHandle` pointer as the opaque `void* context`.
- **Cancellation**: `CancellationToken.Register` → `shared_operation_cancel`. Idempotent, race-safe with completion and disposal.
- **Errors**: native `{ code, message }` → typed C# exceptions for operational failures, `OperationCanceledException` for cancellation. Never let a managed exception cross into a native callback — wrap callback bodies in try/catch and store the error.
- **Threading**: callbacks arrive on native worker threads. Marshal to the WinUI `DispatcherQueue` in the view-model layer, never inside the adapter's hot path.
- **Payloads**: UTF-8 JSON from the ABI → deserialize with `System.Text.Json` source-gen contexts into C# models.

## Verify

- `dotnet build` the WinUI project after any ABI change.
- Run `.agents/scripts/abi-check.sh` — drift means this adapter must be updated in the same change.
- Stress: open/close a streaming screen repeatedly; watch native memory and confirm no leaked handles.
