#!/usr/bin/env bash
set -euo pipefail

# LinuxIA — linuxia-clear-cache.sh
# Clears application cache to free memory and disk space:
#   1. Linux page/dentry/inode cache (drop_caches, requires root)
#   2. Stale /tmp files older than 7 days
#   3. Old linuxia health-report log files beyond retention
#
# Usage:
#   bash scripts/linuxia-clear-cache.sh
#   DRY_RUN=1 bash scripts/linuxia-clear-cache.sh
#
# Environment variables:
#   DRY_RUN=1            Show actions without executing (default: 0)
#   TMP_AGE_DAYS=N       Age threshold for /tmp cleanup (default: 7)
#   KEEP_HEALTH_REPORTS=N  Number of health reports to keep (default: 30)
#   LOGS_DIR             Path to linuxia logs (default: /opt/linuxia/logs)

DRY_RUN="${DRY_RUN:-0}"
TMP_AGE_DAYS="${TMP_AGE_DAYS:-7}"
KEEP_HEALTH_REPORTS="${KEEP_HEALTH_REPORTS:-30}"
LOGS_DIR="${LOGS_DIR:-/opt/linuxia/logs}"

say()  { printf "[linuxia-clear-cache] %s\n" "$*"; }

say "Start — $(date -Is)"
say "DRY_RUN=${DRY_RUN}"

# ── 1. Page cache / dentries / inodes ───────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
  say "Dropping page cache (sync + drop_caches=3)..."
  if [ "$DRY_RUN" = "1" ]; then
    printf "[DRY-RUN] sync\n"
    printf "[DRY-RUN] echo 3 > /proc/sys/vm/drop_caches\n"
  else
    sync
    echo 3 > /proc/sys/vm/drop_caches
  fi
  say "Page cache cleared."
else
  say "SKIP: drop_caches requires root (current uid=$(id -u))."
fi

# ── 2. Stale /tmp files ──────────────────────────────────────────────────────
say "Cleaning /tmp files older than ${TMP_AGE_DAYS} days (linuxia-* pattern)..."
if [ "$DRY_RUN" = "1" ]; then
  find /tmp -maxdepth 1 -name 'linuxia-*' -mtime +"${TMP_AGE_DAYS}" -print 2>/dev/null || true
else
  find /tmp -maxdepth 1 -name 'linuxia-*' -mtime +"${TMP_AGE_DAYS}" -print -delete 2>/dev/null || true
fi
say "/tmp cleanup done."

# ── 3. Old health-report logs ────────────────────────────────────────────────
HEALTH_DIR="${LOGS_DIR}/health"
if [ -d "$HEALTH_DIR" ]; then
  say "Trimming health-report logs (keep last ${KEEP_HEALTH_REPORTS})..."
  stale="$(ls -1t "${HEALTH_DIR}"/health-*.txt 2>/dev/null | tail -n +"$((KEEP_HEALTH_REPORTS + 1))" || true)"
  if [ -n "$stale" ]; then
    if [ "$DRY_RUN" = "1" ]; then
      printf "[DRY-RUN] would remove:\n%s\n" "$stale"
    else
      printf "%s\n" "$stale" | xargs rm -f
    fi
    say "Health-report log trim done."
  else
    say "Health-report logs within retention limit — nothing to remove."
  fi
else
  say "SKIP: health log dir not found (${HEALTH_DIR})."
fi

say "Done — $(date -Is)"
