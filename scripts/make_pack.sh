#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-linuxia_readme_showcase_pack.zip}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

INCLUDES=(
  "README.md"
  "assets/readme/banner-linuxia.svg"
  "showcase"
  "docs"
  "scripts/make_pack.sh"
)

rm -f "$OUT"
zip -r "$OUT" "${INCLUDES[@]}" \
  -x "**/.DS_Store" "**/Thumbs.db" "**/.git/**"
