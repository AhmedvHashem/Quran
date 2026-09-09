---
name: kmp-core
description: Conventions for the KMP shared core. Use when editing the shared KMP module (shared/**) — adding dependencies, writing commonMain code, creating expect/actual declarations, or exposing API to the five native apps (Android, iOS, macOS, Windows, Linux).
---

# KMP Core

Governing contract: the project's architecture plan (e.g. `.ai/arch/APP_STACKS_PLAN.md`) when present. Share product logic and infrastructure; never UI, navigation, colors, or platform types.

## Targets (configured in `shared/build.gradle.kts`)

- `android` (Kotlin/JVM via AGP KMP library plugin)
- `iosArm64`, `iosSimulatorArm64` → static framework `Shared`
- `macosArm64` → static framework `Shared`
- `linuxX64`, `mingwX64` → `sharedLib` (C ABI, see `kmp-c-abi` skill)

Source sets: `commonMain`, `androidMain`, `appleMain` (default hierarchy, shared by iosMain + macosMain), `iosMain`, `macosArm64Main`, `linuxX64Main`, `mingwX64Main`, `cApiMain` (C-export façade shared by mingwX64Main + linuxX64Main).

## Approved library matrix (commonMain)

| Concern | Library | Notes |
|---|---|---|
| Async/streams | kotlinx-coroutines | core in commonMain; `Flow` is the state type |
| Serialization | kotlinx-serialization-json | also the C-ABI payload format |
| HTTP | ktor-client core + content-negotiation + serialization-kotlinx-json | engines per target (below) |
| Database | **not chosen yet — decision gate hit Aug 2026** | SQLDelight removed after verification: its runtime drags `co.touchlab:sqliter-driver` (`-lsqlite3`) into every native link; SQLiter has **no linuxX64 variant** and mingwX64 only links on a Windows host. SQLDelight remains valid for android/apple when a schema lands; mingw/linux persistence likely means Room KMP (bundled sqlite) — decide in the PoC slice |
| Key-value prefs | multiplatform-settings | ✅ compiled on all 5 targets |
| Date/time | kotlinx-datetime | |
| Logging | Kermit | |

Per-target engines/drivers:
- androidMain: `ktor-client-okhttp`
- appleMain: `ktor-client-darwin`
- mingwX64Main / linuxX64Main: `ktor-client-curl`

Verified Aug 2026: full `:shared:assemble` green on all 5 targets with the above (Kotlin 2.3.21, Ktor 3.1.3, settings 1.3.0, Kermit 2.0.5). Versions live in `gradle/libs.versions.toml` — the SQLDelight catalog entries stay for re-add but are unused.

Do NOT add: a DI framework (use manual constructor injection), KMP-NativeCoroutines, protobuf, or Compose Multiplatform. Add only when a measured need exists.

## API design rules

1. Expose a narrow use-case façade (`signIn`, `observeInbox`, `cancelOperation`), never internal object graphs, coroutine scopes, DB handles, or network clients.
2. Public models are immutable `data class`es serializable with kotlinx.serialization.
3. Async operations are `suspend fun`; live state is `Flow<T>`.
4. Errors are sealed domain types, not raw exceptions.
5. Platform services (secure storage, notifications, clock) enter via narrow interfaces declared in commonMain, implemented per platform.
6. `expect`/`actual` is the last resort — prefer passing platform implementations through constructors.

## Tests

`commonTest` with kotlin.test + kotlinx-coroutines-test + Ktor MockEngine. Every use case gets a contract test here before any platform consumes it.

## Verify

```bash
./gradlew :shared:assemble   # assembles all five targets
```
