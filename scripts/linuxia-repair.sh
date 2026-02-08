#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
TAG="linuxia-repair"

if ! [[ -t 1 ]] && command -v systemd-cat >/dev/null 2>&1; then
  exec > >(systemd-cat -t "$TAG") 2>&1
fi

log() { printf '[%s] %s\n' "$(date -Is)" "$*"; }

log "START repair routine"

# IMPORTANT:
# - Ne pas faire "mount -a" ici.
#   Sinon ntfs-3g tourne dans le cgroup du service, et systemd le tue à la fin => UNMOUNT.
# - On se limite à relancer un remount dédié si présent, et à vérifier les bind mounts.

if [ -x /usr/local/sbin/linuxia-samba-remount.sh ]; then
  timeout 180s /usr/local/sbin/linuxia-samba-remount.sh || true
fi

fail=0

findmnt -T /opt/linuxia/data/shareA >/dev/null 2>&1 || fail=1
findmnt -T /opt/linuxia/data/shareB >/dev/null 2>&1 || fail=1

if [ "$fail" -eq 1 ]; then
  log "repair incomplete (shareA/shareB not mounted)"
  exit 1
fi

log "repair OK"
exit 0
