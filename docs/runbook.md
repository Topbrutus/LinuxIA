# LinuxIA VM100 Factory - Operational Runbook

## Purpose
This runbook provides step-by-step procedures for installing, verifying, restoring, and troubleshooting LinuxIA services on VM100 (Factory).

---

## 📦 Storage Mounts (shareA / shareB)

### Overview
LinuxIA uses two bind mounts for shared storage:
- `/opt/linuxia/data/shareA` ← `/srv/linuxia-share/DATA_1TB_A/LinuxIA_SMB`
- `/opt/linuxia/data/shareB` ← `/srv/linuxia-share/DATA_1TB_B/LinuxIA_SMB`

These are managed via systemd mount units (auto-generated from `/etc/fstab`).

### Activate Mounts (One-Time Setup)
```bash
# On VM100, as root:
sudo -i

systemctl start opt-linuxia-data-shareA.mount
systemctl start opt-linuxia-data-shareB.mount

# Make persistent (survive reboots):
systemctl enable opt-linuxia-data-shareA.mount
systemctl enable opt-linuxia-data-shareB.mount
```

### Verify Mounts
```bash
# Check systemd status:
systemctl status opt-linuxia-data-shareA.mount
systemctl status opt-linuxia-data-shareB.mount

# Check actual mounts:
mount | grep -E "shareA|shareB"

# Expected output:
# /srv/linuxia-share/DATA_1TB_A/LinuxIA_SMB on /opt/linuxia/data/shareA type none (bind,nofail)
# /srv/linuxia-share/DATA_1TB_B/LinuxIA_SMB on /opt/linuxia/data/shareB type none (bind,nofail)
```

### Troubleshooting
**Symptom**: Mounts are inactive after boot
```bash
# Check if source directories exist:
ls -ld /srv/linuxia-share/DATA_1TB_A/LinuxIA_SMB
ls -ld /srv/linuxia-share/DATA_1TB_B/LinuxIA_SMB

# Check fstab entries:
grep shareA /etc/fstab

# Manually mount (if enabled):
systemctl start opt-linuxia-data-shareA.mount
```

**Symptom**: Permission denied when writing
See "Permissions & ACLs" section below (Phase 8 PR2).

---

## 🔧 Initial Installation

### Prerequisites
- VM100 provisioned (openSUSE, gaby user with sudo access)
- SSH access configured: `ssh gaby@192.168.1.135`
- Git repository path: `/opt/linuxia`

### Step 1: Clone Repository
```bash
# On VM100
cd /opt
sudo mkdir -p linuxia
sudo chown gaby:users linuxia
git clone git@github.com:Topbrutus/LinuxIA.git linuxia
cd linuxia
```

### Step 2: Verify Directory Structure
```bash
ls -la /opt/linuxia
# Expected: agents/ bin/ configs/ data/ docs/ logs/ scripts/ services/ sessions/
```

### Step 3: Install SystemD Units
```bash
# Use installation script
cd /opt/linuxia
sudo ./scripts/systemd-install.sh

# Verify installation
systemctl list-unit-files 'linuxia-*'
```

### Step 4: Verify Installation
```bash
cd /opt/linuxia
./scripts/verify-systemd.sh
./scripts/verify-platform.sh
# Expected: All [OK], exit code 0
```

### Step 5: Configure Storage Mounts (Optional)
```bash
# On VM100, as root:
sudo -i

# Activate bind mounts for shareA/shareB
systemctl start opt-linuxia-data-shareA.mount
systemctl start opt-linuxia-data-shareB.mount

# Make persistent (survive reboots)
systemctl enable opt-linuxia-data-shareA.mount
systemctl enable opt-linuxia-data-shareB.mount

# Verify
mount | grep -E "shareA|shareB"
```

### Step 6: Set Permissions for Shared Storage
```bash
# On VM100, as root:
sudo -i

# Ensure reports directory exists with proper permissions
mkdir -p /opt/linuxia/data/shareA/reports
mkdir -p /opt/linuxia/data/shareB/reports

# Option A: Simple group ownership (recommended for single-user systems)
chown -R gaby:users /opt/linuxia/data/shareA/reports
chown -R gaby:users /opt/linuxia/data/shareB/reports
chmod -R 775 /opt/linuxia/data/shareA/reports
chmod -R 775 /opt/linuxia/data/shareB/reports

# Option B: ACLs (if multiple users/services need write access)
# Install acl package if not present:
# zypper install acl
#
# setfacl -R -m u:gaby:rwx /opt/linuxia/data/shareA/reports
# setfacl -R -m g:users:rwx /opt/linuxia/data/shareA/reports
# setfacl -R -d -m u:gaby:rwx /opt/linuxia/data/shareA/reports  # default for new files
# setfacl -R -d -m g:users:rwx /opt/linuxia/data/shareA/reports

# Verify permissions
ls -ld /opt/linuxia/data/shareA/reports
getfacl /opt/linuxia/data/shareA/reports  # if using ACLs
```

**Notes**:
- Use Option A (simple permissions) unless you need fine-grained multi-user access
- If systemd services write to reports/, ensure their User= directive matches permissions
- The `nofail` mount option ensures system boots even if mounts fail

---

## ✅ Verification Procedures

### Daily Health Check
```bash
# Quick timer status
systemctl list-timers 'linuxia-*'

# Full verification
cd /opt/linuxia
./scripts/verify-systemd.sh
./scripts/verify-platform.sh

# Check for errors today
journalctl -u 'linuxia-*' --since today --priority=err --no-pager
```

### Deep Inspection
```bash
# Service unit status
systemctl status linuxia-configsnap.service --no-pager -l
systemctl status linuxia-healthcheck.service --no-pager -l

# Timer last/next trigger times
systemctl list-timers 'linuxia-*' --all

# Disk usage for critical paths
df -h /opt/linuxia
du -sh /opt/linuxia/data/shareA/archives/configsnap
du -sh /opt/linuxia/logs
```

### Mount Verification
```bash
# Check shared mounts
mount | grep -E '(shareA|shareB|DATA_1TB)'

# Verify permissions
ls -ld /opt/linuxia/data/shareA
ls -ld /opt/linuxia/data/shareB
ls -ld /mnt/linuxia/DATA_1TB_A
ls -ld /mnt/linuxia/DATA_1TB_B

# SELinux contexts
ls -ldZ /opt/linuxia/data/shareA
ls -ldZ /opt/linuxia/data/shareB
```

---

## 🔄 Restore Procedures

### Rollback SystemD Services
```bash
# Stop services
sudo systemctl stop linuxia-configsnap.timer
sudo systemctl stop linuxia-healthcheck.timer

# Disable timers
sudo systemctl disable linuxia-*.timer

# Restore from Git
cd /opt/linuxia
git log --oneline -10  # Identify good commit
git checkout <commit-hash> -- services/

# Reinstall
sudo ./scripts/systemd-install.sh

# Verify
./scripts/verify-systemd.sh
```

### Restore from Config Snapshot
```bash
# List available snapshots
ls -lht /opt/linuxia/data/shareA/archives/configsnap/ | head -10

# View snapshot contents (DRY RUN)
tar -tzf /opt/linuxia/data/shareA/archives/configsnap/linuxia-configsnap_YYYYMMDD_HHMMSS.tar.zst | less

# Extract to temporary location for inspection
cd /tmp
tar -xzf /opt/linuxia/data/shareA/archives/configsnap/linuxia-configsnap_YYYYMMDD_HHMMSS.tar.zst

# Manually restore specific files after validation
# Example: sudo cp /tmp/etc/systemd/system/linuxia-*.{service,timer} /etc/systemd/system/
```

### Emergency: Revert Repository
```bash
cd /opt/linuxia

# Check current state
git status
git log --oneline -5

# Option 1: Reset to remote (DESTRUCTIVE - loses uncommitted work)
git fetch origin
git reset --hard origin/main

# Option 2: Revert specific commit (preserves history)
git revert <bad-commit-hash>
git push

# Option 3: Restore specific file
git checkout HEAD~1 -- scripts/problematic-script.sh
```

---


## 🐛 Troubleshooting

### Timer Not Triggering
**Symptom**: `systemctl list-timers` shows timer but no recent triggers

**Diagnosis**:
```bash
systemctl status linuxia-configsnap.timer --no-pager -l
journalctl -u linuxia-configsnap.timer --since "24 hours ago" --no-pager
```

**Resolution**:
```bash
# Check timer is active
sudo systemctl is-active linuxia-configsnap.timer

# Restart timer
sudo systemctl restart linuxia-configsnap.timer

# Manual trigger (test service directly)
sudo systemctl start linuxia-configsnap.service

# Check service result
systemctl status linuxia-configsnap.service --no-pager -l
journalctl -u linuxia-configsnap.service -n 50 --no-pager
```

---

### Service Failing
**Symptom**: `systemctl status <service>` shows "failed" state

**Diagnosis**:
```bash
systemctl status linuxia-configsnap.service --no-pager -l
journalctl -xe -u linuxia-configsnap.service --no-pager
```

**Common Causes**:
1. **Permission denied**: Check script executable bits
2. **Path not found**: Verify target directories exist
3. **SELinux denial**: Check AVC denials

**Resolution**:
```bash
# Fix permissions
chmod +x /opt/linuxia/scripts/*.sh

# Create missing directories
sudo mkdir -p /opt/linuxia/data/shareA/archives/configsnap
sudo chown gaby:users /opt/linuxia/data/shareA/archives/configsnap

# SELinux: check denials
sudo ausearch -m avc -ts recent | grep linuxia

# Reset service failure state
sudo systemctl reset-failed linuxia-configsnap.service
```

---

### Permission Denied Writing to shareA/shareB
**Symptom**: Services fail with "Permission denied" when writing to `/opt/linuxia/data/shareA/reports`

**Diagnosis**:
```bash
# Check current permissions
ls -ld /opt/linuxia/data/shareA/reports
getfacl /opt/linuxia/data/shareA/reports  # if using ACLs

# Check mount status
mount | grep shareA
systemctl status opt-linuxia-data-shareA.mount

# Check which user is running the service
systemctl show -p User linuxia-health-report.service

# Test write access
sudo -u gaby touch /opt/linuxia/data/shareA/reports/test.txt
```

**Common Causes**:
1. **Wrong ownership**: Directory owned by root or wrong user
2. **Restrictive permissions**: 755 instead of 775, missing group write
3. **Mount not active**: shareA not mounted, writing to empty local directory
4. **SELinux context**: Wrong security context on NTFS mounts

**Resolution**:
```bash
# On VM100, as root:
sudo -i

# Ensure shareA is mounted
systemctl start opt-linuxia-data-shareA.mount
mount | grep shareA  # verify

# Fix ownership and permissions
chown -R gaby:users /opt/linuxia/data/shareA/reports
chmod -R 775 /opt/linuxia/data/shareA/reports

# If using ACLs:
setfacl -R -m u:gaby:rwx /opt/linuxia/data/shareA/reports
setfacl -R -m g:users:rwx /opt/linuxia/data/shareA/reports
setfacl -R -d -m u:gaby:rwx /opt/linuxia/data/shareA/reports
setfacl -R -d -m g:users:rwx /opt/linuxia/data/shareA/reports

# Verify write access
sudo -u gaby touch /opt/linuxia/data/shareA/reports/test-$(date +%s).txt
ls -la /opt/linuxia/data/shareA/reports/
```

---

### Mounts Inactive After Reboot
**Symptom**: `systemctl status opt-linuxia-data-shareA.mount` shows "inactive (dead)"

**Diagnosis**:
```bash
# Check if mount is enabled
systemctl is-enabled opt-linuxia-data-shareA.mount

# Check source directories exist
ls -ld /srv/linuxia-share/DATA_1TB_A/LinuxIA_SMB

# Check fstab entries
grep shareA /etc/fstab

# Check systemd mount unit
systemctl cat opt-linuxia-data-shareA.mount
```

**Resolution**:
```bash
# On VM100, as root:
sudo -i

# Enable mount to auto-activate
systemctl enable opt-linuxia-data-shareA.mount
systemctl enable opt-linuxia-data-shareB.mount

# Start now
systemctl start opt-linuxia-data-shareA.mount
systemctl start opt-linuxia-data-shareB.mount

# Verify
systemctl status opt-linuxia-data-shareA.mount
mount | grep shareA
```

**Notes**:
- Mounts use `nofail` option to prevent boot failures
- If physical disk (`/mnt/linuxia/DATA_1TB_A`) is unmounted, shareA bind mount will fail
- Check `/srv/linuxia-share/` intermediate bind mounts are active

---

### Disk Space Full
**Symptom**: `/opt/linuxia` partition at high usage

**Diagnosis**:
```bash
df -h /opt/linuxia
du -sh /opt/linuxia/* | sort -h
du -sh /opt/linuxia/data/shareA/archives/configsnap/* | sort -h | tail -20
```

**Resolution**:
```bash
# Clean old configsnap archives (DRY RUN FIRST)
./scripts/backup-configsnap-retention.sh --dry-run --keep-days 30

# Clean systemd journal
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=500M

# Clean old logs
find /opt/linuxia/logs -type f -name "*.log" -mtime +30 -ls
# After review: find /opt/linuxia/logs -type f -name "*.log" -mtime +30 -delete
```

---

### Mount Point Missing
**Symptom**: `/opt/linuxia/data/shareA` or mount points not accessible

**Diagnosis**:
```bash
mount | grep -E '(shareA|shareB|DATA_1TB)'
ls -ld /opt/linuxia/data/shareA
ls -ld /mnt/linuxia/DATA_1TB_A
dmesg | grep -i mount | tail -20
journalctl -u '*.mount' --since "1 hour ago" --no-pager
```

**Resolution**:
```bash
# Check /etc/fstab entries
grep -E '(shareA|shareB|DATA_1TB)' /etc/fstab

# Create mount point if missing
sudo mkdir -p /opt/linuxia/data/shareA
sudo mkdir -p /opt/linuxia/data/shareB
sudo mkdir -p /mnt/linuxia/DATA_1TB_A
sudo mkdir -p /mnt/linuxia/DATA_1TB_B

# Remount
sudo mount -a

# Verify
mount | grep -E '(shareA|shareB|DATA_1TB)'
df -h /opt/linuxia/data/share{A,B}
df -h /mnt/linuxia/DATA_1TB_{A,B}
```

---

### SELinux Denials
**Symptom**: Services fail with "permission denied" despite correct file permissions

**Diagnosis**:
```bash
# Check SELinux mode
getenforce

# Search for recent denials
sudo ausearch -m avc -ts recent

# Check file contexts
ls -Z /opt/linuxia/scripts/*.sh
ls -ldZ /opt/linuxia/data/shareA
```

**Resolution**:
```bash
# Review denials and identify required contexts
sudo ausearch -m avc -ts recent | audit2why

# Temporarily set permissive mode (TESTING ONLY)
sudo setenforce 0

# Test service
sudo systemctl start linuxia-configsnap.service

# If works, identify needed policy
sudo ausearch -m avc -ts recent | audit2allow -M linuxia_local

# Apply policy (after review)
sudo semodule -i linuxia_local.pp

# Re-enable enforcing
sudo setenforce 1
```

---

### 🚫 Permission Denied — Exit Code 126

**Symptom**: Script exits with code `126` or `bash: ./scripts/foo.sh: Permission denied`

Exit 126 means the shell found the file but **could not execute it**. Different from exit 127 (file not found).

#### Causes and fixes

**1 — Executable bit missing (most common)**
```bash
ls -l scripts/foo.sh
# If you see -rw-r--r-- (no x), fix with:
chmod +x scripts/foo.sh
# Or for the whole scripts/ dir:
chmod +x scripts/*.sh
# In git (persists across clones):
git update-index --chmod=+x scripts/foo.sh
```

**2 — Wrong shebang or missing shebang**
```bash
# Check first line:
sed -n '1p' scripts/foo.sh
# Expected: #!/usr/bin/env bash   or   #!/bin/bash
# If blank or wrong, add: #!/usr/bin/env bash  as first line
```

**3 — Windows CRLF line endings**
```bash
file scripts/foo.sh
# If output says "CRLF line terminators", strip them:
sed -i 's/\r$//' scripts/foo.sh
# Or with dos2unix (if installed):
dos2unix scripts/foo.sh
```

**4 — Filesystem mounted noexec**
```bash
mount | grep -E "(opt|linuxia|shareA|shareB)"
# If you see "noexec" in the mount options, the filesystem blocks execution.
# Fix: remount without noexec (requires root):
sudo mount -o remount,exec /opt/linuxia
```

**5 — Wrong file owner / ACL issue**
```bash
stat -c "%a %U:%G %n" scripts/foo.sh
# Expected: 755 gaby:users   (or at least user-executable)
sudo chown gaby:users scripts/foo.sh
chmod 755 scripts/foo.sh
```

**6 — Script run via git on a root-owned object**
```bash
# git objects owned by root can block operations:
sudo chown -R gaby:users /opt/linuxia/.git/objects
sudo find /opt/linuxia/.git/objects -type d -exec chmod 775 {} \;
sudo find /opt/linuxia/.git/objects -type f -exec chmod 664 {} \;
```

#### Quick diagnostic checklist

```bash
# All-in-one: check executable + shebang + encoding
f=scripts/verify-platform.sh
ls -l "$f"
stat -c "%a %U:%G" "$f"
sed -n '1p' "$f"
file "$f"
mount | grep "$(df -P "$f" | tail -1 | awk '{print $6}')" | grep noexec || printf "noexec: not set\n"
```

---

## 🩺 Platform Doctor (`make doctor` / `linuxia doctor`)

A single command that performs a full read-only health check and writes a timestamped report:

```bash
# From the repo root:
make doctor

# Or via the CLI wrapper:
scripts/linuxia doctor
```

### What it does

1. **Runs `scripts/verify-platform.sh`** — checks critical paths, disk usage, failed systemd units, required timers, configsnap archives, optional mounts, and health report freshness. Exits with code `0` (OK), `1` (WARN), or `2` (FAIL).
2. **Runs `scripts/health-report.sh`** (if present) — writes a timestamped `.txt` report collecting uptime, disk, mounts, logs, and timer status.
3. **Prints report paths** so you know exactly where to look:
   - Health logs: `/opt/linuxia/logs/health`
   - Health share copy: `/opt/linuxia/data/shareA/reports/health`

### Overriding report directories

```bash
make doctor HEALTH_LOG_DIR=/tmp/health HEALTH_SHARE_DIR=/tmp/health-share
```

### Expected output (healthy system)

```
=== LinuxIA verify-platform (READ-ONLY) ===
...
OK=N WARN=0 FAIL=0

=== LinuxIA health-report ===
OK: report written -> /opt/linuxia/logs/health/health-vm100-20260224-120000.txt

=== Report paths ===
  Health logs:   /opt/linuxia/logs/health
  Health share:  /opt/linuxia/data/shareA/reports/health
```

---

## 📊 Monitoring Checklist

### Daily (Automated via timers)
- [ ] configsnap executed successfully
- [ ] healthcheck ran without errors

### Weekly (Manual)
- [ ] Run `make doctor` (or `scripts/linuxia doctor`) → verify-platform + health-report, exit 0
- [ ] Run `./scripts/verify-systemd.sh` → exit 0
- [ ] Review disk usage trends: `df -h /opt/linuxia`
- [ ] Check systemd errors: `journalctl -p err --since "7 days ago" | grep linuxia`
- [ ] Verify mount points: `mount | grep -E '(shareA|shareB|DATA_1TB)'`

### Monthly
- [ ] Review configsnap retention policy
- [ ] Test backup restore procedure (sample snapshot)
- [ ] Update runbook with new lessons learned
- [ ] Review SELinux denials: `ausearch -m avc -ts month | wc -l`
- [ ] Audit SSH access logs: `journalctl -u sshd --since "30 days ago" | grep -i failed`

---

## 🆘 Emergency Contacts

### Quick SSH Reference
- **Proxmox Host**: `ssh root@192.168.1.128`
- **VM100 Factory**: `ssh gaby@192.168.1.135`
- **VM101 Layer2**: `ssh gaby@192.168.1.136`
- **VM102 Tool**: `ssh gaby@192.168.1.137`

### Escalation Path
1. Check `/opt/linuxia/logs` for application logs
2. Check `journalctl -u linuxia-*` for service logs
3. Run verification scripts (`verify-systemd.sh`, `verify-platform.sh`)
4. Review recent Git commits: `git log --oneline -10`
5. Check SELinux denials: `ausearch -m avc -ts recent`
6. Open GitHub Issue using `ops_change.md` template

### Recovery Commands
```bash
# Quick health snapshot
cd /opt/linuxia
./scripts/verify-systemd.sh > /tmp/health-$(date +%Y%m%d-%H%M%S).txt 2>&1
./scripts/verify-platform.sh >> /tmp/health-$(date +%Y%m%d-%H%M%S).txt 2>&1

# Safe reboot (stops timers first)
sudo systemctl stop linuxia-*.timer
sudo reboot

# Emergency: disable all LinuxIA timers
sudo systemctl disable --now linuxia-*.timer
```
