#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="linuxia_readme_showcase_pack.zip"
cd "$ROOT"
INCLUDES=("README.md" "assets/readme/banner-linuxia.svg" "showcase" "docs" "scripts/make_pack.sh")
rm -f "$OUT"
zip -r "$OUT" "${INCLUDES[@]}" -x "**/.DS_Store" "**/Thumbs.db" "**/.git/**"
echo "OK -> $ROOT/$OUT"
