<p align="center">
  <img src="assets/readme/banner-linuxia.svg" width="1000" alt="LinuxIA animated banner" />

</p>

# LinuxIA — Proof-First Agent Ops

<!-- LINUXIA:SHOWCASE_CINEMATIC:START -->
## Showcase Cinematic

<p align="center">
  <img src="assets/readme/sections/section_01_vision.svg" width="1000" alt="LinuxIA Vision" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_02_architecture.svg" width="1000" alt="LinuxIA Architecture" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_03_agents.svg" width="1000" alt="LinuxIA Agents" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_04_proof.svg" width="1000" alt="LinuxIA Proof" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_05_infra.svg" width="1000" alt="LinuxIA Infra" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_06_security.svg" width="1000" alt="LinuxIA Security" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_07_storage.svg" width="1000" alt="LinuxIA Storage" />
</p>

<p align="center">
  <img src="assets/readme/sections/section_08_roadmap.svg" width="1000" alt="LinuxIA Roadmap" />
</p>

> Echange `assets/readme/gallery/p01.jpg` ... `p08.jpg` pour changer les photos sans toucher au README.

<!-- LINUXIA:SHOWCASE_CINEMATIC:END -->

<!-- LINUXIA:TRAILERS_MP4:START -->
## Trailers (MP4)

> GitHub n'embed pas les MP4 inline, mais les liens ci-dessous ouvrent les videos.

<p align="center">
  <a href="assets/readme/mp4/section_01_vision.mp4"><img src="assets/readme/posters/section_01_vision.png" width="1000" alt="Trailer Vision" /></a>
  <a href="assets/readme/mp4/section_02_architecture.mp4"><img src="assets/readme/posters/section_02_architecture.png" width="1000" alt="Trailer Architecture" /></a>
  <a href="assets/readme/mp4/section_03_agents.mp4"><img src="assets/readme/posters/section_03_agents.png" width="1000" alt="Trailer Agents" /></a>
  <a href="assets/readme/mp4/section_04_proof.mp4"><img src="assets/readme/posters/section_04_proof.png" width="1000" alt="Trailer Proof" /></a>
  <a href="assets/readme/mp4/section_05_infra.mp4"><img src="assets/readme/posters/section_05_infra.png" width="1000" alt="Trailer Infra" /></a>
  <a href="assets/readme/mp4/section_06_security.mp4"><img src="assets/readme/posters/section_06_security.png" width="1000" alt="Trailer Security" /></a>
  <a href="assets/readme/mp4/section_07_storage.mp4"><img src="assets/readme/posters/section_07_storage.png" width="1000" alt="Trailer Storage" /></a>
  <a href="assets/readme/mp4/section_08_roadmap.mp4"><img src="assets/readme/posters/section_08_roadmap.png" width="1000" alt="Trailer Roadmap" /></a>
</p>
<!-- LINUXIA:TRAILERS_MP4:END -->



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


## Animations SVG

> Sélection des meilleures animations (SVG). Clique pour ouvrir en grand.

[![anim_01_score90.svg](assets/readme/animations/anim_01_score90.svg)](assets/readme/animations/anim_01_score90.svg) | [![anim_02_score11.svg](assets/readme/animations/anim_02_score11.svg)](assets/readme/animations/anim_02_score11.svg) | [![anim_03_score9.svg](assets/readme/animations/anim_03_score9.svg)](assets/readme/animations/anim_03_score9.svg)
[![anim_04_score15.svg](assets/readme/animations/anim_04_score15.svg)](assets/readme/animations/anim_04_score15.svg) | [![anim_05_score25.svg](assets/readme/animations/anim_05_score25.svg)](assets/readme/animations/anim_05_score25.svg) | [![anim_06_score175.svg](assets/readme/animations/anim_06_score175.svg)](assets/readme/animations/anim_06_score175.svg)
[![anim_07_score11.svg](assets/readme/animations/anim_07_score11.svg)](assets/readme/animations/anim_07_score11.svg) | [![anim_08_score9.svg](assets/readme/animations/anim_08_score9.svg)](assets/readme/animations/anim_08_score9.svg) | [![anim_09_score422.svg](assets/readme/animations/anim_09_score422.svg)](assets/readme/animations/anim_09_score422.svg)


## Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) |
[Good First Issues](https://github.com/Topbrutus/LinuxIA/labels/good%20first%20issue)

---

## License

To be determined
