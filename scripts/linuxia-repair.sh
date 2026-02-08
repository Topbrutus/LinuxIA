#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
TAG="linuxia-repair"

if ! [[ -t 1 ]] && command -v systemd-cat >/dev/null 2>&1; then
  exec > >(systemd-cat -t "$TAG") 2>&1
fi

log() { printf '[%s] %s\n' "$(date -Is)" "$*"; }

log "START repair routine"

if /opt/linuxia/scripts/linuxia-healthcheck.sh; then
  log "healthcheck OK, nothing to repair"
  exit 0
fi

log "healthcheck FAIL, attempting safe fixes"

timeout 60s mount -a || true

if [ -x /usr/local/sbin/linuxia-samba-remount.sh ]; then
  timeout 180s /usr/local/sbin/linuxia-samba-remount.sh || true
fi

if /opt/linuxia/scripts/linuxia-healthcheck.sh; then
  chown gaby:users /opt/linuxia/docs/STATE_HEALTHCHECK.md /opt/linuxia/docs/STATE_VM100.md /opt/linuxia/docs/CONFIGSNAP_LATEST.txt 2>/dev/null || true
  log "repair succeeded"
  exit 0
fi

log "repair failed (healthcheck still failing)"
exit 1
