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

## 🎬 Galerie d'animations cinématiques (12 SVG)

<div align="center">

### 1 — Orbital Infrastructure

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Orbital Infrastructure">
  <defs>
    <radialGradient id="oi-hub" cx="50%" cy="50%" r="50%">
      <stop offset="0" stop-color="#ff7a18" stop-opacity="0.9"/>
      <stop offset="1" stop-color="#ff7a18" stop-opacity="0"/>
    </radialGradient>
    <style>
      .oi-orb{animation:oi-spin 8s linear infinite;transform-origin:490px 80px}
      .oi-orb2{animation:oi-spin 12s linear infinite reverse;transform-origin:490px 80px}
      .oi-dot{animation:oi-pulse 2.4s ease-in-out infinite}
      @keyframes oi-spin{to{transform:rotate(360deg)}}
      @keyframes oi-pulse{0%,100%{opacity:.6}50%{opacity:1}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <ellipse cx="490" cy="80" rx="340" ry="52" fill="none" stroke="#ffffff" stroke-opacity=".07" stroke-width="1"/>
  <ellipse cx="490" cy="80" rx="220" ry="36" fill="none" stroke="#ffffff" stroke-opacity=".07" stroke-width="1"/>
  <ellipse cx="490" cy="80" rx="120" ry="22" fill="none" stroke="#ffffff" stroke-opacity=".09" stroke-width="1"/>
  <circle cx="490" cy="80" r="14" fill="url(#oi-hub)" class="oi-dot"/>
  <circle cx="490" cy="80" r="6" fill="#ff7a18"/>
  <g class="oi-orb"><circle cx="830" cy="80" r="7" fill="#00ff9d" opacity=".9"/></g>
  <g class="oi-orb2"><circle cx="270" cy="44" r="5" fill="#7c3aed" opacity=".9"/></g>
  <g class="oi-orb" style="animation-duration:5s"><circle cx="610" cy="58" r="4" fill="#ffb000" opacity=".85"/></g>
  <text x="490" y="134" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">Proxmox Core — VM100 · VM101 · VM102 · Workers Orbit</text>
</svg>

### 2 — Data Flow Pipeline

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Data Flow Pipeline">
  <defs>
    <linearGradient id="df-flow" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#00ff9d" stop-opacity="0"/>
      <stop offset="0.3" stop-color="#00ff9d" stop-opacity=".8"/>
      <stop offset="0.7" stop-color="#ff7a18" stop-opacity=".8"/>
      <stop offset="1" stop-color="#ff7a18" stop-opacity="0"/>
    </linearGradient>
    <style>
      .df-pkt{animation:df-move 3.2s linear infinite}
      .df-pkt2{animation:df-move 3.2s linear infinite;animation-delay:1.6s}
      @keyframes df-move{0%{transform:translateX(-140px)}100%{transform:translateX(1120px)}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <line x1="40" y1="80" x2="940" y2="80" stroke="#ffffff" stroke-opacity=".08" stroke-width="2"/>
  <rect x="40" y="60" width="80" height="40" rx="8" fill="#0b0f14" stroke="#00ff9d" stroke-opacity=".6" stroke-width="1.5"/>
  <rect x="220" y="60" width="80" height="40" rx="8" fill="#0b0f14" stroke="#00ff9d" stroke-opacity=".5" stroke-width="1.5"/>
  <rect x="400" y="60" width="80" height="40" rx="8" fill="#0b0f14" stroke="#ff7a18" stroke-opacity=".7" stroke-width="1.5"/>
  <rect x="580" y="60" width="80" height="40" rx="8" fill="#0b0f14" stroke="#ff7a18" stroke-opacity=".6" stroke-width="1.5"/>
  <rect x="760" y="60" width="80" height="40" rx="8" fill="#0b0f14" stroke="#7c3aed" stroke-opacity=".7" stroke-width="1.5"/>
  <text x="80" y="85" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#00ff9d">INPUT</text>
  <text x="260" y="85" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#00ff9d">PARSE</text>
  <text x="440" y="85" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ff7a18">EXEC</text>
  <text x="620" y="85" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ff7a18">VERIFY</text>
  <text x="800" y="85" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#7c3aed">STORE</text>
  <g class="df-pkt"><rect x="120" y="76" width="28" height="8" rx="4" fill="url(#df-flow)"/></g>
  <g class="df-pkt2"><rect x="120" y="76" width="28" height="8" rx="4" fill="url(#df-flow)"/></g>
  <text x="490" y="134" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">Artifacts: RAM tmpfs → NVMe hot → SATA cold</text>
</svg>

### 3 — Matrix Code Rain

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Matrix Code Rain">
  <defs>
    <style>
      .mc-col{font:bold 11px ui-monospace,monospace;fill:#00ff9d}
      .mc-c1{animation:mc-fall1 4s linear infinite}
      .mc-c2{animation:mc-fall2 3.2s linear infinite;animation-delay:.8s}
      .mc-c3{animation:mc-fall3 5s linear infinite;animation-delay:1.6s}
      .mc-c4{animation:mc-fall4 3.8s linear infinite;animation-delay:.4s}
      .mc-c5{animation:mc-fall5 4.4s linear infinite;animation-delay:2s}
      @keyframes mc-fall1{0%{transform:translateY(-120px)}100%{transform:translateY(280px)}}
      @keyframes mc-fall2{0%{transform:translateY(-120px)}100%{transform:translateY(280px)}}
      @keyframes mc-fall3{0%{transform:translateY(-120px)}100%{transform:translateY(280px)}}
      @keyframes mc-fall4{0%{transform:translateY(-120px)}100%{transform:translateY(280px)}}
      @keyframes mc-fall5{0%{transform:translateY(-120px)}100%{transform:translateY(280px)}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <clipPath id="mc-clip"><rect width="980" height="160" rx="16"/></clipPath>
  <g clip-path="url(#mc-clip)">
    <g class="mc-c1 mc-col" opacity=".9"><text x="60">1</text><text x="60" y="16">0</text><text x="60" y="32">1</text><text x="60" y="48">L</text><text x="60" y="64">I</text><text x="60" y="80">N</text><text x="60" y="96" fill="#ffffff" font-weight="900">X</text></g>
    <g class="mc-c2 mc-col" opacity=".7"><text x="140">P</text><text x="140" y="16">R</text><text x="140" y="32">O</text><text x="140" y="48">X</text><text x="140" y="64" fill="#ff7a18" font-weight="900">M</text><text x="140" y="80">O</text><text x="140" y="96">X</text></g>
    <g class="mc-c3 mc-col" opacity=".8"><text x="260">A</text><text x="260" y="16">G</text><text x="260" y="32">E</text><text x="260" y="48" fill="#ffb000" font-weight="900">N</text><text x="260" y="64">T</text><text x="260" y="80">0</text><text x="260" y="96">1</text></g>
    <g class="mc-c4 mc-col" opacity=".6"><text x="380">V</text><text x="380" y="16">M</text><text x="380" y="32">1</text><text x="380" y="48">0</text><text x="380" y="64" fill="#00ff9d" font-weight="900">0</text><text x="380" y="80">1</text><text x="380" y="96">0</text></g>
    <g class="mc-c5 mc-col" opacity=".75"><text x="500">P</text><text x="500" y="16">R</text><text x="500" y="32">O</text><text x="500" y="48">O</text><text x="500" y="64" fill="#7c3aed" font-weight="900">F</text><text x="500" y="80">0</text><text x="500" y="96">1</text></g>
    <g class="mc-c1 mc-col" opacity=".5" style="animation-delay:2.2s"><text x="620">N</text><text x="620" y="16">V</text><text x="620" y="32">M</text><text x="620" y="48">e</text><text x="620" y="64" fill="#00ff9d" font-weight="900">→</text><text x="620" y="80">S</text><text x="620" y="96">A</text></g>
    <g class="mc-c3 mc-col" opacity=".65" style="animation-delay:3.1s"><text x="740">G</text><text x="740" y="16">P</text><text x="740" y="32">U</text><text x="740" y="48">B</text><text x="740" y="64" fill="#ff7a18" font-weight="900">7</text><text x="740" y="80">P</text><text x="740" y="96">r</text></g>
    <g class="mc-c2 mc-col" opacity=".55" style="animation-delay:1.1s"><text x="860">D</text><text x="860" y="16">O</text><text x="860" y="32">D</text><text x="860" y="48">✓</text><text x="860" y="64" fill="#00ff9d" font-weight="900">✓</text><text x="860" y="80">✓</text><text x="860" y="96">✓</text></g>
  </g>
  <text x="490" y="150" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#00ff9d" opacity=".6">LinuxIA Matrix — Proof-First · Every byte traced</text>
</svg>

### 4 — Network Topology

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Network Topology">
  <defs>
    <style>
      .nt-edge{stroke:#ffffff;stroke-opacity:.12;stroke-width:1.5;fill:none}
      .nt-active{stroke:#00ff9d;stroke-opacity:.5;stroke-width:1.5;fill:none;stroke-dasharray:6 8;animation:nt-dash 3s linear infinite}
      .nt-node{animation:nt-pulse 2.8s ease-in-out infinite}
      @keyframes nt-dash{to{stroke-dashoffset:-28}}
      @keyframes nt-pulse{0%,100%{opacity:.8}50%{opacity:1}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- edges -->
  <line class="nt-edge" x1="490" y1="80" x2="160" y2="55"/>
  <line class="nt-edge" x1="490" y1="80" x2="160" y2="110"/>
  <line class="nt-active" x1="490" y1="80" x2="340" y2="55"/>
  <line class="nt-active" x1="490" y1="80" x2="340" y2="110"/>
  <line class="nt-edge" x1="490" y1="80" x2="640" y2="55"/>
  <line class="nt-edge" x1="490" y1="80" x2="640" y2="110"/>
  <line class="nt-active" x1="490" y1="80" x2="820" y2="80" style="animation-delay:.8s"/>
  <!-- central Proxmox node -->
  <circle class="nt-node" cx="490" cy="80" r="18" fill="#0b0f14" stroke="#ff7a18" stroke-width="2"/>
  <text x="490" y="84" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ff7a18">PVE</text>
  <!-- VMs -->
  <circle cx="160" cy="55" r="12" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="160" y="59" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#00ff9d">L0</text>
  <circle cx="160" cy="110" r="12" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="160" y="114" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#00ff9d">LXC</text>
  <circle cx="340" cy="55" r="12" fill="#0b0f14" stroke="#ffb000" stroke-width="1.5"/>
  <text x="340" y="59" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#ffb000">V100</text>
  <circle cx="340" cy="110" r="12" fill="#0b0f14" stroke="#ffb000" stroke-width="1.5"/>
  <text x="340" y="114" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#ffb000">V101</text>
  <circle cx="640" cy="55" r="12" fill="#0b0f14" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="640" y="59" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#7c3aed">V102</text>
  <circle cx="640" cy="110" r="12" fill="#0b0f14" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="640" y="114" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#7c3aed">V103</text>
  <circle cx="820" cy="80" r="12" fill="#0b0f14" stroke="#ffffff" stroke-width="1.5" stroke-opacity=".5"/>
  <text x="820" y="84" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">WRK</text>
  <text x="490" y="148" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">192.168.1.128 (PVE) → .135 (VM100) · .136 · .137 · Workers</text>
</svg>

### 5 — Thermal Storage Layers

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Thermal Storage Layers">
  <defs>
    <linearGradient id="ts-hot" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ff4500"/>
      <stop offset="1" stop-color="#ff7a18"/>
    </linearGradient>
    <linearGradient id="ts-warm" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ffb000"/>
      <stop offset="1" stop-color="#ffd700" stop-opacity=".7"/>
    </linearGradient>
    <linearGradient id="ts-cold" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#00b3ff"/>
      <stop offset="1" stop-color="#00ff9d" stop-opacity=".6"/>
    </linearGradient>
    <style>
      .ts-bar{animation:ts-glow 3s ease-in-out infinite}
      @keyframes ts-glow{0%,100%{opacity:.8}50%{opacity:1}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- Layer labels -->
  <text x="30" y="42" font-size="11" font-family="ui-monospace,monospace" fill="#ff4500">ULTRA-HOT</text>
  <text x="30" y="82" font-size="11" font-family="ui-monospace,monospace" fill="#ffb000">HOT</text>
  <text x="30" y="122" font-size="11" font-family="ui-monospace,monospace" fill="#00b3ff">COLD</text>
  <!-- Bars -->
  <rect x="130" y="26" width="520" height="24" rx="6" fill="url(#ts-hot)" class="ts-bar"/>
  <text x="660" y="43" font-size="10" font-family="ui-monospace,monospace" fill="#ff7a18"> tmpfs RAM (ultra-hot, slots dédiés)</text>
  <rect x="130" y="66" width="380" height="24" rx="6" fill="url(#ts-warm)" class="ts-bar" style="animation-delay:.6s"/>
  <text x="520" y="83" font-size="10" font-family="ui-monospace,monospace" fill="#ffb000"> NVMe (artefacts chauds persistants)</text>
  <rect x="130" y="106" width="240" height="24" rx="6" fill="url(#ts-cold)" class="ts-bar" style="animation-delay:1.2s"/>
  <text x="380" y="123" font-size="10" font-family="ui-monospace,monospace" fill="#00b3ff"> SATA (archivage cold, peu consulté)</text>
  <text x="490" y="152" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">zRAM (swap compressé prioritaire) → swap disque en dernier filet</text>
</svg>

### 6 — Systemd Orchestration

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Systemd Orchestration">
  <defs>
    <style>
      .so-edge{stroke:#ffffff;stroke-opacity:.15;stroke-width:1.5;fill:none;marker-end:url(#so-arr)}
      .so-box{rx:7}
      .so-pulse{animation:so-pulse 2.5s ease-in-out infinite}
      @keyframes so-pulse{0%,100%{opacity:.75}50%{opacity:1}}
    </style>
    <marker id="so-arr" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
      <path d="M0,0 L0,6 L6,3 z" fill="#ffffff" opacity=".3"/>
    </marker>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- Timer → Script boxes + arrows -->
  <rect x="30" y="55" width="110" height="34" class="so-box" fill="#0b0f14" stroke="#ff7a18" stroke-width="1.5"/>
  <text x="85" y="77" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ff7a18">linuxia.timer</text>
  <line class="so-edge" x1="140" y1="72" x2="200" y2="72"/>
  <rect x="200" y="55" width="120" height="34" class="so-box so-pulse" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="260" y="77" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#00ff9d">healthcheck.sh</text>
  <line class="so-edge" x1="320" y1="72" x2="380" y2="72"/>
  <rect x="380" y="55" width="110" height="34" class="so-box" fill="#0b0f14" stroke="#ffb000" stroke-width="1.5"/>
  <text x="435" y="77" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ffb000">verify.sh</text>
  <line class="so-edge" x1="490" y1="72" x2="550" y2="72"/>
  <rect x="550" y="55" width="110" height="34" class="so-box" fill="#0b0f14" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="605" y="77" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#7c3aed">log → proof</text>
  <line class="so-edge" x1="660" y1="72" x2="720" y2="72"/>
  <rect x="720" y="55" width="110" height="34" class="so-box" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="775" y="77" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#00ff9d">artifact store</text>
  <line class="so-edge" x1="830" y1="72" x2="890" y2="72"/>
  <rect x="890" y="55" width="70" height="34" class="so-box" fill="#0b0f14" stroke="#ff7a18" stroke-width="1.5"/>
  <text x="925" y="77" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ff7a18">DoD ✓</text>
  <text x="490" y="134" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">systemd timers → scripts → logs append-only → artifacts → DoD</text>
</svg>

### 7 — Proof-First CI Pipeline

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Proof-First CI Pipeline">
  <defs>
    <linearGradient id="ci-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#00ff9d" stop-opacity=".15"/>
      <stop offset="1" stop-color="#ff7a18" stop-opacity=".15"/>
    </linearGradient>
    <style>
      .ci-step{animation:ci-light 4s ease-in-out infinite}
      .ci-s1{animation-delay:0s}
      .ci-s2{animation-delay:.7s}
      .ci-s3{animation-delay:1.4s}
      .ci-s4{animation-delay:2.1s}
      .ci-s5{animation-delay:2.8s}
      @keyframes ci-light{0%,80%,100%{opacity:.55}40%{opacity:1}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <rect x="0" y="0" width="980" height="160" rx="16" fill="url(#ci-grad)"/>
  <!-- Pipeline track -->
  <line x1="60" y1="80" x2="920" y2="80" stroke="#ffffff" stroke-opacity=".1" stroke-width="2"/>
  <!-- Steps -->
  <g class="ci-step ci-s1">
    <circle cx="110" cy="80" r="22" fill="#0b0f14" stroke="#00ff9d" stroke-width="2"/>
    <text x="110" y="76" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#00ff9d">CODE</text>
    <text x="110" y="88" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#00ff9d">PUSH</text>
  </g>
  <g class="ci-step ci-s2">
    <circle cx="280" cy="80" r="22" fill="#0b0f14" stroke="#ffb000" stroke-width="2"/>
    <text x="280" y="76" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ffb000">BUILD</text>
    <text x="280" y="88" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ffb000">TEST</text>
  </g>
  <g class="ci-step ci-s3">
    <circle cx="450" cy="80" r="22" fill="#0b0f14" stroke="#ff7a18" stroke-width="2"/>
    <text x="450" y="76" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ff7a18">PROOF</text>
    <text x="450" y="88" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ff7a18">LOG</text>
  </g>
  <g class="ci-step ci-s4">
    <circle cx="620" cy="80" r="22" fill="#0b0f14" stroke="#7c3aed" stroke-width="2"/>
    <text x="620" y="76" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#7c3aed">ARTI</text>
    <text x="620" y="88" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#7c3aed">FACT</text>
  </g>
  <g class="ci-step ci-s5">
    <circle cx="790" cy="80" r="22" fill="#0b0f14" stroke="#00ff9d" stroke-width="2"/>
    <text x="790" y="76" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#00ff9d">DoD</text>
    <text x="790" y="88" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#00ff9d">✓✓✓</text>
  </g>
  <text x="490" y="138" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">GitHub Actions → scripts/ci.sh → logs/proof → artifacts → DoD gate</text>
</svg>

### 8 — GPU Compute Acceleration

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="GPU Compute Acceleration">
  <defs>
    <style>
      .gpu-core{animation:gpu-flash 1.8s ease-in-out infinite}
      .gpu-c1{animation-delay:0s}
      .gpu-c2{animation-delay:.15s}
      .gpu-c3{animation-delay:.3s}
      .gpu-c4{animation-delay:.45s}
      .gpu-c5{animation-delay:.6s}
      .gpu-c6{animation-delay:.75s}
      .gpu-c7{animation-delay:.9s}
      .gpu-c8{animation-delay:1.05s}
      @keyframes gpu-flash{0%,100%{opacity:.3}50%{opacity:.9}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <text x="60" y="50" font-size="12" font-family="ui-monospace,monospace" fill="#ff7a18">NVIDIA GTX 1080</text>
  <text x="60" y="68" font-size="10" font-family="ui-monospace,monospace" fill="#8b949e">PandaMiner B7Pro</text>
  <!-- GPU core grid -->
  <g transform="translate(280,20)">
    <rect class="gpu-core gpu-c1" x="0" y="0" width="28" height="28" rx="4" fill="#7c3aed" opacity=".4"/>
    <rect class="gpu-core gpu-c2" x="34" y="0" width="28" height="28" rx="4" fill="#7c3aed" opacity=".4"/>
    <rect class="gpu-core gpu-c3" x="68" y="0" width="28" height="28" rx="4" fill="#7c3aed" opacity=".4"/>
    <rect class="gpu-core gpu-c4" x="102" y="0" width="28" height="28" rx="4" fill="#7c3aed" opacity=".4"/>
    <rect class="gpu-core gpu-c5" x="0" y="34" width="28" height="28" rx="4" fill="#ff7a18" opacity=".4"/>
    <rect class="gpu-core gpu-c6" x="34" y="34" width="28" height="28" rx="4" fill="#ff7a18" opacity=".4"/>
    <rect class="gpu-core gpu-c7" x="68" y="34" width="28" height="28" rx="4" fill="#ff7a18" opacity=".4"/>
    <rect class="gpu-core gpu-c8" x="102" y="34" width="28" height="28" rx="4" fill="#ff7a18" opacity=".4"/>
    <rect class="gpu-core gpu-c1" x="0" y="68" width="28" height="28" rx="4" fill="#00ff9d" opacity=".4"/>
    <rect class="gpu-core gpu-c3" x="34" y="68" width="28" height="28" rx="4" fill="#00ff9d" opacity=".4"/>
    <rect class="gpu-core gpu-c5" x="68" y="68" width="28" height="28" rx="4" fill="#00ff9d" opacity=".4"/>
    <rect class="gpu-core gpu-c7" x="102" y="68" width="28" height="28" rx="4" fill="#00ff9d" opacity=".4"/>
  </g>
  <text x="580" y="42" font-size="12" font-family="ui-monospace,monospace" fill="#7c3aed">CUDA Cores</text>
  <text x="580" y="60" font-size="10" font-family="ui-monospace,monospace" fill="#8b949e">passthrough PCIe</text>
  <text x="580" y="78" font-size="10" font-family="ui-monospace,monospace" fill="#8b949e">VM102 GPU worker</text>
  <text x="580" y="96" font-size="10" font-family="ui-monospace,monospace" fill="#8b949e">quota: 80% max</text>
  <text x="490" y="148" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">GPU passthrough KVM → jobs lourds externalisés → quotas stricts PandaMiner</text>
</svg>

### 9 — Event Sourcing Architecture

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Event Sourcing Architecture">
  <defs>
    <style>
      .es-evt{animation:es-pop 5s ease-in-out infinite}
      .es-e1{animation-delay:0s}
      .es-e2{animation-delay:1s}
      .es-e3{animation-delay:2s}
      .es-e4{animation-delay:3s}
      .es-e5{animation-delay:4s}
      @keyframes es-pop{0%,90%,100%{transform:scaleY(.6);opacity:.4}10%,80%{transform:scaleY(1);opacity:1}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- Timeline axis -->
  <line x1="60" y1="110" x2="920" y2="110" stroke="#ffffff" stroke-opacity=".15" stroke-width="1.5"/>
  <!-- Events -->
  <g class="es-evt es-e1" transform-origin="150px 110px">
    <rect x="130" y="60" width="40" height="50" rx="4" fill="#ff7a18" opacity=".6"/>
    <text x="150" y="132" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">BOOT</text>
  </g>
  <g class="es-evt es-e2" transform-origin="270px 110px">
    <rect x="250" y="50" width="40" height="60" rx="4" fill="#00ff9d" opacity=".6"/>
    <text x="270" y="132" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">AGENT</text>
  </g>
  <g class="es-evt es-e3" transform-origin="420px 110px">
    <rect x="400" y="40" width="40" height="70" rx="4" fill="#ffb000" opacity=".6"/>
    <text x="420" y="132" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">JOB</text>
  </g>
  <g class="es-evt es-e4" transform-origin="570px 110px">
    <rect x="550" y="55" width="40" height="55" rx="4" fill="#7c3aed" opacity=".6"/>
    <text x="570" y="132" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">LOG</text>
  </g>
  <g class="es-evt es-e5" transform-origin="720px 110px">
    <rect x="700" y="45" width="40" height="65" rx="4" fill="#00ff9d" opacity=".6"/>
    <text x="720" y="132" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">PROOF</text>
  </g>
  <rect x="860" y="65" width="40" height="45" rx="4" fill="#ff7a18" opacity=".5"/>
  <text x="880" y="132" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">DoD</text>
  <text x="490" y="152" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">Event log append-only · chaque action = preuve horodatée · replay possible</text>
</svg>

### 10 — Multi-Node Cluster

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Multi-Node Cluster">
  <defs>
    <style>
      .mn-sync{stroke-dasharray:6 8;animation:mn-dash 2.5s linear infinite}
      .mn-sync2{stroke-dasharray:6 8;animation:mn-dash 2.5s linear infinite;animation-delay:1.25s}
      @keyframes mn-dash{to{stroke-dashoffset:-28}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- Cluster nodes -->
  <rect x="40" y="45" width="100" height="70" rx="10" fill="#0b0f14" stroke="#ff7a18" stroke-width="2"/>
  <text x="90" y="70" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ff7a18">Proxmox</text>
  <text x="90" y="85" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">192.168.1.128</text>
  <text x="90" y="100" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">master</text>
  <line class="mn-sync" x1="140" y1="80" x2="220" y2="80" stroke="#00ff9d" stroke-width="1.5" fill="none"/>
  <rect x="220" y="45" width="100" height="70" rx="10" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="270" y="70" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#00ff9d">VM100</text>
  <text x="270" y="85" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">.135 Usine</text>
  <line class="mn-sync2" x1="320" y1="80" x2="400" y2="80" stroke="#ffb000" stroke-width="1.5" fill="none"/>
  <rect x="400" y="45" width="100" height="70" rx="10" fill="#0b0f14" stroke="#ffb000" stroke-width="1.5"/>
  <text x="450" y="70" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#ffb000">VM101</text>
  <text x="450" y="85" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">.136 Layer2</text>
  <line class="mn-sync" x1="500" y1="80" x2="580" y2="80" stroke="#7c3aed" stroke-width="1.5" fill="none"/>
  <rect x="580" y="45" width="100" height="70" rx="10" fill="#0b0f14" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="630" y="70" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#7c3aed">VM102</text>
  <text x="630" y="85" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">.137 Tools</text>
  <line class="mn-sync2" x1="680" y1="80" x2="760" y2="80" stroke="#8b949e" stroke-width="1.5" fill="none"/>
  <rect x="760" y="45" width="100" height="70" rx="10" fill="#0b0f14" stroke="#8b949e" stroke-width="1.5"/>
  <text x="810" y="70" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#8b949e">Workers</text>
  <text x="810" y="85" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#8b949e">externes</text>
  <text x="490" y="150" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">Cluster Proxmox · pacemaker/SSH/API · tolérance aux pannes · scale-out</text>
</svg>

### 11 — Snapshot Timeline

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Snapshot Timeline">
  <defs>
    <style>
      .sn-snap{animation:sn-appear 6s ease-in-out infinite}
      .sn-s1{animation-delay:0s}
      .sn-s2{animation-delay:1s}
      .sn-s3{animation-delay:2s}
      .sn-s4{animation-delay:3s}
      .sn-s5{animation-delay:4s}
      @keyframes sn-appear{0%,100%{opacity:.4}20%,80%{opacity:1}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- Timeline -->
  <line x1="60" y1="80" x2="920" y2="80" stroke="#ffffff" stroke-opacity=".12" stroke-width="2"/>
  <!-- Snapshot points -->
  <g class="sn-snap sn-s1">
    <circle cx="140" cy="80" r="8" fill="#ff7a18"/>
    <line x1="140" y1="72" x2="140" y2="40" stroke="#ff7a18" stroke-opacity=".5" stroke-width="1"/>
    <text x="140" y="35" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ff7a18">snap-001</text>
    <text x="140" y="105" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">baseline</text>
  </g>
  <g class="sn-snap sn-s2">
    <circle cx="300" cy="80" r="8" fill="#00ff9d"/>
    <line x1="300" y1="72" x2="300" y2="40" stroke="#00ff9d" stroke-opacity=".5" stroke-width="1"/>
    <text x="300" y="35" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#00ff9d">snap-002</text>
    <text x="300" y="105" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">post-deploy</text>
  </g>
  <g class="sn-snap sn-s3">
    <circle cx="460" cy="80" r="8" fill="#ffb000"/>
    <line x1="460" y1="72" x2="460" y2="40" stroke="#ffb000" stroke-opacity=".5" stroke-width="1"/>
    <text x="460" y="35" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ffb000">snap-003</text>
    <text x="460" y="105" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">pre-update</text>
  </g>
  <g class="sn-snap sn-s4">
    <circle cx="640" cy="80" r="8" fill="#7c3aed"/>
    <line x1="640" y1="72" x2="640" y2="40" stroke="#7c3aed" stroke-opacity=".5" stroke-width="1"/>
    <text x="640" y="35" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#7c3aed">snap-004</text>
    <text x="640" y="105" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">stable✓</text>
  </g>
  <g class="sn-snap sn-s5">
    <circle cx="820" cy="80" r="8" fill="#00ff9d"/>
    <line x1="820" y1="72" x2="820" y2="40" stroke="#00ff9d" stroke-opacity=".5" stroke-width="1"/>
    <text x="820" y="35" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#00ff9d">snap-005</text>
    <text x="820" y="105" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#8b949e">rollback✓</text>
  </g>
  <text x="490" y="150" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">Btrfs/ZFS snapshots · rollback instantané · historique versionné</text>
</svg>

### 12 — Agent Ecosystem

<svg width="980" height="160" viewBox="0 0 980 160" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Agent Ecosystem">
  <defs>
    <style>
      .ae-msg{animation:ae-fly 3.6s linear infinite}
      .ae-m2{animation:ae-fly 3.6s linear infinite;animation-delay:1.2s}
      .ae-m3{animation:ae-fly 3.6s linear infinite;animation-delay:2.4s}
      .ae-agent{animation:ae-hb 2.2s ease-in-out infinite}
      @keyframes ae-fly{0%{opacity:0;transform:scale(.5)}20%,80%{opacity:1;transform:scale(1)}100%{opacity:0}}
      @keyframes ae-hb{0%,100%{transform:scale(1)}50%{transform:scale(1.06)}}
    </style>
  </defs>
  <rect width="980" height="160" rx="16" fill="#0b0f14"/>
  <!-- Central orchestrator -->
  <g class="ae-agent" style="transform-origin:490px 80px">
    <circle cx="490" cy="80" r="22" fill="#0b0f14" stroke="#ff7a18" stroke-width="2.5"/>
    <text x="490" y="76" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ff7a18">ORCH</text>
    <text x="490" y="88" text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#ff7a18">VM100</text>
  </g>
  <!-- Spoke agents -->
  <line x1="468" y1="80" x2="200" y2="55" stroke="#00ff9d" stroke-opacity=".2" stroke-width="1"/>
  <circle cx="175" cy="50" r="16" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="175" y="54" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#00ff9d">Agent-A</text>
  <line x1="468" y1="80" x2="200" y2="110" stroke="#00ff9d" stroke-opacity=".2" stroke-width="1"/>
  <circle cx="175" cy="115" r="16" fill="#0b0f14" stroke="#00ff9d" stroke-width="1.5"/>
  <text x="175" y="119" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#00ff9d">Agent-B</text>
  <line x1="512" y1="80" x2="780" y2="55" stroke="#7c3aed" stroke-opacity=".2" stroke-width="1"/>
  <circle cx="805" cy="50" r="16" fill="#0b0f14" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="805" y="54" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#7c3aed">GPU-W</text>
  <line x1="512" y1="80" x2="780" y2="110" stroke="#7c3aed" stroke-opacity=".2" stroke-width="1"/>
  <circle cx="805" cy="115" r="16" fill="#0b0f14" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="805" y="119" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#7c3aed">Panda</text>
  <!-- Message packets -->
  <g class="ae-msg"><circle cx="330" cy="62" r="4" fill="#00ff9d"/></g>
  <g class="ae-m2"><circle cx="330" cy="98" r="4" fill="#00ff9d"/></g>
  <g class="ae-m3"><circle cx="645" cy="62" r="4" fill="#7c3aed"/></g>
  <text x="490" y="150" text-anchor="middle" font-size="11" font-family="ui-monospace,monospace" fill="#8b949e">Agents autonomes · messages structurés · orchestrateur central VM100</text>
</svg>

</div>

---

## 🖥️ Virtualisation &amp; isolation

LinuxIA tire parti des capacités natives de **Proxmox VE** pour garantir une isolation forte entre les charges de travail :

### KVM (Kernel-based Virtual Machine)
- Isolation matérielle complète — chaque VM dispose de ses propres vCPUs, RAM allouée et espace disque
- **Passthrough PCIe** pour les GPU (GTX 1080 → VM102 GPU worker)
- Snapshots cohérents à chaud (live snapshots Proxmox)
- Templates reproductibles : clone → deploy → destroy en secondes

### LXC (Linux Containers)
- Isolation au niveau OS — espace de noms, cgroups v2, seccomp
- Densité élevée : plusieurs LXC par hôte physique
- Parfait pour les services légers (proxy, monitoring, agents sans GPU)

### Stratégie d'isolation
| Composant | Type | Isolation | Usage |
|-----------|------|-----------|-------|
| VM100 Usine | KVM | Forte | Factory, scripts, pipelines |
| VM101 Analyse | KVM | Forte | Tests, divergence, critique |
| VM102 Outils | KVM | Forte | GPU passthrough, exécution lourde |
| LXC services | LXC | Moyenne | Services légers, agents |
| PandaMiner | externe | SSH/API | Jobs GPU déportés |

---

## 📂 Système de fichiers (Btrfs / ZFS)

### Btrfs — Copy-on-Write natif
- **Snapshots instantanés** : `btrfs subvolume snapshot` → rollback en secondes
- Compression transparente : `zstd` (ratio 2-4x, faible overhead CPU)
- RAID logiciel intégré (RAID1/5/6 natif)
- Envoi/réception incrémentiel : `btrfs send | btrfs receive` pour backup/réplication

### ZFS — Enterprise-grade (optionnel)
- ARC (Adaptive Replacement Cache) en RAM pour lecture ultra-rapide
- L2ARC sur NVMe pour cache secondaire
- ZVOL pour stockage blocs des VMs KVM
- `zfs send/recv` pour snapshots réplicables à distance

### Arborescence type
```
/opt/linuxia/          ← subvolume Btrfs (snapshots automatiques)
  .snapshots/          ← snapshots horodatés
  data/                ← données persistantes
  logs/                ← preuves append-only
  artifacts/           ← artefacts buildés
/mnt/nvme/             ← NVMe tier chaud
/mnt/sata/             ← SATA tier cold
```

---

## 📊 Journalisation &amp; observabilité

La philosophie Proof-First exige que **chaque action soit tracée et vérifiable** :

### Stack de logs
- **journald** (systemd) : logs structurés système, rotation automatique
- **Fichiers append-only** dans `logs/health/` et `logs/reports/` : écriture séquentielle, jamais de modification
- **JSONL** (JSON Lines) pour les événements machine → parseable, diffable

### Métriques & alertes
- `linuxia-healthcheck.sh` : vérification périodique (timer systemd toutes les 5 min)
- Sorties : `OK`, `WARN`, `CRIT` avec timestamps ISO 8601
- Seuils RAM/CPU/IO → alertes préventives avant saturation

### Observabilité distribuée
```bash
# Exemple de log proof structuré
{"ts":"2025-06-30T22:00:01Z","host":"VM100","check":"ram_pressure","status":"OK","free_mb":4096,"zram_mb":2048}
{"ts":"2025-06-30T22:00:02Z","host":"VM100","check":"nvme_io","status":"OK","iops":42000,"lat_ms":0.8}
```

### Rétention
| Tier | Durée | Stockage |
|------|-------|----------|
| Logs temps-réel | 7 jours | tmpfs / NVMe |
| Logs agrégés | 90 jours | SATA cold |
| Snapshots | rolling-7 | Btrfs auto |

---

## 🤖 Agents &amp; orchestration (détail)

### Architecture des agents
Chaque agent LinuxIA est un script shell versionné qui respecte le contrat :

```
TASK → CONTEXT → CONSTRAINTS → DONE_CRITERIA
  ↓
EXECUTE (avec dry-run par défaut)
  ↓
RESULT + EVIDENCE + RISKS + NEXT
```

### Types d'agents
| Agent | Rôle | Machine |
|-------|------|---------|
| `linuxia-orchestrator` | Coordinateur principal | VM100 |
| `linuxia-healthcheck` | Vérification continue | VM100 |
| `linuxia-artifact-push` | Publication artefacts | VM100 |
| `linuxia-gpu-worker` | Jobs CUDA | VM102 / PandaMiner |
| `linuxia-snapshot` | Gestion snapshots | Proxmox |
| `linuxia-report` | Rapports DoD | VM100 → GitHub |

### Macros (contrat CODEX)
Chaque comportement complexe est une **macro versionnée** dans `macros/` :
- `VERSION`, `INPUT_SCHEMA`, `OUTPUT_SCHEMA`, `ALLOWLIST`, `RISKS`, `EVIDENCE_REQUIRED`
- Pipeline : `PLAN → EXECUTE → VERIFY → CRITIQUE → LOG_EVENT`

### Communication inter-agents
- **SSH/API** pour les workers externes (PandaMiner)
- **Fichiers partagés** via bind mounts pour la communication intra-VM
- **Samba** pour les partages réseau cross-VM

---

## 🔏 Preuve &amp; traçabilité

Chaque opération dans LinuxIA doit être **vérifiable, reproductible et traçable** :

### Preuve minimale requise
1. **Sortie de commande horodatée** (stdout/stderr capturée)
2. **Fichier de résultat** dans `logs/` (append-only)
3. **Diff ou checksum** si modification de configuration
4. **Artefact ou log de test** si déploiement

### Définition of Done (DoD)
```bash
✓ Script exécuté sans erreur (exit 0)
✓ Log proof créé dans logs/health/YYYY-MM-DD/
✓ Checksum configs sauvegardé dans data/shareA/archives/
✓ Métriques RAM/CPU/IO dans les seuils
✓ Rapport GitHub Actions vert (si CI)
```

### Anti-patterns interdits
- ❌ "Ça semble OK" sans preuve
- ❌ Modification de fichier sans backup + diff
- ❌ Déploiement sans test minimal
- ❌ Secrets dans le repo (voir SECURITY.md)

---

## 🔒 Sécurité &amp; gouvernance

### Principes de sécurité
- **Least privilege** : chaque agent/script tourne avec les droits minimaux nécessaires
- **Secrets hors repo** : variables d'environnement ou vault (jamais dans git)
- **Isolation réseau** : VLANs ou firewalling entre VMs selon sensibilité
- **Audit trail** : tous les accès root loggés via `auditd` ou `journald`

### Politique de disclosure
Voir [SECURITY.md](SECURITY.md) — contact privé pour les vulnérabilités.

### Matrice de risques
Voir [RISKS.md](RISKS.md) — risques R1–R7 documentés avec mitigations.

### Hardening appliqué
| Mesure | Outil | Statut |
|--------|-------|--------|
| SSH key-only | sshd_config | ✓ |
| Fail2ban | fail2ban | ✓ |
| Firewall | nftables/iptables | ✓ |
| Quotas cgroups | systemd | ✓ |
| Secrets vault | env vars | ✓ |
| Audit logs | journald | ✓ |

---

## 🌐 Réseau &amp; Samba

### Topologie réseau
```
192.168.1.128  Proxmox VE (hôte physique)
192.168.1.135  VM100 — Usine principale
192.168.1.136  VM101 — Analyse/divergence
192.168.1.137  VM102 — Outils/GPU
```

### Partages Samba (cross-VM)
Les données partagées entre VMs transitent via Samba sur le réseau local :

```ini
[shareA]
path = /opt/linuxia/data/shareA
read only = No
valid users = linuxia
browseable = Yes

[shareB]
path = /opt/linuxia/data/shareB
read only = No
valid users = linuxia
browseable = Yes
```

### Sécurité réseau
- Accès Samba restreint aux IPs du LAN LinuxIA uniquement
- Authentification par utilisateur dédié (`linuxia`)
- Bind mounts pour données critiques (pas de Samba pour les logs de proof)

---

## ⚡ GPU &amp; Compute avancé

### NVIDIA GTX 1080 (VM102)
- Passthrough PCIe KVM complet
- Drivers NVIDIA propriétaires dans VM102
- **CUDA** disponible pour calculs intensifs
- Isolation KVM : le GPU ne partage pas de ressources avec les autres VMs

### PandaMiner B7Pro (alias PinderMiner)
- Worker GPU externe (réseau local)
- Accès via SSH/API depuis VM100
- **Quotas stricts** : max 80% GPU, jobs en file d'attente
- Spécialisé jobs lourds : ML inference, hash, rendu

### Politique d'exécution GPU
```bash
# Lancer un job GPU (via orchestrateur)
linuxia-gpu-worker submit \
  --target pandaminer \
  --quota 80 \
  --timeout 3600 \
  --proof-required true \
  job.sh
```

### Monitoring GPU
- `nvidia-smi` polling toutes les 60s → log JSONL
- Alerte si temp > 80°C ou VRAM > 90%
- Résultats des jobs archivés dans `logs/gpu/`

---

## 🧠 Philosophie Proof-First (version étendue)

> *"Une infrastructure sans preuve est une infrastructure au bord du gouffre."*

### Les 5 axiomes Proof-First

**1. Toute action produit une trace**
Chaque script, agent ou opération génère un log horodaté. Sans log = non fait.

**2. Toute configuration est versionnée**
`git commit` obligatoire avant et après tout changement de config. Diff disponible.

**3. Toute déployabilité est testée**
Un template non testé ne peut pas être cloné en production. CI gate obligatoire.

**4. Toute défaillance est documentée**
Incident → RISKS.md mis à jour → mitigation versionnée. Pas de "fix silencieux".

**5. Toute donnée sensible est isolée**
Secrets dans l'environnement, jamais dans les fichiers versionnés. Audit régulier.

### Cycle de vie Proof-First
```
PLAN (DRY-RUN)
    ↓ validation
EXECUTE (avec backup)
    ↓ sortie capturée
VERIFY (check exit code + log)
    ↓ preuve confirmée
CRITIQUE (peer review ou auto-check)
    ↓ corrections si besoin
LOG_EVENT (JSONL append-only)
    ↓
DoD ✓
```

---

## 🛡️ Résilience systémique

### Mécanismes de protection

| Mécanisme | Description | Seuil |
|-----------|-------------|-------|
| **zRAM** | Swap compressé prioritaire | Avant swap disque |
| **Quotas RAM** | cgroups v2 par VM | Configurable par VM |
| **OOM killer** | Tune pour protéger les VMs critiques | VM100 protégée |
| **Snapshots** | Btrfs auto-snapshots avant toute modif | Rolling-7 |
| **Watchdog** | systemd watchdog sur services critiques | timeout 30s |
| **Fallback VM** | VM103 prête en cold spare | Manuel |

### Dégradation progressive
1. **Pression RAM légère** → zRAM absorbe, alerte LOG
2. **Pression RAM forte** → suspend workers non-critiques, alerte WARN
3. **Pression RAM critique** → OOM policy, protect VM100, alerte CRIT
4. **Panne disque NVMe** → fallback SATA, snapshot emergency, pager
5. **Panne VM100** → escalade vers Proxmox host, snapshot + rebuild

### RPO / RTO cibles
- **RPO** (Recovery Point Objective) : < 5 minutes (snapshots toutes les 5 min)
- **RTO** (Recovery Time Objective) : < 15 minutes (snapshot restore + healthcheck)

---

## 🚀 Projection future

### Roadmap technique (priorités)

| Horizon | Objectif | Priorité |
|---------|----------|----------|
| Court terme | Automatisation complète CI/CD proof-first | 🔴 Haute |
| Court terme | Dashboard observabilité temps réel | 🔴 Haute |
| Moyen terme | Fédération multi-Proxmox (cluster HA) | 🟡 Moyenne |
| Moyen terme | Intégration LLM agent-loop (CoT + proof) | 🟡 Moyenne |
| Long terme | Self-healing automatisé (ML-driven) | 🟢 Basse |
| Long terme | Déploiement edge (Raspberry Pi workers) | 🟢 Basse |

### Innovations prévues
- **Agent-loop LLM** : les agents utilisent un LLM local (LLaMA/Mistral) pour la prise de décision, avec vérification proof-first de chaque décision
- **GitOps complet** : toute modification d'infrastructure via PR GitHub Actions → audit trail automatique
- **Observabilité ML** : anomaly detection sur les métriques système → alertes prédictives

---

## 🏆 Conclusion stratégique

LinuxIA n'est pas qu'une infrastructure — c'est une **philosophie d'ingénierie** :

### Ce qui distingue LinuxIA

1. **Proof-First avant tout** : aucune action sans preuve. Chaque log est une garantie.
2. **Architecture en couches** : isolation, reproductibilité, scalabilité horizontale par design.
3. **Thermal-Tier Memory** : gestion intelligente RAM→NVMe→SATA, latence minimisée.
4. **Agents versionnés** : les comportements complexes sont des macros explicites, jamais de magie.
5. **Résilience systémique** : dégradation progressive, snapshots automatiques, fallback documenté.
6. **GPU intégré** : PandaMiner + GTX 1080 pour les charges lourdes, quotas et isolation garantis.

### Mission
> Orchestrer des systèmes Linux complexes avec la rigueur d'une mission spatiale NASA :
> **chaque byte tracé, chaque décision justifiée, chaque défaillance documentée.**

```
LinuxIA v∞ — Proof-First · Multi-Layer · Low-Latency · GPU-Ready · Resilient
```

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
