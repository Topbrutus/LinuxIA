#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$BASE_DIR/services/systemd"
DEST_DIR="/etc/systemd/system"

units=(
  linuxia-configsnap.service
  linuxia-configsnap.timer
  linuxia-healthcheck.service
  linuxia-healthcheck.timer
  linuxia-repair.service
)

echo "[linuxia] Installing units from: $SRC_DIR"
for u in "${units[@]}"; do
  src="$SRC_DIR/$u"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: missing $src" >&2
    exit 1
  fi
done

for u in "${units[@]}"; do
  echo "[linuxia] install $u -> $DEST_DIR/$u"
  sudo install -m 0644 "$SRC_DIR/$u" "$DEST_DIR/$u"
done

echo "[linuxia] systemctl daemon-reload"
sudo systemctl daemon-reload

echo "[linuxia] enable timers"
sudo systemctl enable --now linuxia-configsnap.timer
sudo systemctl enable --now linuxia-healthcheck.timer

echo "[linuxia] status timers"
sudo systemctl list-timers --all | grep linuxia || true

echo "[linuxia] done."
