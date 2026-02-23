# LinuxIA - Project Overview

## Vision
Self-hosted multi-agent AI platform leveraging cloud-based GPT instances, with infrastructure automation and operational excellence through Infrastructure as Code principles.

## Infrastructure

### Proxmox VE 9.1 Foundation
- **Host**: GPU passthrough enabled (NVIDIA GTX 1080)
- **VMs**: 3-tier architecture for separation of concerns
- **Security**: SSH hardened, SELinux enforced on critical VMs

### VM Architecture

| VM | Hostname | Role | Critical Services |
|----|----------|------|-------------------|
| VM100 | Factory | Control plane, orchestration, admin | systemd timers, configsnap, runbooks |
| VM101 | Layer2 | Specialized agents (research, analysis) | Agent containers |
| VM102 | Tool | Dedicated tooling agents | Tool containers |

**Design Principle**: Strict separation between control (Factory) and execution (Layer2/Tool).

## Multi-Agent System

### Agent Hierarchy
1. **Agent 001** (Architect/Orchestrator): Central coordinator on VM100
2. **Team Lead**: Distributes tasks to specialized agents
3. **Research Agents**: Specialized workers on VM101/VM102

### Technical Stack
- **Orchestration**: Python/Node.js scripts
- **Browser Automation**: Chromium headless via Playwright/Puppeteer
- **Logging**: JSONL format for agent interactions
- **AI Models**: GPT instances via API

## Data Management

### Shared Storage
- **NFS/Samba/Virtio-FS**: Performance vs security tradeoffs
- **Critical Paths**:
  - `/opt/linuxia/data/shareA` (archives, configsnap)
  - `/opt/linuxia/data/shareB` (shared workspace)
  - `/mnt/linuxia/DATA_1TB_A` (shared mount A)
  - `/mnt/linuxia/DATA_1TB_B` (shared mount B)
- **NTFS Integration**: Dual-boot compatibility with SELinux hardening

### Configuration Snapshots
- **Tool**: configsnap via systemd timer
- **Storage**: `/opt/linuxia/data/shareA/archives/configsnap`
- **Frequency**: Automated via `linuxia-configsnap.timer` (daily at 03:00)

## Security Model

### Access Control
- **Proxmox**: Hardened access, minimal user accounts
- **SSH**: Key-based authentication only, strict key management
- **SELinux**: Enforcing mode on VM100 for mount/share isolation
- **Network**: No public exposure except SSH with restricted keys

### Audit Trail
- All operations logged to `/opt/linuxia/logs`
- JSONL structured logging for agent interactions
- systemd journal for service events

## Operational Philosophy

### Non-Negotiable Principles
1. **Human-in-the-Loop**: AI proposes, human validates and executes
2. **GitHub as Truth**: Issues = intent, PRs = changes, no persistent state outside Git
3. **Proof-First**: Every change includes verification commands and rollback procedures

### Versioning Strategy
- **Git Repository**: Single source of truth for all artifacts
- **Branching**: `main` (production), feature branches for changes
- **Commit Discipline**: Atomic commits, descriptive messages, Co-authored-by for AI assistance

## Current State

### ✅ Operational
- Proxmox VE with GPU passthrough
- VM100/101/102 provisioned and networked
- Multi-agent orchestration framework deployed
- SSH hardening and SELinux enforcement active
- SystemD timers for configsnap, healthcheck

### 🔄 In Progress
- Verification script suite expansion
- Runbook documentation
- GitHub workflow templates
- Security documentation consolidation

### 📋 Planned
- Retention policy automation for configsnap archives
- Monitoring dashboards
- Backup validation procedures

## Getting Started

### Prerequisites
- Access to Proxmox host (192.168.1.128)
- SSH key configured for VM100 (gaby@192.168.1.135)
- Git repository cloned to `/opt/linuxia`

### Quick Health Check
```bash
cd /opt/linuxia
./scripts/verify-systemd.sh    # Verify timers and services
./scripts/verify-platform.sh   # Platform-wide checks
```

### Documentation Index
- [Runbook](runbook.md) - Operational procedures for VM100
- [Security](security.md) - Security principles and configurations (planned)
- [Verification Scripts](verify.md) - SystemD verification usage
- [Copilot Contract](COPILOT_CONTRACT.md) - AI-assisted operations rules (planned)

## Repository Structure

```
/opt/linuxia/
├── agents/           # Agent configurations and scripts
├── bin/              # Executable binaries
├── configs/          # Configuration files
├── data/             # Data storage (not in Git)
│   ├── shareA/       # Shared storage A (archives, configsnap)
│   └── shareB/       # Shared storage B (workspace)
├── docs/             # Documentation
├── logs/             # Application logs (not in Git)
├── scripts/          # Operational scripts
├── services/         # SystemD unit files
└── sessions/         # Session storage (not in Git)
```

## Support

### Issue Tracking
Use GitHub Issues with appropriate templates:
- `ops_change.md` for operational changes requiring validation

### Emergency Contacts
- **Proxmox Host**: `ssh root@192.168.1.128`
- **VM100 Factory**: `ssh gaby@192.168.1.135`
- **VM101 Layer2**: `ssh gaby@192.168.1.136`
- **VM102 Tool**: `ssh gaby@192.168.1.137`

### Emergency Procedures
- **Rollback**: Revert to last known good commit via Git
- **Logs**: Check `/opt/linuxia/logs` and `journalctl -u linuxia-*`
- **Verification**: Run all `scripts/verify-*.sh` scripts
