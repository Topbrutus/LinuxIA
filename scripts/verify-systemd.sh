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
================================================================================
LinuxIA Systemd Verification Report
================================================================================
Script: ${SCRIPT_NAME}
Timestamp (UTC): ${TIMESTAMP_UTC}
Timestamp (Local): ${TIMESTAMP_LOCAL}
Host: ${hostname_value}
================================================================================

EOF
}

print_section() {
    local title="$1"
    cat <<EOF

--- ${title} ---
EOF
}

check_systemctl_available() {
    if ! command -v systemctl >/dev/null 2>&1; then
        status_fail "systemctl command not found (systemd not available)"
        return 1
    fi
    return 0
}

find_linuxia_units() {
    local unit_type="$1"
    systemctl list-unit-files --type="${unit_type}" --no-pager --no-legend --all 2>/dev/null | \
        awk '{print $1}' | \
        grep '^linuxia-' || true
}

check_unit_state() {
    local unit="$1"
    local critical="${2:-no}"
    
    if ! systemctl list-unit-files "${unit}" --no-pager --no-legend >/dev/null 2>&1; then
        if [ "${critical}" = "yes" ]; then
            status_fail "Unit ${unit} not found (critical)"
        else
            status_warn "Unit ${unit} not found (optional)"
        fi
        return 1
    fi
    
    local is_enabled
    is_enabled=$(systemctl is-enabled "${unit}" 2>/dev/null || echo "disabled")
    
    local load_state
    load_state=$(systemctl show "${unit}" -p LoadState --value 2>/dev/null || echo "unknown")
    
    if [ "${load_state}" = "loaded" ]; then
        printf "  %-40s [%s] %s\n" "${unit}" "${load_state}" "${is_enabled}"
        status_ok
    elif [ "${load_state}" = "not-found" ]; then
        if [ "${critical}" = "yes" ]; then
            printf "  %-40s [%s] CRITICAL\n" "${unit}" "${load_state}"
            status_fail "Unit ${unit} is critical but not found"
        else
            printf "  %-40s [%s] OPTIONAL\n" "${unit}" "${load_state}"
            status_warn "Unit ${unit} not found (optional)"
        fi
        return 1
    else
        printf "  %-40s [%s] %s\n" "${unit}" "${load_state}" "${is_enabled}"
        if [ "${critical}" = "yes" ]; then
            status_fail "Unit ${unit} has unexpected load state: ${load_state}"
        else
            status_warn "Unit ${unit} has unexpected load state: ${load_state}"
        fi
        return 1
    fi
    return 0
}

check_service_umask() {
    local service="$1"
    local expected_umask="$2"
    
    if ! systemctl list-unit-files "${service}" --no-pager --no-legend >/dev/null 2>&1; then
        return 0
    fi
    
    local actual_umask
    actual_umask=$(systemctl show "${service}" -p UMask --value 2>/dev/null || echo "")
    
    if [ -z "${actual_umask}" ]; then
        status_warn "UMask not set on ${service}"
        printf "  UMask: <not set> (expected: %s)\n" "${expected_umask}"
        return 1
    fi
    
    if [ "${actual_umask}" = "${expected_umask}" ]; then
        printf "  UMask: %s ✓\n" "${actual_umask}"
        status_ok
    else
        printf "  UMask: %s (expected: %s) ✗\n" "${actual_umask}" "${expected_umask}"
        status_fail "UMask mismatch on ${service}: got ${actual_umask}, expected ${expected_umask}"
    fi
}

show_timers() {
    print_section "Timer Status"
    
    local timers
    timers=$(find_linuxia_units timer)
    
    if [ -z "${timers}" ]; then
        printf "  No linuxia-* timers found\n"
        status_warn "No linuxia-* timers found"
        return
    fi
    
    printf "\n"
    local timer_output
    timer_output=$(systemctl list-timers --all --no-pager 2>/dev/null | grep 'linuxia-' || true)
    if [ -n "${timer_output}" ]; then
        systemctl list-timers --all --no-pager 2>/dev/null | head -n 1
        printf "%s\n" "${timer_output}"
    else
        printf "  No active linuxia-* timers\n"
    fi
    printf "\n"
    
    while IFS= read -r timer; do
        if [ -n "${timer}" ]; then
            local active_state
            active_state=$(systemctl is-active "${timer}" 2>/dev/null || echo "inactive")
            
            if [ "${active_state}" = "active" ]; then
                status_ok
            else
                status_warn "Timer ${timer} is not active (state: ${active_state})"
            fi
        fi
    done <<< "${timers}"
}

show_unit_logs() {
    local unit="$1"
    local lines="${2:-10}"
    
    if ! systemctl list-unit-files "${unit}" --no-pager --no-legend >/dev/null 2>&1; then
        return 0
    fi
    
    printf "\n  Last %d log lines for %s:\n" "${lines}" "${unit}"
    
    if journalctl -u "${unit}" -n "${lines}" --no-pager --output=short-iso 2>/dev/null | grep -q .; then
        journalctl -u "${unit}" -n "${lines}" --no-pager --output=short-iso 2>/dev/null | sed 's/^/    /'
    else
        printf "    (no logs available)\n"
    fi
}

verify_services() {
    print_section "Service Units"
    
    local services
    services=$(find_linuxia_units service)
    
    if [ -z "${services}" ]; then
        printf "  No linuxia-* services found\n"
        status_warn "No linuxia-* services found"
        return
    fi
    
    printf "\n"
    while IFS= read -r service; do
        if [ -n "${service}" ]; then
            check_unit_state "${service}" "no"
        fi
    done <<< "${services}"
    
    print_section "Service Configuration Checks"
    
    printf "\nlinuxia-configsnap.service:\n"
    check_service_umask "linuxia-configsnap.service" "0002"
}

verify_timers() {
    print_section "Timer Units"
    
    local timers
    timers=$(find_linuxia_units timer)
    
    if [ -z "${timers}" ]; then
        printf "  No linuxia-* timers found\n"
        status_warn "No linuxia-* timers found"
        return
    fi
    
    printf "\n"
    while IFS= read -r timer; do
        if [ -n "${timer}" ]; then
            check_unit_state "${timer}" "no"
        fi
    done <<< "${timers}"
}

show_logs_summary() {
    print_section "Recent Logs Summary"
    
    local units
    units=$(find_linuxia_units service)
    
    if [ -z "${units}" ]; then
        printf "  No linuxia-* services found\n"
        return
    fi
    
    while IFS= read -r unit; do
        if [ -n "${unit}" ]; then
            show_unit_logs "${unit}" 5
        fi
    done <<< "${units}"
}

print_summary() {
    print_section "Summary"
    
    printf "\n"
    printf "  OK:   %d\n" "${OK_COUNT}"
    printf "  WARN: %d\n" "${WARN_COUNT}"
    printf "  FAIL: %d\n" "${FAIL_COUNT}"
    printf "\n"
    
    if [ ${FAIL_COUNT} -gt 0 ]; then
        printf "  Overall Status: FAIL ✗\n"
    elif [ ${WARN_COUNT} -gt 0 ]; then
        printf "  Overall Status: WARN ⚠\n"
    else
        printf "  Overall Status: OK ✓\n"
    fi
    
    if [ ${#CHECKS[@]} -gt 0 ]; then
        printf "\n  Issues:\n"
        for check in "${CHECKS[@]}"; do
            printf "    - %s\n" "${check}"
        done
    fi
    
    printf "\n"
    printf "================================================================================\n"
}

main() {
    print_header
    
    if ! check_systemctl_available; then
        print_summary
        exit "${EXIT_CODE}"
    fi
    
    verify_services
    verify_timers
    show_timers
    show_logs_summary
    print_summary
    
    exit "${EXIT_CODE}"
}

main "$@"
