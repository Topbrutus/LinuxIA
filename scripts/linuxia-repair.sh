#!/usr/bin/env bash
set -euo pipefail

HEALTHCHECK_SCRIPT="/opt/linuxia/scripts/linuxia-healthcheck.sh"
HEALTHCHECK_REPORT="/opt/linuxia/docs/STATE_HEALTHCHECK.md"

printf "[linuxia-repair] Running healthcheck...\n"
if "$HEALTHCHECK_SCRIPT"; then
  printf "[linuxia-repair] Healthcheck OK. No repair needed.\n"
  exit 0
fi

printf "[linuxia-repair] Healthcheck FAIL. Applying safe remedies...\n"

if ! mount -a; then
  printf "[linuxia-repair] mount -a failed. Continuing.\n"
fi

if ! systemctl is-enabled --quiet linuxia-configsnap.timer; then
  printf "[linuxia-repair] Enabling linuxia-configsnap.timer...\n"
  systemctl enable --now linuxia-configsnap.timer
fi

printf "[linuxia-repair] Relaunching linuxia-healthcheck.service...\n"
systemctl start linuxia-healthcheck.service

if [ -f "$HEALTHCHECK_REPORT" ] && grep -q '^Result: OK$' "$HEALTHCHECK_REPORT"; then
  printf "[linuxia-repair] Healthcheck OK after repair.\n"
  exit 0
fi

printf "[linuxia-repair] Healthcheck still FAIL after repair.\n"
exit 1
