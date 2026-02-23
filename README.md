# 🧠 LinuxIA — Proof-First Agent Ops

<p align="center">
  <img src="assets/readme/sections/section_01_vision.svg" width="1000" alt="Vision"/>
</p>

> **LinuxIA n'est pas un projet. C'est un organisme informatique distribué.**
> Chaque action laisse une preuve. Chaque agent a un rôle. Chaque VM est un organe.

**LinuxIA** is a self-hosted, proof-first multi-agent AI platform running on Proxmox VE. Every infrastructure change generates timestamped evidence stored in append-only logs and shared storage. AI proposes — humans validate.

---

## 🚀 Quick Start

```bash
# Clone the repository (requires write access to /opt/linuxia on VM100)
git clone git@github.com:Topbrutus/LinuxIA.git /opt/linuxia
cd /opt/linuxia

# Syntax-check all scripts
bash -n scripts/verify-platform.sh

# Run platform verification (read-only)
bash scripts/verify-platform.sh

# Run system health check
bash scripts/linuxia-healthcheck.sh
```

> ℹ️ On VM100, the repository lives at `/opt/linuxia`. To clone elsewhere (e.g., for local development), omit the target path.

---

## 🧩 Hub Status

<p align="center">
  <img src="assets/readme/anims/anim_01.svg" width="155"/>
  <img src="assets/readme/anims/anim_02.svg" width="155"/>
  <img src="assets/readme/anims/anim_03.svg" width="155"/>
  <img src="assets/readme/anims/anim_04.svg" width="155"/>
  <img src="assets/readme/anims/anim_05.svg" width="155"/>
  <img src="assets/readme/anims/anim_06.svg" width="155"/>
</p>
<p align="center">
  <img src="assets/readme/anims/anim_07.svg" width="155"/>
  <img src="assets/readme/anims/anim_08.svg" width="155"/>
  <img src="assets/readme/anims/anim_09.svg" width="155"/>
</p>

---

## 🌌 Architecture & Orchestration

<p align="center">
  <img src="assets/readme/sections/section_02_architecture.svg" width="1000" alt="Architecture"/>
</p>

## 🤖 Agents TriluxIA

<p align="center">
  <img src="assets/readme/sections/section_03_agents.svg" width="1000" alt="Agents"/>
</p>

## 🛡️ Immutable Proof

<p align="center">
  <img src="assets/readme/sections/section_04_proof.svg" width="1000" alt="Proof"/>
</p>

## ⚙️ Infra & Timers

<p align="center">
  <img src="assets/readme/sections/section_05_infra.svg" width="1000" alt="Infra"/>
</p>

## 🔒 Security

<p align="center">
  <img src="assets/readme/sections/section_06_security.svg" width="1000" alt="Security"/>
</p>

## 💾 Storage

<p align="center">
  <img src="assets/readme/sections/section_07_storage.svg" width="1000" alt="Storage"/>
</p>

## 🗺️ Roadmap

<p align="center">
  <img src="assets/readme/sections/section_08_roadmap.svg" width="1000" alt="Roadmap"/>
</p>

---

## 🖥️ VM Architecture

| VM | Role | Key Services |
|----|------|--------------|
| **VM100** Factory | Control plane, orchestration | systemd timers, configsnap, runbooks |
| **VM101** Layer2 | Specialized agents (research, analysis) | Agent containers |
| **VM102** Tool | Dedicated tooling agents | Tool containers |

---

## 📁 Repository Structure

```
/opt/linuxia/
├── scripts/          # Operational scripts (verify-platform, healthcheck…)
├── services/         # SystemD unit files and timers
├── docs/             # Documentation (runbook, security, verifications…)
├── ops/              # VM setup and orchestrator guides
├── sessions/         # Session logs (not in Git)
├── data/             # Shared storage (not in Git)
│   ├── shareA/       # Archives and configsnap evidence
│   └── shareB/       # Shared workspace
└── logs/             # Application logs (not in Git)
```

---

## 📚 Documentation

- [Runbook](docs/runbook.md) — Operational procedures for VM100
- [Project Overview](docs/PROJECT_OVERVIEW.md) — Architecture and design decisions
- [Security](docs/security.md) — Security principles and configurations
- [Verification Scripts](docs/verify.md) — SystemD verification usage
- [Contributing](CONTRIBUTING.md) — Contribution guidelines and PR checklist
- [Security Policy](SECURITY.md) — Vulnerability reporting

---

## 🎬 Media Vault

- **Trailer 01**: [Watch](assets/readme/videos/Trailer_01.mp4)
- **Trailer 02**: [Watch](assets/readme/videos/Trailer_02.mp4)
- **Theme Audio**: [Listen](assets/readme/audio/Theme_01.mp3)

---

<p align="center">
  <img src="assets/readme/anims/anim_09.svg" width="120"/>
  <br/>
  <sub>© 2026 LINUXIA PROJECT • MISSION CONTROL v1.5.0</sub>
</p>
