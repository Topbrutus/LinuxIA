#!/usr/bin/env bash
set -euo pipefail

# LinuxIA — health-retention.sh
# Remove old health reports, keep last N (default 30)

DIR="/opt/linuxia/logs/health"
KEEP="${KEEP_HEALTH_REPORTS:-30}"

[ -d "$DIR" ] || exit 0

# Remove files beyond retention count
ls -1t "$DIR"/health-*.txt 2>/dev/null | tail -n +"$((KEEP+1))" | xargs -r rm -f
