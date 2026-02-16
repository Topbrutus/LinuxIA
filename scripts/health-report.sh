#!/usr/bin/env bash
set -euo pipefail

# LinuxIA — health-report.sh
# READ-ONLY diagnostics, writes only a report file.
# Usage:
#   bash scripts/health-report.sh
#   OUT_DIR=/tmp bash scripts/health-report.sh

OUT_DIR="${OUT_DIR:-/opt/linuxia/logs/health}"
SHAREA_DIR="${SHAREA_DIR:-/opt/linuxia/data/shareA/reports/health}"

ts="$(date +%Y%m%d-%H%M%S)"
host="$(hostname -s || echo unknown)"
report="${OUT_DIR}/health-${host}-${ts}.txt"

mkdir -p "$OUT_DIR" || true
mkdir -p "$SHAREA_DIR" 2>/dev/null || true

w() { printf "%s\n" "$*" >>"$report"; }
run() {
  local title="$1"; shift
  w ""
  w "============================================================"
  w "$title"
  w "------------------------------------------------------------"
  # shellcheck disable=SC2129
  { "$@" 2>&1 || true; } >>"$report"
}

w "=== LinuxIA Health Report (READ-ONLY) ==="
w "Host:   ${host}"
w "Date:   $(date -Is)"
w "Kernel: $(uname -a 2>/dev/null || true)"

run "Uptime" uptime
run "Disk usage (df -h)" df -h
run "Mounts (first 120 lines)" bash -lc 'mount | sed -n "1,120p"'
run "Failed systemd units" systemctl list-units --state=failed --no-legend
run "LinuxIA timers (all)" bash -lc 'systemctl list-timers --all | grep -E "linuxia-|NEXT|LEFT|LAST|PASSED|UNIT|ACTIVATES" || true'
run "LinuxIA logs last 200 lines" journalctl -u 'linuxia-*' -n 200 --no-pager

# Configsnap quick proof (count + newest 3)
cfgdir="/opt/linuxia/data/shareA/archives/configsnap"
if [[ -d "$cfgdir" ]]; then
  run "Configsnap archives (count + newest 3)" bash -lc "ls -1t \"$cfgdir\"/*.tar.zst 2>/dev/null | sed -n '1,3p' ; echo ; ls -1 \"$cfgdir\"/*.tar.zst 2>/dev/null | wc -l"
else
  run "Configsnap archives" bash -lc "echo 'WARN: missing dir: $cfgdir'"
fi

# Optional listeners
if command -v ss >/dev/null 2>&1; then
  run "Network listeners (ss -lntup first 80)" bash -lc 'ss -lntup | sed -n "1,80p"'
else
  run "Network listeners" bash -lc "echo 'WARN: ss not available'"
fi

# Copy report to shareA if possible
if [[ -d "$SHAREA_DIR" ]]; then
  cp -f "$report" "$SHAREA_DIR/" 2>/dev/null || true
fi

echo "OK: report written -> $report"
[[ -d "$SHAREA_DIR" ]] && echo "OK: copy attempt -> $SHAREA_DIR"
