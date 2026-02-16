# LinuxIA - Security Documentation

## Overview
This document outlines security principles, implementations, and operational procedures for the LinuxIA platform.

---

## Security Philosophy

### Defense in Depth
Multiple layers of security controls to protect against various threat vectors:
1. **Network isolation** - No public exposure except SSH
2. **Access control** - SSH key-based authentication only
3. **Privilege separation** - Minimal sudo usage, dedicated service accounts
4. **Mandatory access control** - SELinux enforcing on critical systems
5. **Audit logging** - Comprehensive logging of all operations

### Principle of Least Privilege
- Services run with minimal required permissions
- Users have only necessary access rights
- Temporary privilege escalation logged and audited

---

## SSH Security

### Configuration Standards

**Key-based Authentication Only**
```bash
# /etc/ssh/sshd_config critical settings
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin prohibit-password  # VM100, VM101, VM102
PermitRootLogin yes                # Proxmox host only
```

### SSH Key Management

**Key Generation**
```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -C "gaby@vm100-factory" -f ~/.ssh/id_ed25519_vm100

# Or RSA 4096 for compatibility
ssh-keygen -t rsa -b 4096 -C "gaby@vm100-factory" -f ~/.ssh/id_rsa_vm100
```

**Key Distribution**
```bash
# Deploy public key to target VM
ssh-copy-id -i ~/.ssh/id_ed25519_vm100.pub gaby@192.168.1.135

# Verify key-based auth works
ssh -i ~/.ssh/id_ed25519_vm100 gaby@192.168.1.135

# Disable password auth (after verification)
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl reload sshd
```

**Key Rotation Policy**
- Rotate SSH keys annually (minimum)
- Immediate rotation if key compromise suspected
- Document key rotation in Git commit message

### Access Matrix

| User | VM100 | VM101 | VM102 | Proxmox |
|------|-------|-------|-------|---------|
| gaby | ✅ SSH | ✅ SSH | ✅ SSH | ❌ No access |
| root | ❌ No direct | ❌ No direct | ❌ No direct | ✅ SSH (emergency only) |

**IP Addresses (for reference)**
- Proxmox: `192.168.1.128`
- VM100 Factory: `192.168.1.135`
- VM101 Layer2: `192.168.1.136`
- VM102 Tool: `192.168.1.137`

---

## SELinux

### Enforcement Policy

**VM100 (Factory)**: SELinux **Enforcing** mode
```bash
# Verify enforcement
getenforce
# Expected: Enforcing

# Set enforcing (if not already)
sudo setenforce 1

# Make permanent
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
```

### Common SELinux Operations

**Check denials**
```bash
# Recent denials
sudo ausearch -m avc -ts recent

# Today's denials
sudo ausearch -m avc -ts today

# Denials for specific service
sudo ausearch -m avc -ts recent | grep linuxia
```

**Analyze and create policy**
```bash
# Analyze denials
sudo ausearch -m avc -ts recent | audit2why

# Generate policy module
sudo ausearch -m avc -ts recent | audit2allow -M linuxia_custom

# Review generated policy (CRITICAL - review before applying)
cat linuxia_custom.te

# Apply policy (after review)
sudo semodule -i linuxia_custom.pp

# List installed modules
sudo semodule -l | grep linuxia
```

**File contexts for shared mounts**
```bash
# Check current contexts
ls -ldZ /opt/linuxia/data/shareA
ls -ldZ /opt/linuxia/data/shareB

# Set context for shared directories
sudo semanage fcontext -a -t public_content_rw_t "/opt/linuxia/data/shareA(/.*)?"
sudo semanage fcontext -a -t public_content_rw_t "/opt/linuxia/data/shareB(/.*)?"
sudo restorecon -Rv /opt/linuxia/data/shareA
sudo restorecon -Rv /opt/linuxia/data/shareB
```

### Troubleshooting SELinux

**Temporary permissive mode (testing only)**
```bash
# WARNING: Only for troubleshooting
sudo setenforce 0
# Test your operation
# Check denials: ausearch -m avc -ts recent
# Re-enable: sudo setenforce 1
```

**Persistent context changes**
```bash
# Relabel filesystem (reboot required)
sudo touch /.autorelabel
sudo reboot
```

---

## Shared Storage Security

### Mount Types

| Mount | Type | Security Level | Use Case |
|-------|------|----------------|----------|
| shareA | Bind mount / NFS | Medium | Archives, configsnap |
| shareB | Bind mount / NFS | Medium | Shared workspace |
| DATA_1TB_A | NTFS / NFS | Low | Large data storage |
| DATA_1TB_B | NTFS / NFS | Low | Large data storage |

### NTFS Mounts with SELinux

**Mount options for NTFS**
```bash
# /etc/fstab example
/dev/sdb1  /mnt/linuxia/DATA_1TB_A  ntfs-3g  defaults,context=system_u:object_r:public_content_rw_t:s0,uid=1000,gid=100  0  0
```

**Permissions verification**
```bash
# Check mount options
mount | grep DATA_1TB

# Verify user/group ownership
ls -ld /mnt/linuxia/DATA_1TB_A

# Test write access
touch /mnt/linuxia/DATA_1TB_A/test_write_access.txt
rm /mnt/linuxia/DATA_1TB_A/test_write_access.txt
```

### NFS/Samba Security

**NFS exports (if used)**
```bash
# /etc/exports example
/opt/linuxia/data/shareA  192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
```

**Samba shares (if used)**
```bash
# /etc/samba/smb.conf example
[shareA]
    path = /opt/linuxia/data/shareA
    valid users = gaby
    read only = no
    browseable = yes
```

**Audit mounted shares**
```bash
# List all NFS/Samba mounts
mount | grep -E '(nfs|cifs)'

# Check for stale mounts
df -h | grep -E '(shareA|shareB|DATA_1TB)'
```

---

## Secrets Management

### What NOT to Commit
- SSH private keys
- API tokens (GPT, GitHub, etc.)
- Passwords or password hashes
- TLS/SSL private keys
- Database credentials

### .gitignore Rules
```gitignore
# Secrets
*.key
*.pem
*.p12
*.pfx
secrets/
.env
.env.local

# Data directories (not in Git)
data/
logs/
workspace/
sessions/
```

### Checking for Leaked Secrets
```bash
# Search for potential secrets in repository
git log -p | grep -iE '(password|token|api_key|secret)'

# Scan staged files before commit
git diff --cached | grep -iE '(password|token|api_key|secret)'
```

### Removing Committed Secrets

**If secret committed but not pushed**
```bash
# Amend last commit
git commit --amend

# Or reset and recommit
git reset --soft HEAD~1
# Remove secret from files
git add .
git commit -m "Fixed: removed secret"
```

**If secret pushed to GitHub (CRITICAL)**
```bash
# 1. Revoke/rotate the exposed secret immediately
# 2. Remove from history (use BFG Repo Cleaner or git filter-branch)
# 3. Force push (coordinate with team)
# 4. Document incident

# Example: remove file from all history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/secret/file' \
  --prune-empty --tag-name-filter cat -- --all

# Force push (DANGER)
git push origin --force --all
```

---

## Proxmox Host Security

### Access Control
- Root access via SSH key only
- Access limited to emergency operations
- All administrative changes logged

### Hardening Checklist
- [ ] SSH key-based auth configured
- [ ] Password authentication disabled
- [ ] Firewall rules limiting SSH to internal network
- [ ] Regular security updates applied
- [ ] Audit logging enabled

**Check Proxmox SSH config**
```bash
# On Proxmox host
ssh root@192.168.1.128
grep -E '^(PasswordAuthentication|PermitRootLogin)' /etc/ssh/sshd_config
```

---

## Audit and Monitoring

### Security Event Logging

**SSH access logs**
```bash
# Failed SSH attempts
sudo journalctl -u sshd --since "7 days ago" | grep -i failed

# Successful SSH logins
sudo journalctl -u sshd --since "7 days ago" | grep -i accepted

# Login summary
last -n 20
```

**Sudo usage audit**
```bash
# Recent sudo usage
sudo journalctl SYSLOG_IDENTIFIER=sudo --since today

# Specific user sudo history
sudo grep -i 'gaby.*sudo' /var/log/auth.log
```

**SELinux denials**
```bash
# Count denials today
sudo ausearch -m avc -ts today | grep denied | wc -l

# Detailed denial analysis
sudo ausearch -m avc -ts today | audit2why
```

### Security Monitoring Schedule

**Daily** (automated via timer):
- Check failed SSH attempts
- Verify SELinux enforcing mode
- Review systemd service failures

**Weekly** (manual):
- Audit sudo usage
- Review SELinux denials and adjust policies if needed
- Check for available security updates: `sudo zypper list-updates`

**Monthly**:
- Review and rotate logs
- Audit user accounts and permissions
- Test backup restore procedures (includes config snapshots)

---

## Incident Response

### Suspected Compromise

**Immediate Actions**
1. Isolate affected VM (network disconnect if needed)
2. Preserve logs and evidence
3. Revoke potentially compromised credentials
4. Review recent commits and changes

**Investigation Commands**
```bash
# Recent commands executed
history

# Recent logins
last -20

# Active SSH sessions
who

# Running processes
ps auxf

# Network connections
ss -tunap
```

**Recovery**
```bash
# Roll back to known good state
cd /opt/linuxia
git log --oneline -10  # Identify last known good commit
git reset --hard <commit-hash>
sudo systemctl restart linuxia-*.timer
```

---

## Compliance and Best Practices

### Change Control
- All security-related changes require GitHub Issue
- Use `ops_change.md` template for operational changes
- Include rollback plan in every PR

### Documentation Requirements
- Document all SELinux policy changes
- Record SSH key rotations in Git commit messages
- Update this security.md when procedures change

### Periodic Security Reviews
- Quarterly review of SSH keys
- Quarterly review of SELinux policies
- Annual penetration test (or self-assessment)

---

## Quick Reference

### Emergency Contacts
- **VM100**: `ssh gaby@192.168.1.135`
- **Proxmox**: `ssh root@192.168.1.128` (emergency only)

### Critical Commands
```bash
# Check SELinux status
getenforce

# Review failed SSH attempts
sudo journalctl -u sshd | grep -i failed | tail -20

# Verify systemd service status
systemctl status linuxia-*

# Check for security updates
sudo zypper list-updates --category security
```

### Security Incident Reporting
1. Open GitHub Issue with `[SECURITY]` prefix
2. Document timeline and affected systems
3. List remediation steps taken
4. Include lessons learned
