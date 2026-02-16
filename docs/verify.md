# LinuxIA Systemd Verification Guide

## Overview

The `verify-systemd.sh` script provides read-only verification of LinuxIA systemd units and timers. It performs comprehensive checks without modifying the system state, making it safe to run at any time.

## Running the Verification Script

### Basic Usage

```bash
/opt/linuxia/scripts/verify-systemd.sh
```

Or from the repository root:

```bash
./scripts/verify-systemd.sh
```

### Requirements

- systemd-based Linux distribution
- Bash 4.0 or higher
- Standard coreutils (date, grep, awk, sed)
- `systemctl` and `journalctl` commands available

### Permissions

The script is designed to run without elevated privileges. However, some log entries may be restricted depending on systemd journal permissions. For complete log access, you may need to run with appropriate permissions or be in the `systemd-journal` group.

## Understanding the Output

### Status Indicators

The script uses three status levels:

- **OK** ✓: The check passed successfully
- **WARN** ⚠: A non-critical issue was detected (unit missing, timer inactive, etc.)
- **FAIL** ✗: A critical issue was detected (required unit missing, configuration mismatch, etc.)

### Exit Codes

- **0**: All checks passed (OK or WARN only)
- **Non-zero (1)**: One or more FAIL conditions detected

Use the exit code to integrate with CI/CD or monitoring systems:

```bash
/opt/linuxia/scripts/verify-systemd.sh
if [ $? -ne 0 ]; then
    # Handle failure case
    echo "Verification failed - see output for details"
fi
```

## What the Script Verifies

### 1. Service Units

- Detects all `linuxia-*` services
- Verifies load state (loaded/not-found)
- Shows enabled/disabled status
- Reports on unit configuration

Expected services:
- `linuxia-configsnap.service`
- `linuxia-healthcheck.service`
- `linuxia-repair.service`

### 2. Timer Units

- Detects all `linuxia-*` timers
- Shows next scheduled run time
- Displays last trigger time
- Verifies active/inactive state

Expected timers:
- `linuxia-configsnap.timer`
- `linuxia-healthcheck.timer`

### 3. Configuration Checks

The script performs specific configuration validations:

- **UMask on linuxia-configsnap.service**: Verifies `UMask=0002` is set (ensures group-writable file creation for shared access)

### 4. Log Summary

Displays recent log entries (last 5 lines) for each service unit to help identify issues or verify recent activity.

## Verification Checklist

Use this checklist when verifying LinuxIA systemd infrastructure:

- [ ] Run the verification script: `./scripts/verify-systemd.sh`
- [ ] Check exit code is 0 (no FAIL conditions)
- [ ] Verify all expected units are present and loaded
- [ ] Confirm timers are active and scheduled
- [ ] Review UMask configuration on linuxia-configsnap.service
- [ ] Examine log summaries for errors or warnings
- [ ] Document any WARN conditions for investigation
- [ ] If FAIL detected: investigate root cause before proceeding

## Validation Commands

Run these commands manually to validate systemd configuration:

### List all LinuxIA units and timers

```bash
systemctl list-unit-files 'linuxia-*' --no-pager
```

### Check timer schedules

```bash
systemctl list-timers 'linuxia-*' --all --no-pager
```

### Verify specific unit status

```bash
systemctl status linuxia-configsnap.service
systemctl status linuxia-configsnap.timer
systemctl status linuxia-healthcheck.service
systemctl status linuxia-healthcheck.timer
systemctl status linuxia-repair.service
```

### Check UMask configuration

```bash
systemctl show linuxia-configsnap.service -p UMask
```

### View recent logs

```bash
# Last 20 lines for configsnap service
journalctl -u linuxia-configsnap.service -n 20 --no-pager

# Last 20 lines for healthcheck service
journalctl -u linuxia-healthcheck.service -n 20 --no-pager

# Logs since yesterday
journalctl -u linuxia-configsnap.service --since yesterday --no-pager
```

### Check timer next run time

```bash
systemctl show linuxia-configsnap.timer -p NextElapseUSecRealtime
systemctl show linuxia-healthcheck.timer -p NextElapseUSecRealtime
```

### Verify unit files exist

```bash
systemctl cat linuxia-configsnap.service
systemctl cat linuxia-configsnap.timer
systemctl cat linuxia-healthcheck.service
systemctl cat linuxia-healthcheck.timer
systemctl cat linuxia-repair.service
```

## Interpreting Results

### Normal Operation

Expected output for a healthy system:

```
Overall Status: OK ✓
OK:   10
WARN: 0
FAIL: 0
```

### Warning Conditions (WARN)

Common warning scenarios:

- Optional units not installed
- Timer not active (might be intentionally disabled)
- UMask not explicitly set (uses system default)
- No recent logs (unit hasn't run yet)

**Action**: Warnings should be reviewed but don't necessarily require immediate action.

### Failure Conditions (FAIL)

Common failure scenarios:

- Critical unit missing (linuxia-configsnap.service not found)
- UMask mismatch (configured value differs from expected 0002)
- Unit in error state
- Configuration inconsistency

**Action**: Failures require investigation and remediation before production deployment.

## WARN vs FAIL Policy

The script implements the following policy for missing units:

- **WARN**: Unit is missing but considered optional (system can operate without it)
- **FAIL**: Configuration mismatch on existing units (UMask incorrect, etc.)

Currently, all linuxia-* units are treated as optional (produce WARN if missing). This allows the script to run on systems where some units are not yet deployed.

To make specific units critical (produce FAIL if missing), edit the script and change the second parameter in `check_unit_state` calls from "no" to "yes".

## Safety Guarantees

The verification script is designed with the following safety guarantees:

1. **Read-only**: Never modifies system state
2. **Idempotent**: Can be run multiple times with identical results
3. **No daemon-reload**: Doesn't reload systemd configuration
4. **No enable/disable**: Doesn't change unit enabled state
5. **No start/stop/restart**: Doesn't affect running services
6. **No file modifications**: Doesn't edit configuration files
7. **No privileged operations**: Doesn't use `sudo` or require root

## Troubleshooting

### Script fails with "systemctl command not found"

**Cause**: System doesn't have systemd installed.

**Solution**: This script requires systemd. Check if your system uses a different init system.

### "Permission denied" when reading logs

**Cause**: User doesn't have permission to read systemd journal.

**Solution**: Add user to `systemd-journal` group or run with appropriate privileges:

```bash
sudo usermod -a -G systemd-journal $(whoami)
# Re-login for group membership to take effect
```

### Timer shows "inactive" but unit is loaded

**Cause**: Timer exists but hasn't been enabled.

**Solution**: This is reported as WARN. To enable the timer (on the actual VM, not in verification):

```bash
# Example (DO NOT run from verification script):
sudo systemctl enable --now linuxia-configsnap.timer
```

## Integration Examples

### CI/CD Pipeline

```bash
#!/bin/bash
# Run verification as part of deployment pipeline
/opt/linuxia/scripts/verify-systemd.sh
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "✓ Systemd verification passed"
    exit 0
else
    echo "✗ Systemd verification failed"
    exit 1
fi
```

### Monitoring Integration

```bash
#!/bin/bash
# Periodic verification for monitoring
output=$(/opt/linuxia/scripts/verify-systemd.sh 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    # Send alert with output
    echo "ALERT: LinuxIA systemd verification failed"
    echo "$output"
fi
```

## Related Documentation

- [LinuxIA Production Documentation](PRODUCTION.md)
- [Service Definitions](../services/systemd/)
- [Health Check Scripts](../scripts/)
