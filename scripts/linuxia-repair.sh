#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

TAG="linuxia-repair"
REMOUNT_SCRIPT="/usr/local/sbin/linuxia-samba-remount.sh"
SHARE_A="/opt/linuxia/data/shareA"
SHARE_B="/opt/linuxia/data/shareB"

log() { printf "%s [%s] %s\n" "$(date -Is)" "$TAG" "$*"; }

exec > >(systemd-cat -t "$TAG" 2>/dev/null || cat) 2>&1

log "START"

if [ -x "$REMOUNT_SCRIPT" ]; then
  log "Running $REMOUNT_SCRIPT (timeout 180s)..."
  if timeout 180s "$REMOUNT_SCRIPT"; then
    log "Remount script completed successfully"
  else
    log "Remount script failed or timed out (exit $?), continuing to mount check"
  fi
fi

fail=0
findmnt -T "$SHARE_A" >/dev/null 2>&1 || { log "FAIL: $SHARE_A not mounted"; fail=1; }
findmnt -T "$SHARE_B" >/dev/null 2>&1 || { log "FAIL: $SHARE_B not mounted"; fail=1; }

if [ "$fail" -eq 0 ]; then
  log "OK: all shares mounted"
  exit 0
fi

log "FAIL: one or more shares are not mounted"
exit 1
