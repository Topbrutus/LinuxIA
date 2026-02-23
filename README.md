<p align="center">
  <img src="assets/readme/banner-linuxia.svg" width="1000" alt="LinuxIA animated banner" />
</p>

# LinuxIA — Proof-First Agent Ops

> Orchestration multi-VM, agents systemd, preuve à chaque commit.

---

<!-- LINUXIA:HERO_3D:START -->
## Hero NASA 3D — Vision · Architecture · Agents · Proof

<p align="center">
  <img src="assets/readme/showcase/cards/section_01.png" width="1000" alt="LinuxIA — Vision" />
</p>
<p align="center">
  <img src="assets/readme/showcase/cards/section_02.png" width="1000" alt="LinuxIA — Architecture" />
</p>
<p align="center">
  <img src="assets/readme/showcase/cards/section_03.png" width="1000" alt="LinuxIA — Agents" />
</p>
<p align="center">
  <img src="assets/readme/showcase/cards/section_04.png" width="1000" alt="LinuxIA — Proof" />
</p>

<!-- LINUXIA:HERO_3D:END -->

---

<!-- LINUXIA:TRAILERS:START -->
## 🎬 Trailers

<p align="center">
  <a href="assets/readme/videos/Trailer_01.mp4">
    <img src="assets/readme/showcase/video_thumbs/Trailer_01.jpg" width="480" alt="Trailer 01" />
  </a>
  &nbsp;
  <a href="assets/readme/videos/Trailer_02.mp4">
    <img src="assets/readme/showcase/video_thumbs/Trailer_02.jpg" width="480" alt="Trailer 02" />
  </a>
</p>

> 🎵 Theme: [Theme_01.mp3](assets/readme/audio/Theme_01.mp3)

<!-- LINUXIA:TRAILERS:END -->

---

<!-- LINUXIA:GALLERY:START -->
## Gallery

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

<!-- LINUXIA:GALLERY:END -->

---

<!-- LINUXIA:ANIMATIONS:START -->
## Animations SVG

<p align="center">
  <img src="assets/readme/anims/anim_09.svg" width="320" alt="anim_09" />
  <img src="assets/readme/anims/anim_06.svg" width="320" alt="anim_06" />
  <img src="assets/readme/anims/anim_01.svg" width="320" alt="anim_01" />
</p>

<p align="center">
  <img src="assets/readme/anims/anim_05.svg" width="320" alt="anim_05" />
  <img src="assets/readme/anims/anim_04.svg" width="320" alt="anim_04" />
  <img src="assets/readme/anims/anim_02.svg" width="320" alt="anim_02" />
</p>

<p align="center">
  <img src="assets/readme/anims/anim_07.svg" width="320" alt="anim_07" />
  <img src="assets/readme/anims/anim_08.svg" width="320" alt="anim_08" />
  <img src="assets/readme/anims/anim_03.svg" width="320" alt="anim_03" />
</p>
## Infra · Security · Storage · Roadmap

<p align="center">
  <img src="assets/readme/showcase/cards/section_05.png" width="490" alt="LinuxIA — Infra" />
  <img src="assets/readme/showcase/cards/section_06.png" width="490" alt="LinuxIA — Security" />
</p>
<p align="center">
  <img src="assets/readme/showcase/cards/section_07.png" width="490" alt="LinuxIA — Storage" />
  <img src="assets/readme/showcase/cards/section_08.png" width="490" alt="LinuxIA — Roadmap" />
</p>

<!-- LINUXIA:SECTIONS_REST:END -->

---

## What

Automated infrastructure ops with **mandatory proof generation**:

- Every change → timestamped evidence
- Scripts: bash + shellcheck + `set -euo pipefail`
- Systemd timers (configsnap, healthchecks, reports)
- GitHub PR workflow + CI

---

---

## Architecture

- **VM100** (`vm100-factory`): Main repo, storage, Samba, health reports
- **VM101** (`vm101-layer2`): CIFS client, independent proofs
- **VM102** (`vm102-tool`): Sandbox, tests, API orchestrator

---

---

## Quick Start

```bash
git clone git@github.com:Topbrutus/LinuxIA.git /opt/linuxia
cd /opt/linuxia
bash scripts/verify-platform.sh
# Should show: OK=24 WARN=0 FAIL=0
```

---

---

## Status

* **Latest:** Phase 6 merged (health reports + systemd timers)
* **Proof:** See [docs/status.md](docs/status.md)
* **Runbook:** [docs/runbook.md](docs/runbook.md)
* **Checklists:** [docs/checklists/](docs/checklists/)

---

---

## Guides

- [Mode d'emploi — Linux Mint 22.2 → Agent maison](docs/Mode_emploi_LinuxMint22_2_Agent_Maison.md)

---

---

## Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) |
[Good First Issues](https://github.com/Topbrutus/LinuxIA/labels/good%20first%20issue)

---

---

## License

To be determined
