<!--
LINUXIA_README_VNEXT_REBUILD
Thème: NASA / Proxmox / Matrix — accents orange, animations fines, propres, GitHub-safe.
-->

<div align="center">

<!-- LOGO / HERO (SVG animé, fin et léger) -->
<svg width="980" height="220" viewBox="0 0 980 220" role="img" aria-label="LinuxIA — Proof-First Agent Orchestration Framework" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#00ff9d" stop-opacity="0.18"/>
      <stop offset="0.45" stop-color="#ff7a18" stop-opacity="0.28"/>
      <stop offset="1" stop-color="#7c3aed" stop-opacity="0.16"/>
    </linearGradient>

    <linearGradient id="o" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ff7a18"/>
      <stop offset="1" stop-color="#ffb000"/>
    </linearGradient>

    <filter id="softGlow" x="-40%" y="-40%" width="180%" height="180%">
      <feGaussianBlur stdDeviation="8" result="b"/>
      <feMerge>
        <feMergeNode in="b"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>

    <pattern id="grid" width="24" height="24" patternUnits="userSpaceOnUse">
      <path d="M24 0H0V24" fill="none" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1"/>
    </pattern>

    <style>
      .t { font: 800 44px ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell, Noto Sans, Arial; letter-spacing: 1px; }
      .s { font: 500 14px ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell, Noto Sans, Arial; letter-spacing: .4px; }
      .m { font: 600 12px ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; letter-spacing: .2px; }
      .scan { animation: scan 5.2s linear infinite; }
      .orb  { animation: drift 6.5s ease-in-out infinite; }
      .dash { stroke-dasharray: 6 10; animation: dash 7s linear infinite; }
      .pulse{ animation: pulse 3.2s ease-in-out infinite; transform-origin: 50% 50%; }
      @keyframes scan { 0%{transform:translateX(-180px)} 100%{transform:translateX(1160px)} }
      @keyframes dash { to { stroke-dashoffset: -120; } }
      @keyframes drift{ 0%,100%{transform:translate(0,0)} 50%{transform:translate(10px,-6px)} }
      @keyframes pulse{ 0%,100%{opacity:.72} 50%{opacity:1} }
    </style>
  </defs>

  <!-- background -->
  <rect x="0" y="0" width="980" height="220" rx="22" fill="#0b0f14"/>
  <rect x="0" y="0" width="980" height="220" rx="22" fill="url(#g)"/>
  <rect x="0" y="0" width="980" height="220" rx="22" fill="url(#grid)"/>

  <!-- fine orbit lines -->
  <g opacity="0.85">
    <ellipse cx="720" cy="108" rx="210" ry="74" fill="none" stroke="#ffffff" stroke-opacity="0.08" stroke-width="1"/>
    <ellipse cx="720" cy="108" rx="160" ry="56" fill="none" stroke="#ffffff" stroke-opacity="0.07" stroke-width="1"/>
    <path d="M565 108 C610 50, 830 40, 880 108 C832 175, 610 168, 565 108 Z" fill="none" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1" class="dash"/>
  </g>

  <!-- drifting orb -->
  <g class="orb" filter="url(#softGlow)">
    <circle cx="820" cy="74" r="7" fill="url(#o)" opacity="0.95"/>
    <circle cx="820" cy="74" r="18" fill="none" stroke="#ff7a18" stroke-opacity="0.25" stroke-width="1"/>
  </g>

  <!-- scanning line -->
  <g class="scan">
    <rect x="0" y="30" width="140" height="160" rx="14" fill="#ffffff" opacity="0.05"/>
    <rect x="6" y="36" width="128" height="148" rx="12" fill="#ff7a18" opacity="0.06"/>
  </g>

  <!-- title -->
  <text x="54" y="92" class="t" fill="#ffffff">LINUXIA</text>
  <rect x="54" y="104" width="280" height="6" rx="3" fill="url(#o)" class="pulse" opacity="0.95"/>
  <text x="54" y="136" class="s" fill="#d8dee9" opacity="0.95">Proof-First Agent Orchestration Framework • Proxmox Multi-Layer • Low-Latency Artifact Registry</text>
  <text x="54" y="166" class="m" fill="#8b949e">Couches: 0 Hôte Proxmox → 1 VM100 Usine → 2 Outils duplicables → 3 Workers externes</text>

  <!-- corner tag -->
  <g transform="translate(772,154)">
    <rect width="178" height="44" rx="14" fill="#0b0f14" opacity="0.86" stroke="#ffffff" stroke-opacity="0.08"/>
    <text x="16" y="28" class="m" fill="#ffb000">NASA-style • ORANGE • MATRIX</text>
  </g>
</svg>

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

<svg width="980" height="140" viewBox="0 0 980 140" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="LinuxIA signals and orchestration trace">
  <defs>
    <linearGradient id="mx" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#00ff9d" stop-opacity="0.0"/>
      <stop offset="0.25" stop-color="#00ff9d" stop-opacity="0.55"/>
      <stop offset="0.65" stop-color="#ff7a18" stop-opacity="0.60"/>
      <stop offset="1" stop-color="#ff7a18" stop-opacity="0.0"/>
    </linearGradient>
    <style>
      .wire { fill: none; stroke: #ffffff; stroke-opacity: .10; stroke-width: 1; }
      .flow { fill: none; stroke: url(#mx); stroke-width: 2; stroke-linecap: round; stroke-dasharray: 40 940; animation: f 3.4s linear infinite; }
      .dot  { fill: #ff7a18; opacity: .9; animation: p 1.6s ease-in-out infinite; transform-origin: 50% 50%; }
      .lbl  { font: 600 12px ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; fill: #c9d1d9; opacity: .85; }
      @keyframes f { from { stroke-dashoffset: 980; } to { stroke-dashoffset: 0; } }
      @keyframes p { 0%,100% { transform: scale(1); opacity:.55 } 50% { transform: scale(1.2); opacity:1 } }
    </style>
  </defs>

  <rect x="0" y="0" width="980" height="140" rx="18" fill="#0b0f14"/>
  <path class="wire" d="M60 70 C210 20, 320 20, 420 70 C520 120, 620 120, 740 70 C860 20, 910 40, 940 70"/>
  <path class="flow" d="M60 70 C210 20, 320 20, 420 70 C520 120, 620 120, 740 70 C860 20, 910 40, 940 70"/>

  <circle class="dot" cx="60" cy="70" r="4"/>
  <circle class="dot" cx="420" cy="70" r="4" style="animation-delay:.25s"/>
  <circle class="dot" cx="740" cy="70" r="4" style="animation-delay:.5s"/>
  <circle class="dot" cx="940" cy="70" r="4" style="animation-delay:.75s"/>

  <text class="lbl" x="44" y="28">L0: Proxmox</text>
  <text class="lbl" x="392" y="28">L1: VM100 Usine</text>
  <text class="lbl" x="700" y="28">L2: Outils</text>
  <text class="lbl" x="898" y="28">L3: Workers</text>

  <text class="lbl" x="44" y="120" opacity=".75">RAM tmpfs → NVMe → SATA • zRAM • Templates • Agents • Logs</text>
</svg>

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
