#!/bin/bash
set -euo pipefail

EXIT_CODE=0
FAIL_COUNT=0
WARN_COUNT=0
OK_COUNT=0

DISK_WARN_THRESHOLD=80
DISK_FAIL_THRESHOLD=90

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

printf "=== LinuxIA Platform Verification ===\n\n"

# Disk space checks
for path in /opt/linuxia /mnt/linuxia/DATA_1TB_A /mnt/linuxia/DATA_1TB_B; do
    if [[ -d "$path" ]]; then
        if df "$path" &>/dev/null; then
            usage=$(df "$path" | awk 'NR==2 {print $5}' | sed 's/%//')
            if [[ $usage -ge $DISK_FAIL_THRESHOLD ]]; then
                check FAIL "Disk space $path at ${usage}% (>= ${DISK_FAIL_THRESHOLD}%)"
            elif [[ $usage -ge $DISK_WARN_THRESHOLD ]]; then
                check WARN "Disk space $path at ${usage}% (>= ${DISK_WARN_THRESHOLD}%)"
            else
                check OK "Disk space $path at ${usage}%"
            fi
        else
            check FAIL "Cannot determine disk usage for $path"
        fi
    else
        check FAIL "Path $path does not exist"
    fi
done

# Mount point accessibility checks
for mount in /mnt/linuxia/DATA_1TB_A /mnt/linuxia/DATA_1TB_B; do
    if mountpoint -q "$mount" 2>/dev/null; then
        check OK "Mount point $mount is mounted"
    elif [[ -d "$mount" ]]; then
        check WARN "Path $mount exists but is not a mount point"
    else
        check FAIL "Mount point $mount does not exist"
    fi
done

# Critical directory structure
for dir in /opt/linuxia/data/shareA /opt/linuxia/data/shareB /opt/linuxia/logs /opt/linuxia/scripts; do
    if [[ -d "$dir" ]]; then
        if [[ -r "$dir" && -w "$dir" ]]; then
            check OK "Directory $dir exists and is accessible"
        else
            check WARN "Directory $dir exists but has restricted permissions"
        fi
    else
        check FAIL "Directory $dir does not exist"
    fi
done

# Critical services
for service in sshd; do
    if systemctl is-active "$service" &>/dev/null; then
        check OK "Service $service is active"
    else
        check FAIL "Service $service is not active"
    fi
done

# LinuxIA systemd timer health (basic check)
timer_count=$(systemctl list-timers 'linuxia-*' --no-legend 2>/dev/null | wc -l)
if [[ $timer_count -gt 0 ]]; then
    check OK "LinuxIA timers registered ($timer_count found)"
else
    check WARN "No LinuxIA timers found (expected: linuxia-configsnap.timer, etc.)"
fi

# Check for recent systemd failures
if systemctl --failed --no-legend --no-pager 2>/dev/null | grep -q 'linuxia-'; then
    failed_units=$(systemctl --failed --no-legend --no-pager | grep 'linuxia-' | awk '{print $1}')
    for unit in $failed_units; do
        check FAIL "SystemD unit $unit is in failed state"
    done
else
    check OK "No failed LinuxIA systemd units"
fi

# Archive directory health
configsnap_dir="/opt/linuxia/data/shareA/archives/configsnap"
if [[ -d "$configsnap_dir" ]]; then
    snapshot_count=$(find "$configsnap_dir" -type f -name "*.tar.zst" 2>/dev/null | wc -l)
    if [[ $snapshot_count -gt 0 ]]; then
        check OK "Config snapshots exist ($snapshot_count archives found)"
    else
        check WARN "Config snapshot directory exists but no archives found"
    fi
else
    check FAIL "Config snapshot directory $configsnap_dir does not exist"
fi

# SELinux status check
if command -v getenforce &>/dev/null; then
    selinux_mode=$(getenforce 2>/dev/null || echo "Unknown")
    if [[ "$selinux_mode" == "Enforcing" ]]; then
        check OK "SELinux is in Enforcing mode"
    elif [[ "$selinux_mode" == "Permissive" ]]; then
        check WARN "SELinux is in Permissive mode (should be Enforcing)"
    else
        check WARN "SELinux status: $selinux_mode"
    fi
else
    check WARN "SELinux tools not available"
fi

printf "\n=== Summary ===\n"
printf "OK: %d | WARN: %d | FAIL: %d\n" "$OK_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

exit $EXIT_CODE
