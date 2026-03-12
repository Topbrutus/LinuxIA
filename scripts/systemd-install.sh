#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="/etc/systemd/system"

# Units présentes dans services/systemd/
SYSTEMD_UNITS=(
  linuxia-configsnap.service
  linuxia-configsnap.timer
  linuxia-healthcheck.service
  linuxia-healthcheck.timer
  linuxia-repair.service
)

# Units présentes dans services/
SERVICES_UNITS=(
  linuxia-health-report.service
  linuxia-health-report.timer
)

echo "[linuxia] Installation des unités depuis: $BASE_DIR/services/{systemd,/}"

for u in "${SYSTEMD_UNITS[@]}"; do
  src="$BASE_DIR/services/systemd/$u"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: manquant $src" >&2
    exit 1
  fi
done

for u in "${SERVICES_UNITS[@]}"; do
  src="$BASE_DIR/services/$u"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: manquant $src" >&2
    exit 1
  fi
done

for u in "${SYSTEMD_UNITS[@]}"; do
  echo "[linuxia] install $u -> $DEST_DIR/$u"
  sudo install -m 0644 "$BASE_DIR/services/systemd/$u" "$DEST_DIR/$u"
done

for u in "${SERVICES_UNITS[@]}"; do
  echo "[linuxia] install $u -> $DEST_DIR/$u"
  sudo install -m 0644 "$BASE_DIR/services/$u" "$DEST_DIR/$u"
done

echo "[linuxia] systemctl daemon-reload"
sudo systemctl daemon-reload

echo "[linuxia] enable timers"
sudo systemctl enable --now linuxia-configsnap.timer
sudo systemctl enable --now linuxia-healthcheck.timer
sudo systemctl enable --now linuxia-health-report.timer

echo "[linuxia] status timers"
sudo systemctl list-timers --all | grep linuxia || true

echo "[linuxia] done."
