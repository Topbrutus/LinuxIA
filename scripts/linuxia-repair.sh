#!/usr/bin/env bash
set -euo pipefail

# Ensure a predictable PATH when run from systemd
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

HEALTHCHECK_SCRIPT="/opt/linuxia/scripts/linuxia-healthcheck.sh"
HEALTHCHECK_REPORT="/opt/linuxia/docs/STATE_HEALTHCHECK.md"

# Timestamp helper for structured logging
_timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

printf "[linuxia-repair] %s Running healthcheck...\n" "$(_timestamp)"
if "$HEALTHCHECK_SCRIPT"; then
  printf "[linuxia-repair] %s Healthcheck OK. No repair needed.\n" "$(_timestamp)"
  exit 0
fi

printf "[linuxia-repair] %s Healthcheck FAIL. Applying safe remedies...\n" "$(_timestamp)"

# Re-mount only shares that are listed in fstab but currently not mounted,
# instead of running 'mount -a' which can attempt to mount unrelated entries.
declare -a LINUXIA_MOUNTS=(
  "/opt/linuxia/data/shareA"
  "/opt/linuxia/data/shareB"
)
for _mnt in "${LINUXIA_MOUNTS[@]}"; do
  if ! findmnt --mountpoint "$_mnt" --noheadings >/dev/null 2>&1; then
    printf "[linuxia-repair] %s Mounting %s...\n" "$(_timestamp)" "$_mnt"
    mount "$_mnt" 2>/dev/null || printf "[linuxia-repair] %s mount %s failed. Continuing.\n" "$(_timestamp)" "$_mnt"
  fi
done

if ! systemctl is-enabled --quiet linuxia-configsnap.timer; then
  printf "[linuxia-repair] %s Enabling linuxia-configsnap.timer...\n" "$(_timestamp)"
  systemctl enable --now linuxia-configsnap.timer
fi

printf "[linuxia-repair] %s Relaunching linuxia-healthcheck.service...\n" "$(_timestamp)"
systemctl start linuxia-healthcheck.service

if [ -f "$HEALTHCHECK_REPORT" ] && grep -q '^Result: OK$' "$HEALTHCHECK_REPORT"; then
  printf "[linuxia-repair] %s Healthcheck OK after repair.\n" "$(_timestamp)"
  exit 0
fi

printf "[linuxia-repair] %s Healthcheck still FAIL after repair.\n" "$(_timestamp)"
exit 1
