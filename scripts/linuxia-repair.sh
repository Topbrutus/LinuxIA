#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
TAG="linuxia-repair"

if ! [[ -t 1 ]] && command -v systemd-cat >/dev/null 2>&1; then
  exec > >(systemd-cat -t "$TAG") 2>&1
fi

log() { printf '[%s] %s\n' "$(date -Is)" "$*"; }

# Objectif: remettre les montages critiques et, si dispo, relancer la routine Samba/NTFS
log "START repair routine"

# Tentative simple: remonter tout ce qui est dans fstab
timeout 60s mount -a || true

# Si le remount Samba/NTFS existe, l'utiliser (plus robuste)
if [ -x /usr/local/sbin/linuxia-samba-remount.sh ]; then
  timeout 180s /usr/local/sbin/linuxia-samba-remount.sh || true
fi

# Revalider via healthcheck mais exécuté en gaby (ownership propre)
if [ "$(id -u)" -eq 0 ]; then
  su - gaby -c /opt/linuxia/scripts/linuxia-healthcheck.sh
else
  /opt/linuxia/scripts/linuxia-healthcheck.sh
fi

log "END repair routine"
exit 0
