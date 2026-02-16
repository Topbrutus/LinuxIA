#!/usr/bin/env bash
set -euo pipefail

# LinuxIA — verify-platform.sh (READ-ONLY)
# Goals:
# - Be strict on critical LinuxIA operational guarantees (timers, failed units, core paths)
# - Be tolerant on optional components (missing mounts/tools => WARN, not FAIL)
# - Provide stable, parseable output + meaningful exit codes
#
# Exit codes:
#   0 = OK
#   1 = WARN (no FAIL)
#   2 = FAIL

# ----------------------------
# Tunables (override via env)
# ----------------------------
DISK_WARN_THRESHOLD="${DISK_WARN_THRESHOLD:-80}"
DISK_FAIL_THRESHOLD="${DISK_FAIL_THRESHOLD:-90}"

# Critical LinuxIA timers expected on VM100
REQUIRED_TIMERS=(
  "linuxia-configsnap.timer"
  "linuxia-healthcheck.timer"
)

# Critical paths (FAIL if missing)
CRITICAL_PATHS=(
  "/opt/linuxia"
  "/opt/linuxia/scripts"
  "/opt/linuxia/data"
  "/opt/linuxia/data/shareA/archives/configsnap"
)

# Optional mounts/paths (WARN if missing or not mounted)
OPTIONAL_PATHS=(
  "/srv/artifacts-hot"
  "/mnt/linuxia/DATA_1TB_A"
  "/mnt/linuxia/DATA_1TB_B"
)

# Configsnap archive pattern (WARN if none found, FAIL if dir missing already handled in CRITICAL_PATHS)
CONFIGSNAP_GLOB="linuxia-configsnap_*.tar.zst"

# ----------------------------
# Helpers
# ----------------------------
OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
EXIT_CODE=0

ok()   { printf "[OK]   %s\n" "$*"; OK_COUNT=$((OK_COUNT+1)); }
warn() { printf "[WARN] %s\n" "$*"; WARN_COUNT=$((WARN_COUNT+1)); [[ $EXIT_CODE -lt 1 ]] && EXIT_CODE=1; }
fail() { printf "[FAIL] %s\n" "$*"; FAIL_COUNT=$((FAIL_COUNT+1)); EXIT_CODE=2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || warn "Missing command: $1 (some checks will be skipped)"
}

hr() { printf "%s\n" "------------------------------------------------------------"; }

is_mounted() {
  local p="$1"
  mountpoint -q "$p" 2>/dev/null
}

disk_usage_pct() {
  # returns integer percent for the filesystem containing $1, or empty if not available
  local path="$1"
  df -P "$path" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $5}'
}

check_disk_path() {
  local path="$1"
  local critical="$2"  # "yes" or "no"

  if [[ ! -e "$path" ]]; then
    if [[ "$critical" == "yes" ]]; then
      fail "Path missing: $path"
    else
      warn "Optional path missing: $path"
    fi
    return 0
  fi

  local usage
  usage="$(disk_usage_pct "$path" || true)"
  if [[ -z "${usage:-}" ]]; then
    warn "Disk usage unavailable for: $path"
    return 0
  fi

  if [[ "$usage" -ge "$DISK_FAIL_THRESHOLD" ]]; then
    fail "Disk usage $path at ${usage}% (>= ${DISK_FAIL_THRESHOLD}%)"
  elif [[ "$usage" -ge "$DISK_WARN_THRESHOLD" ]]; then
    warn "Disk usage $path at ${usage}% (>= ${DISK_WARN_THRESHOLD}%)"
  else
    ok "Disk usage $path at ${usage}%"
  fi
}

check_failed_units() {
  if ! command -v systemctl >/dev/null 2>&1; then
    warn "systemctl not available; cannot check failed units"
    return 0
  fi

  local failed
  failed="$(systemctl list-units --state=failed --no-legend 2>/dev/null | awk '{print $1}' || true)"
  if [[ -z "${failed:-}" ]]; then
    ok "No failed systemd units"
  else
    fail "Failed systemd units detected:"
    printf "%s\n" "$failed" | sed 's/^/  - /'
  fi
}

check_timer() {
  local t="$1"

  if ! command -v systemctl >/dev/null 2>&1; then
    warn "systemctl not available; cannot verify timer $t"
    return 0
  fi

  # Unit file exists?
  if ! systemctl list-unit-files "$t" --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "$t"; then
    fail "Missing timer unit file: $t"
    return 0
  fi

  # Enabled?
  if systemctl is-enabled "$t" >/dev/null 2>&1; then
    ok "Timer enabled: $t"
  else
    fail "Timer NOT enabled: $t"
  fi

  # Active?
  if systemctl is-active "$t" >/dev/null 2>&1; then
    ok "Timer active: $t"
  else
    fail "Timer NOT active: $t"
  fi
}

check_linuxia_timers() {
  hr
  echo "LinuxIA timers"
  for t in "${REQUIRED_TIMERS[@]}"; do
    check_timer "$t"
  done
}

check_configsnap_archives() {
  hr
  echo "Configsnap archives"
  local dir="/opt/linuxia/data/shareA/archives/configsnap"

  if [[ ! -d "$dir" ]]; then
    # This should already be FAIL via CRITICAL_PATHS, but keep it explicit
    fail "Configsnap archive directory missing: $dir"
    return 0
  fi

  shopt -s nullglob
  local files=( "$dir"/$CONFIGSNAP_GLOB )
  shopt -u nullglob

  if ((${#files[@]} == 0)); then
    warn "Configsnap directory exists but no archives found matching: $CONFIGSNAP_GLOB"
    return 0
  fi

  # Show last 3 newest (by mtime)
  ok "Configsnap archives found: ${#files[@]}"
  ls -1t "${files[@]}" 2>/dev/null | head -n 3 | sed 's/^/  - /' || true
}

check_mount_optional() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    warn "Optional mount path missing: $path"
    return 0
  fi
  if command -v mountpoint >/dev/null 2>&1; then
    if is_mounted "$path"; then
      ok "Mounted: $path"
    else
      warn "Not mounted (optional): $path"
    fi
  else
    warn "mountpoint not available; cannot confirm mount state for: $path"
  fi
}

check_network_listeners() {
  hr
  echo "Network listeners (optional)"
  if command -v ss >/dev/null 2>&1; then
    ok "ss -lntup (first 60 lines)"
    ss -lntup 2>/dev/null | head -n 60 || true
  else
    warn "ss not available; skipping listener check"
  fi
}

# ----------------------------
# Main
# ----------------------------
main() {
  echo "=== LinuxIA verify-platform (READ-ONLY) ==="
  echo "Host:   $(hostname)"
  echo "Date:   $(date -Is)"
  echo "Kernel: $(uname -a)"
  echo

  # Optional tool presence warnings
  need_cmd df
  need_cmd mount
  need_cmd mountpoint
  need_cmd systemctl
  need_cmd ss
  need_cmd journalctl

  hr
  echo "Critical paths"
  for p in "${CRITICAL_PATHS[@]}"; do
    if [[ -e "$p" ]]; then
      ok "Path exists: $p"
    else
      fail "Path missing: $p"
    fi
  done

  hr
  echo "Disk usage checks"
  # Always check root
  check_disk_path "/" "yes"
  # Check /opt/linuxia specifically
  check_disk_path "/opt/linuxia" "yes"
  # Check optional storage paths too
  for p in "${OPTIONAL_PATHS[@]}"; do
    check_disk_path "$p" "no"
  done

  hr
  echo "Failed units"
  check_failed_units

  check_linuxia_timers
  check_configsnap_archives

  hr
  echo "Optional mounts"
  for p in "${OPTIONAL_PATHS[@]}"; do
    check_mount_optional "$p"
  done

  check_network_listeners

  hr
  echo "=== Summary ==="
  printf "OK=%d WARN=%d FAIL=%d\n" "$OK_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
  exit "$EXIT_CODE"
}

main "$@"
