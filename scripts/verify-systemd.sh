#!/usr/bin/env bash
# Title: verify-systemd.sh
# Description: Read-only verification of LinuxIA systemd units and timers
# Version: 1.0.0
# Usage: /opt/linuxia/scripts/verify-systemd.sh
# Notes: Read-only, idempotent. No system modifications.

set -euo pipefail
IFS=$'\n\t'

declare SCRIPT_NAME
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
declare -r SCRIPT_NAME

declare TIMESTAMP_UTC
TIMESTAMP_UTC="$(date -u +%Y%m%dT%H%M%SZ)"
declare -r TIMESTAMP_UTC

declare TIMESTAMP_LOCAL
TIMESTAMP_LOCAL="$(date -Is)"
declare -r TIMESTAMP_LOCAL

declare -i EXIT_CODE=0
declare -i OK_COUNT=0
declare -i WARN_COUNT=0
declare -i FAIL_COUNT=0

declare -a CHECKS=()

status_ok() {
    OK_COUNT=$((OK_COUNT + 1))
}

status_warn() {
    local msg="$1"
    WARN_COUNT=$((WARN_COUNT + 1))
    CHECKS+=("WARN: ${msg}")
}

status_fail() {
    local msg="$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    CHECKS+=("FAIL: ${msg}")
    EXIT_CODE=1
}

print_header() {
    local hostname_value
    hostname_value="$(hostname)"
    cat <<EOF
=== ${SCRIPT_NAME} — LinuxIA systemd verification ===
Host      : ${hostname_value}
UTC       : ${TIMESTAMP_UTC}
Local     : ${TIMESTAMP_LOCAL}
EOF
}

print_summary() {
    cat <<EOF

--- Summary ---
OK  : ${OK_COUNT}
WARN: ${WARN_COUNT}
FAIL: ${FAIL_COUNT}
EOF
    local c
    for c in "${CHECKS[@]:-}"; do
        [[ -n "${c}" ]] && printf "  %s\n" "${c}"
    done
}

# --- Checks ---

check_systemctl_available() {
    if ! command -v systemctl >/dev/null 2>&1; then
        status_warn "systemctl not available (non-systemd host or container)"
        return 0
    fi
    status_ok
}

check_required_timers() {
    local timers=(
        "linuxia-configsnap.timer"
        "linuxia-healthcheck.timer"
        "linuxia-health-report.timer"
    )
    local t
    for t in "${timers[@]}"; do
        if systemctl is-enabled "${t}" >/dev/null 2>&1; then
            status_ok
        else
            status_warn "Timer not enabled: ${t}"
        fi
    done
}

check_failed_units() {
    local failed
    failed="$(systemctl list-units --state=failed --no-legend --no-pager 2>/dev/null | wc -l || true)"
    if [[ "${failed}" -eq 0 ]]; then
        status_ok
    else
        status_fail "Failed systemd units: ${failed}"
    fi
}

check_linuxia_services() {
    local units
    mapfile -t units < <(systemctl list-units 'linuxia-*' --no-legend --no-pager 2>/dev/null | awk '{print $1}' || true)
    if [[ "${#units[@]}" -eq 0 ]]; then
        status_warn "No linuxia-* units found"
        return 0
    fi
    local u
    for u in "${units[@]}"; do
        [[ -z "${u}" ]] && continue
        local state
        state="$(systemctl is-active "${u}" 2>/dev/null || true)"
        case "${state}" in
            active|inactive) status_ok ;;
            failed)          status_fail "Unit in failed state: ${u}" ;;
            *)               status_warn "Unit state '${state}': ${u}" ;;
        esac
    done
}

# --- Main ---

main() {
    print_header

    if ! command -v systemctl >/dev/null 2>&1; then
        status_warn "systemctl not available — skipping all systemd checks"
        print_summary
        exit 0
    fi

    check_required_timers
    check_failed_units
    check_linuxia_services

    print_summary
    exit "${EXIT_CODE}"
}

main "$@"
