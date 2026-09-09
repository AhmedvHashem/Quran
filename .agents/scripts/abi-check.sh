#!/usr/bin/env bash
# Fail if the generated C ABI header drifts from the committed abi/ snapshots.
# First run (no snapshots) records them instead of failing.
#
# Portable: works in any project with the <root>/.agents/scripts/ layout and
# committed snapshots under <root>/abi/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"   # .agents/scripts -> project root
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

"$ROOT/.agents/scripts/abi-export.sh" "$TMP" >/dev/null

status=0
for target in mingwX64 linuxX64; do
    committed="$(find "$ROOT/abi/$target" -name '*_api.h' 2>/dev/null | head -n 1 || true)"
    fresh="$(find "$TMP/$target" -name '*_api.h' | head -n 1)"
    if [[ -z "$committed" ]]; then
        mkdir -p "$ROOT/abi/$target"
        cp "$fresh" "$ROOT/abi/$target/"
        echo "abi/$target: no snapshot existed; recorded initial snapshot"
        continue
    fi
    if ! diff -u "$committed" "$fresh"; then
        echo "ABI DRIFT in $target: update the C#/C++ adapters, then refresh with .agents/scripts/abi-export.sh" >&2
        status=1
    else
        echo "$target: ABI matches snapshot"
    fi
done
exit $status
