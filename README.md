<!--
LINUXIA_README_VNEXT_REBUILD
Thème: NASA / Proxmox / Matrix — accents orange, animations fines, propres, GitHub-safe.
-->

<div align="center">

<!-- LOGO / HERO (SVG animé, fin et léger) -->
<img src="assets/readme/hero-badge.svg" alt="LinuxIA — Proof-First Agent Orchestration Framework" width="980"/>

<p>
  <a href="https://github.com/Topbrutus/LinuxIA/actions"><img alt="CI" src="https://img.shields.io/badge/CI-GitHub%20Actions-2ea043?style=flat"/></a>
  <a href="#"><img alt="Proxmox" src="https://img.shields.io/badge/Proxmox-VE%20(KVM%2FLXC)-ff7a18?style=flat"/></a>
  <a href="#"><img alt="Proof-First" src="https://img.shields.io/badge/Proof%E2%80%91First-Logs%20%2B%20DoD-7c3aed?style=flat"/></a>
  <a href="#"><img alt="Artifacts" src="https://img.shields.io/badge/Artifacts-RAM%E2%86%92NVMe%E2%86%92SATA-00ff9d?style=flat"/></a>
</p>

</div>

---

## 🧠 LinuxIA — c'est quoi?

LinuxIA est une infrastructure **multi-couches** bâtie autour de **Proxmox VE** (KVM + LXC) pour orchestrer des environnements duplicables, **pilotés par preuves** (logs, checks, DoD), avec un objectif clair :

- **Latence minimale** (données "ultra-hot" en RAM + NVMe)
- **Ordonnancement maîtrisé** (couches, templates, agents, règles de priorité)
- **Résilience** (isolation VM/CT, quotas, dégradation progressive via zRAM)

---

## 🛰️ Architecture en 4 couches (Proxmox-native)

### Couche 0 — Hôte Proxmox (Orchestrateur)
- Hyperviseur & gestion ressources CPU/RAM/IO
- "Oracle mémoire" (pression RAM → actions correctives, priorité, protection)
- Stockage central des artefacts & caches partagés

### Couche 1 — VM100 "Usine" (Factory)
- Forge de **templates** (CT/VM) et **artefacts**
- Standardisation des environnements
- Pipeline de mise à jour: rebuild → test → diffusion

### Couche 2 — Outils duplicables ("Chromium")
- Instances clonées depuis template (rapide, homogène, isolé)
- Mini-agent local: exécution, supervision, dépôt d'artefacts, reporting
- Scalabilité horizontale (création/destruction rapide)

### Couche 3 — Workers externes
- Extension de capacité (CPU/GPU) sur nœuds satellites (cluster ou SSH/API)
- Déport de charges lourdes, tolérance accrue

---

## ⚡ Mémoire & stockage "Thermal-Tier" (Ultra-Hot → Hot → Cold)

- **tmpfs** en RAM (slots dédiés) pour données ultra-chaudes
- **NVMe** pour artefacts chauds persistants et images actives
- **SATA** pour archivage cold (artefacts peu consultés)
- **zRAM** (swap compressé) en priorité, swap disque en dernier filet

---

## 🧩 Principes "Proof-First"
Chaque étape doit être:
- **Reproductible**
- **Vérifiable**
- **Traçable** (logs, scripts, checks, artefacts)

---

## 🖼️ Media Vault — Gallery (11)

<div align="center">

<a href="assets/readme/gallery/LinuxIA_02.jpg"><img src="assets/readme/gallery/LinuxIA_02.jpg" width="220" alt="LinuxIA_02" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_03.jpg"><img src="assets/readme/gallery/LinuxIA_03.jpg" width="220" alt="LinuxIA_03" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_04.jpg"><img src="assets/readme/gallery/LinuxIA_04.jpg" width="220" alt="LinuxIA_04" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_05.jpg"><img src="assets/readme/gallery/LinuxIA_05.jpg" width="220" alt="LinuxIA_05" style="max-width:100%; border-radius:14px; margin:6px;"/></a>

<a href="assets/readme/gallery/LinuxIA_06.jpg"><img src="assets/readme/gallery/LinuxIA_06.jpg" width="220" alt="LinuxIA_06" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_07.jpg"><img src="assets/readme/gallery/LinuxIA_07.jpg" width="220" alt="LinuxIA_07" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_08.jpg"><img src="assets/readme/gallery/LinuxIA_08.jpg" width="220" alt="LinuxIA_08" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_09.jpg"><img src="assets/readme/gallery/LinuxIA_09.jpg" width="220" alt="LinuxIA_09" style="max-width:100%; border-radius:14px; margin:6px;"/></a>

<a href="assets/readme/gallery/LinuxIA_10.jpg"><img src="assets/readme/gallery/LinuxIA_10.jpg" width="220" alt="LinuxIA_10" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_11.jpg"><img src="assets/readme/gallery/LinuxIA_11.jpg" width="220" alt="LinuxIA_11" style="max-width:100%; border-radius:14px; margin:6px;"/></a>
<a href="assets/readme/gallery/LinuxIA_12.jpg"><img src="assets/readme/gallery/LinuxIA_12.jpg" width="220" alt="LinuxIA_12" style="max-width:100%; border-radius:14px; margin:6px;"/></a>

</div>

---

## �� Animated "Matrix Trace" (SVG micro-animation)

<div align="center">

<img src="assets/readme/matrix-trace.svg" alt="LinuxIA signals and orchestration trace" width="980"/>

</div>

---

## 🎥 Vidéos

<div align="center">

| Fichier | Description |
|---------|-------------|
| [Trailer_01.mp4](assets/readme/videos/Trailer_01.mp4) | Trailer LinuxIA #1 |
| [Trailer_02.mp4](assets/readme/videos/Trailer_02.mp4) | Trailer LinuxIA #2 |

</div>

---

## 🔊 Audio

<div align="center">

| Fichier | Description |
|---------|-------------|
| [Theme_01.mp3](assets/readme/audio/Theme_01.mp3) | Thème principal LinuxIA |

</div>

---

## 🧪 Quick Facts
- Proxmox VE (Type-1) : **KVM + LXC** sur un orchestrateur central
- Templates : **déploiement en secondes**
- Artefacts multi-niveaux : **RAM → NVMe → SATA**
- Protection mémoire : **zRAM prioritaire + quotas + isolation**
- Extensible : **workers externes** (cluster ou orchestration SSH/API)
- Philosophie : **Proof-First** (logs + checks + DoD)

---

## 📁 Convention d'assets (repo)

\`\`\`
assets/
  readme/
    gallery/     LinuxIA_02.jpg … LinuxIA_12.jpg
    videos/      Trailer_01.mp4, Trailer_02.mp4
    audio/       Theme_01.mp3
\`\`\`

---

## 🔗 Docs

- [Start here](docs/start-here.md) — prerequisites, quickstart
- [Architecture](docs/architecture.md) — Mermaid diagrams, VM topology
- [Runbook](docs/runbook.md) — troubleshooting
- [RISKS.md](RISKS.md) — risk matrix R1–R7
- [SECURITY.md](SECURITY.md) — disclosure policy
