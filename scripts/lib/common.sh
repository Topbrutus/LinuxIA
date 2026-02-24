#!/usr/bin/env bash
# LinuxIA — scripts/lib/common.sh
# Shared utility functions sourced by scripts in scripts/.
# Source with:
#   # shellcheck source=scripts/lib/common.sh
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
#
# Requires: ScriptName to be set by the caller before invoking acquire_lock.

# Guard against double-sourcing.
[[ -n "${_LINUXIA_COMMON_SH:-}" ]] && return 0;
_LINUXIA_COMMON_SH=1;

# ── Timestamps ────────────────────────────────────────────────────────────────
# Sets TimeStampUtc and TimeStampLocal as global variables in the caller's scope.
# Callers should declare these variables before calling, e.g.:
#   declare TimeStampUtc TimeStampLocal
#   init_timestamps
#   declare -r TimeStampUtc TimeStampLocal
init_timestamps() {
  TimeStampUtc="$(date -u +%Y%m%dT%H%M%SZ)";
  TimeStampLocal="$(date -Is)";
}

# ── Lock management ───────────────────────────────────────────────────────────
# cleanup: removes LockDir and LockDirFallback created by acquire_lock.
cleanup() {
  if [[ -d "${LockDir:-}" ]];
  then
    rmdir "${LockDir}" 2>/dev/null || true;
  fi;

  if [[ -d "${LockDirFallback:-}" ]];
  then
    rmdir "${LockDirFallback}" 2>/dev/null || true;
  fi;
}

# acquire_lock: creates an exclusive lock based on ScriptName.
# Requires: ScriptName to be set in the caller's scope before calling.
# Sets LockDir and LockDirFallback as globals and registers cleanup on exit.
acquire_lock() {
  if [[ -z "${ScriptName:-}" ]];
  then
    printf '%s\n' "ERROR: acquire_lock requires ScriptName to be set.";
    exit 1;
  fi;
  LockDir="/run/lock/${ScriptName}.lock.d";
  LockDirFallback="/tmp/${ScriptName}.lock.d";

  if mkdir "${LockDir}" 2>/dev/null;
  then
    trap cleanup EXIT INT TERM;
    return 0;
  fi;

  if mkdir "${LockDirFallback}" 2>/dev/null;
  then
    trap cleanup EXIT INT TERM;
    return 0;
  fi;

  printf '%s\n' "ERROR: Lock exists (${LockDir} or ${LockDirFallback}). Another run may be in progress.";
  exit 1;
}

# ── Utilities ─────────────────────────────────────────────────────────────────
# have_cmd: returns 0 if the given command is available, 1 otherwise.
have_cmd() {
  declare Cmd="${1}";
  if command -v "${Cmd}" >/dev/null 2>&1;
  then
    return 0;
  fi;
  return 1;
}

# detect_host: sets HostShort and HostFqdn in the caller's scope.
detect_host() {
  HostShort="$(hostname -s 2>/dev/null || hostname)";
  HostFqdn="$(hostname -f 2>/dev/null || true)";
}

# section: prints a formatted section header.
section() {
  declare Title="${1}";
  printf '\n%s\n' "=== ${Title} ===";
}
