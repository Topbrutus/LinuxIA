<p align="center">
  <img src="assets/readme/banner-linuxia.svg" width="1000" alt="LinuxIA animated banner" />
</p>

# LinuxIA — Proof-First Agent Ops

[![Phase 6](https://img.shields.io/badge/Phase_6-✅_Merged-success)](https://github.com/Topbrutus/LinuxIA/pulls?q=is%3Apr+is%3Aclosed)
[![Verify](https://img.shields.io/badge/verify--platform-OK=24_WARN=0-brightgreen)](docs/runbook.md)

**Proof-first multi-VM orchestration** (Proxmox + openSUSE + systemd + GitHub)

---

## What

Automated infrastructure ops with **mandatory proof generation**:

- Every change → timestamped evidence
- Scripts: bash + shellcheck + `set -euo pipefail`
- Systemd timers (configsnap, healthchecks, reports)
- GitHub PR workflow + CI

---

## Architecture

- **VM100** (`vm100-factory`): Main repo, storage, Samba, health reports
- **VM101** (`vm101-layer2`): CIFS client, independent proofs
- **VM102** (`vm102-tool`): Sandbox, tests, API orchestrator

---

## Quick Start

```bash
git clone git@github.com:Topbrutus/LinuxIA.git /opt/linuxia
cd /opt/linuxia
bash scripts/verify-platform.sh
# Should show: OK=24 WARN=0 FAIL=0
```

---

## Status

* **Latest:** Phase 6 merged (health reports + systemd timers)
* **Proof:** See [docs/status.md](docs/status.md)
* **Runbook:** [docs/runbook.md](docs/runbook.md)
* **Checklists:** [docs/checklists/](docs/checklists/)

---

## Media

- 🎵 Theme: [Theme_01.mp3](assets/readme/audio/Theme_01.mp3)
- 🎬 Trailer 01: [Trailer_01.mp4](assets/readme/videos/Trailer_01.mp4)
- 🎬 Trailer 02: [Trailer_02.mp4](assets/readme/videos/Trailer_02.mp4)

## Guides

- [Mode d'emploi — Linux Mint 22.2 → Agent maison](docs/Mode_emploi_LinuxMint22_2_Agent_Maison.md)

---

## Gallery (temporary small thumbnails)

<p align="center">
  <img src="assets/readme/gallery/LinuxIA_02.jpg" width="220" alt="LinuxIA_02" />
  <img src="assets/readme/gallery/LinuxIA_03.jpg" width="220" alt="LinuxIA_03" />
  <img src="assets/readme/gallery/LinuxIA_04.jpg" width="220" alt="LinuxIA_04" />
  <img src="assets/readme/gallery/LinuxIA_05.jpg" width="220" alt="LinuxIA_05" />
</p>

<p align="center">
  <img src="assets/readme/gallery/LinuxIA_06.jpg" width="220" alt="LinuxIA_06" />
  <img src="assets/readme/gallery/LinuxIA_07.jpg" width="220" alt="LinuxIA_07" />
  <img src="assets/readme/gallery/LinuxIA_08.jpg" width="220" alt="LinuxIA_08" />
  <img src="assets/readme/gallery/LinuxIA_09.jpg" width="220" alt="LinuxIA_09" />
</p>

<p align="center">
  <img src="assets/readme/gallery/LinuxIA_10.jpg" width="220" alt="LinuxIA_10" />
  <img src="assets/readme/gallery/LinuxIA_11.jpg" width="220" alt="LinuxIA_11" />
  <img src="assets/readme/gallery/LinuxIA_12.jpg" width="220" alt="LinuxIA_12" />
</p>


## Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) |
[Good First Issues](https://github.com/Topbrutus/LinuxIA/labels/good%20first%20issue)

---

## License

To be determined
