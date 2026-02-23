#!/bin/bash
set -euo pipefail

EXIT_CODE=0
FAIL_COUNT=0
WARN_COUNT=0
OK_COUNT=0

check() {
    local status=$1
    local message=$2
    case $status in
        OK)
            printf "[OK]   %s\n" "$message"
            ((OK_COUNT++))
            ;;
        WARN)
            printf "[WARN] %s\n" "$message"
            ((WARN_COUNT++))
            [[ $EXIT_CODE -lt 1 ]] && EXIT_CODE=1
            ;;
        FAIL)
            printf "[FAIL] %s\n" "$message"
            ((FAIL_COUNT++))
            EXIT_CODE=2
            ;;
    esac
}

printf "=== LinuxIA SystemD Services Verification ===\n\n"

# Timer units
for timer in linuxia-configsnap.timer linuxia-session-manager.timer linuxia-quota-check.timer; do
    if systemctl is-enabled "$timer" &>/dev/null; then
        if systemctl is-active "$timer" &>/dev/null; then
            check OK "Timer $timer is enabled and active"
        else
            check FAIL "Timer $timer is enabled but not active"
        fi
    else
        check FAIL "Timer $timer is not enabled"
    fi
done

# Service units (should be loaded, may be inactive)
for service in linuxia-configsnap.service linuxia-session-manager.service linuxia-quota-check.service; do
    if systemctl list-unit-files "$service" 2>/dev/null | grep -q "$service"; then
        check OK "Service $service is loaded"
    else
        check FAIL "Service $service not found"
    fi
done

# Check for recent timer activations
if journalctl --no-pager -u linuxia-configsnap.timer --since "24 hours ago" 2>/dev/null | grep -q "Triggered"; then
    check OK "linuxia-configsnap.timer has recent triggers"
else
    check WARN "linuxia-configsnap.timer has no triggers in last 24h"
fi

# Check service failures
for service in linuxia-configsnap.service linuxia-session-manager.service linuxia-quota-check.service; do
    if systemctl --state=failed --no-pager -l | grep -q "$service"; then
        check FAIL "Service $service is in failed state"
    fi
done

# Check directory structure
if [[ -d /opt/linuxia/data/shareA/archives/configsnap ]]; then
    check OK "Config snapshot directory exists"
else
    check FAIL "Config snapshot directory missing"
fi

if [[ -d /opt/linuxia/logs ]]; then
    check OK "Logs directory exists"
else
    check WARN "Logs directory missing"
fi

# Check script executables
for script in /opt/linuxia/scripts/configsnap.sh /opt/linuxia/scripts/session-manager.sh /opt/linuxia/scripts/quota-check.sh; do
    if [[ -x "$script" ]]; then
        check OK "Script $script is executable"
    else
        check FAIL "Script $script not found or not executable"
    fi
done

printf "\n=== Summary ===\n"
printf "OK: %d | WARN: %d | FAIL: %d\n" "$OK_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

exit $EXIT_CODE
