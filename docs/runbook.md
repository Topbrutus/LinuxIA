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

## 📊 Monitoring Checklist

### Daily (Automated via timers)
- [ ] configsnap executed successfully
- [ ] healthcheck ran without errors

### Weekly (Manual)
- [ ] Run `./scripts/verify-systemd.sh` → exit 0
- [ ] Run `./scripts/verify-platform.sh` → exit 0
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
