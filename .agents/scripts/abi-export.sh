#!/usr/bin/env bash
# Build the mingwX64/linuxX64 shared libraries and snapshot their generated
# C headers into abi/<target>/. Used by abi-check.sh; run it directly to
# refresh snapshots after an intentional ABI change.
#
# Portable: works in any project with the <root>/.agents/scripts/ layout and
# a Gradle :shared module. Snapshots land in <root>/abi/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"   # .agents/scripts -> project root
OUT_DIR="${1:-$ROOT/abi}"   # override with a temp dir for drift checks
cd "$ROOT"

./gradlew :shared:linkReleaseSharedMingwX64 :shared:linkReleaseSharedLinuxX64

for target in mingwX64 linuxX64; do
    header_dir="shared/build/bin/$target/releaseShared"
    header="$(find "$header_dir" -maxdepth 1 -name '*_api.h' | head -n 1)"
    if [[ -z "$header" ]]; then
        echo "error: no *_api.h found in $header_dir" >&2
        exit 1
    fi
    mkdir -p "$OUT_DIR/$target"
    cp "$header" "$OUT_DIR/$target/"
    echo "snapshot: $OUT_DIR/$target/$(basename "$header")"
done
