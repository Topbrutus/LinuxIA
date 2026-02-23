# LinuxIA - Verification Script

## Overview
`scripts/verify-systemd.sh` performs read-only verification of LinuxIA systemd services and infrastructure.

## Usage

```bash
./scripts/verify-systemd.sh
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0    | All checks passed (OK only) |
| 1    | Warnings detected (OK + WARN) |
| 2    | Failures detected (FAIL present) |

## Checks Performed

### Timer Units
- linuxia-configsnap.timer
- linuxia-session-manager.timer
- linuxia-quota-check.timer

Verifies each timer is **enabled** and **active**.

### Service Units
- linuxia-configsnap.service
- linuxia-session-manager.service
- linuxia-quota-check.service

Verifies each service unit is **loaded** in systemd.

### Operational Checks
- Recent timer triggers (24h window)
- Service failure states
- Directory structure (`/opt/linuxia/data/shareA/archives/configsnap`, `/opt/linuxia/logs`)
- Script executables permissions

## Output Format

```
[OK]   Timer linuxia-configsnap.timer is enabled and active
[WARN] linuxia-configsnap.timer has no triggers in last 24h
[FAIL] Service linuxia-quota-check.service not found
```

## Properties

- **Read-only**: No system modifications
- **Idempotent**: Can be run repeatedly safely
- **Non-destructive**: Only queries systemd and filesystem
- **Fast**: Completes in <2 seconds

## Integration

Safe to run from:
- Cron jobs
- CI/CD pipelines
- Manual verification
- Post-deployment checks
