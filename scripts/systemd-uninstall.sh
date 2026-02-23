#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/etc/systemd/system"

units=(
  linuxia-configsnap.service
  linuxia-configsnap.timer
  linuxia-healthcheck.service
  linuxia-healthcheck.timer
  linuxia-repair.service
)

echo "[linuxia] stopping/disabling timers"
sudo systemctl disable --now linuxia-configsnap.timer || true
sudo systemctl disable --now linuxia-healthcheck.timer || true

for u in "${units[@]}"; do
  if [[ -f "$DEST_DIR/$u" ]]; then
    echo "[linuxia] remove $DEST_DIR/$u"
    sudo rm -f "$DEST_DIR/$u"
  fi
done

echo "[linuxia] systemctl daemon-reload"
sudo systemctl daemon-reload

echo "[linuxia] done."
