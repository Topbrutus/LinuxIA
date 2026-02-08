#!/usr/bin/env bash
set -euo pipefail

DIR="/opt/linuxia/data/shareA/archives/configsnap"
OUT="/opt/linuxia/docs/CONFIGSNAP_LATEST.txt"

LATEST="$(ls -1t "$DIR"/linuxia-configsnap_*.tar.zst 2>/dev/null | head -n 1 || true)"
test -n "${LATEST}"

zstd -t "$LATEST" >/dev/null

{
  printf "CONFIGSNAP_LATEST\n"
  printf "Generated: %s\n" "$(date -Is)"
  printf "Archive: %s\n\n" "$LATEST"
  tar -I zstd -tf "$LATEST"
} > "$OUT"
