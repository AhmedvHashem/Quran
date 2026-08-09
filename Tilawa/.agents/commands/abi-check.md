---
description: Rebuild the Kotlin/Native C ABI for mingwX64/linuxX64 and report drift between the generated header and the committed abi/ snapshots.
---

# ABI Check

Run `scripts/abi-check.sh` from the repo root and report the result.

- If it passes: say so in one line.
- If it reports drift: show the symbol-level diff and list which adapters (`QuranWindows` C# P/Invoke layer, Linux C++ wrapper) must be updated to match, per the kmp-c-abi skill rules.
- If the build itself fails: report the failing Gradle task and error verbatim.
