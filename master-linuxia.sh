#!/usr/bin/env bash
set -euo pipefail

# LinuxIA — Master Showcase Generator v4.0
# Aesthetic: NASA x Proxmox x Matrix
# --------------------------------------------------

REPO_ROOT="."
# Media source directories. Override via env vars if sources are not in the repo's pour_copilot/ folder.
# Example: LINUXIA_SRC_AUDIO=/mnt/media/audio bash master-linuxia.sh
SRC_AUDIO="${LINUXIA_SRC_AUDIO:-$REPO_ROOT/pour_copilot/audio}"
SRC_PHOTOS="${LINUXIA_SRC_PHOTOS:-$REPO_ROOT/pour_copilot/photos}"
SRC_VIDEOS="${LINUXIA_SRC_VIDEOS:-$REPO_ROOT/pour_copilot/videos}"
ASSETS_DIR="$REPO_ROOT/assets/readme"

# --------------------------------------------------
# STEP 01: DIRECTORIES
# --------------------------------------------------
mkdir -p "$ASSETS_DIR"/{anims,sections,gallery,videos,audio}

# --------------------------------------------------
# STEP 02: MEDIA
# --------------------------------------------------
cp -f "$SRC_AUDIO/Theme_01.mp3"   "$ASSETS_DIR/audio/"  2>/dev/null || true
cp -f "$SRC_VIDEOS/Trailer_01.mp4" "$ASSETS_DIR/videos/" 2>/dev/null || true
cp -f "$SRC_VIDEOS/Trailer_02.mp4" "$ASSETS_DIR/videos/" 2>/dev/null || true

i=1
for n in 02 03 04 05 06 07 08 09; do
    src="$SRC_PHOTOS/LinuxIA_${n}.jpg"
    [[ -f "$src" ]] && cp -f "$src" "$ASSETS_DIR/gallery/p$(printf '%02d' $i).jpg"
    i=$((i+1))
done

# --------------------------------------------------
# STEP 03: SVGs (Python)
# --------------------------------------------------
python3 - <<'PY'
import random
from pathlib import Path

REPO = Path(".")
ANIMS   = REPO / "assets/readme/anims"
SECTIONS = REPO / "assets/readme/sections"
ANIMS.mkdir(parents=True, exist_ok=True)
SECTIONS.mkdir(parents=True, exist_ok=True)

CYAN   = "#4efcff"
CYAN2  = "#2bdcff"
ORANGE = "#ff6a00"
GREEN  = "#00ff7b"
PURPLE = "#b36bff"
DEEP   = "#02060f"
BLUEBG = "#061225"
W = H  = 320

# ── 9 Hub Animations ──────────────────────────────
def stars(seed, n=26):
    rng = random.Random(seed)
    return [(rng.randint(36,W-36), rng.randint(36,H-36),
             rng.choice([0.8,1.0,1.2,1.6,2.0]),
             rng.choice([CYAN,ORANGE,PURPLE,"#ffffff"]),
             rng.choice([0.35,0.45,0.55,0.65,0.75])) for _ in range(n)]

def hud_bars(seed):
    rng = random.Random(seed)
    bars = []
    for i in range(12):
        h = rng.randint(6,28)
        bars.append((46+i*9, 274+(28-h), 6, h))
    return bars

def hub_svg(i):
    phase   = (i*37)%360
    orbit_r = 96+(i%3)*10
    inner_r = 46+(i%4)*4
    pts  = stars(1000+i)
    bars = hud_bars(2000+i)
    dur_orbit = f"{7.2+(i%4)*0.6:.1f}"
    dur_aura  = f"{14.0+(i%3)*1.2:.1f}"
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{DEEP}"/><stop offset="1" stop-color="{BLUEBG}"/>
    </linearGradient>
    <radialGradient id="vign" cx="50%" cy="45%" r="70%">
      <stop offset="0" stop-color="#000" stop-opacity="0"/>
      <stop offset="1" stop-color="#000" stop-opacity="0.55"/>
    </radialGradient>
    <linearGradient id="shade" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#000" stop-opacity="0.82"/>
      <stop offset="0.52" stop-color="#000" stop-opacity="0.34"/>
      <stop offset="1" stop-color="#000" stop-opacity="0.82"/>
    </linearGradient>
    <pattern id="grid" patternUnits="userSpaceOnUse" width="28" height="28">
      <path d="M28 0H0V28" fill="none" stroke="#7aa7ff" stroke-opacity="0.11" stroke-width="1"/>
    </pattern>
    <pattern id="scan" patternUnits="userSpaceOnUse" width="6" height="6">
      <rect width="6" height="6" fill="none"/>
      <rect y="0" width="6" height="1" fill="#fff" opacity="0.06"/>
    </pattern>
    <filter id="shadowDeep" x="-30%" y="-30%" width="160%" height="160%">
      <feDropShadow dx="0" dy="10" stdDeviation="10" flood-color="#000" flood-opacity="0.55"/>
    </filter>
    <filter id="glowC" x="-40%" y="-40%" width="180%" height="180%">
      <feGaussianBlur stdDeviation="4.8" result="b"/>
      <feColorMatrix in="b" type="matrix"
        values="1 0 0 0 0  0 1 0 0 0.25  0 0 1 0 0.75  0 0 0 0.95 0" result="c"/>
      <feMerge><feMergeNode in="c"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="glowO" x="-40%" y="-40%" width="180%" height="180%">
      <feGaussianBlur stdDeviation="5.5" result="b"/>
      <feColorMatrix in="b" type="matrix"
        values="1 0 0 0 0.18  0 1 0 0 0.05  0 0 1 0 0  0 0 0 0.85 0" result="c"/>
      <feMerge><feMergeNode in="c"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="ts"><feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="#000" flood-opacity="0.9"/></filter>
    <clipPath id="cc"><rect x="18" y="18" width="284" height="284" rx="22" ry="22"/></clipPath>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#bg)"/>
  <rect width="{W}" height="{H}" fill="url(#shade)"/>
  <rect width="{W}" height="{H}" fill="url(#grid)"/>
  <rect width="{W}" height="{H}" fill="url(#scan)" opacity="0.65"/>
  <rect width="{W}" height="{H}" fill="url(#vign)"/>
  <g filter="url(#shadowDeep)">
    <rect x="18" y="18" width="284" height="284" rx="22" fill="#07142a" opacity="0.52"/>
  </g>
  <rect x="18" y="18" width="284" height="284" rx="22"
    fill="none" stroke="{CYAN}" stroke-opacity="0.45" stroke-width="2.2" filter="url(#glowC)"/>
  <rect x="26" y="26" width="268" height="268" rx="18"
    fill="none" stroke="{ORANGE}" stroke-opacity="0.25" stroke-width="1.6" filter="url(#glowO)"/>
  <g clip-path="url(#cc)">
    <rect x="18" y="18" width="284" height="284" fill="#fff" opacity="0.05"/>
    {"".join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}" opacity="{o}"/>' for x,y,r,c,o in pts)}
    <circle cx="160" cy="160" r="{orbit_r}" fill="none" stroke="{CYAN2}" stroke-opacity="0.22" stroke-width="2"/>
    <circle cx="160" cy="160" r="{inner_r}" fill="none" stroke="{PURPLE}" stroke-opacity="0.18" stroke-width="1.6"/>
    <g transform="translate(160 160)">
      <g>
        <animateTransform attributeName="transform" type="rotate"
          from="{phase} 0 0" to="{phase+360} 0 0" dur="{dur_orbit}s" repeatCount="indefinite"/>
        <circle cx="{orbit_r}" cy="0" r="4.2" fill="{CYAN}" opacity="0.85" filter="url(#glowC)"/>
        <circle cx="{orbit_r}" cy="0" r="2.0" fill="#fff" opacity="0.70"/>
      </g>
    </g>
    <g transform="translate(160 160)" opacity="0.55">
      <animateTransform attributeName="transform" type="rotate"
        from="{phase+180} 0 0" to="{phase-180} 0 0" dur="{dur_aura}s" repeatCount="indefinite"/>
      <circle cx="0" cy="0" r="{orbit_r-14}" fill="none" stroke="{ORANGE}"
        stroke-opacity="0.12" stroke-width="10" filter="url(#glowO)"/>
    </g>
  </g>
  <g opacity="0.75" filter="url(#glowC)">
    {"".join(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="2" fill="{CYAN2}" opacity="0.55"/>' for x,y,w,h in bars)}
  </g>
  <g filter="url(#ts)">
    <text x="160" y="292" text-anchor="middle"
      font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace"
      font-size="12" font-weight="900" fill="#d7f6ff" opacity="0.92"
      paint-order="stroke fill" stroke="#000" stroke-width="3" stroke-linejoin="round">
      HUB_ANIM_{i:02d}
    </text>
  </g>
</svg>"""

for i in range(1,10):
    p = ANIMS / f"anim_{i:02d}.svg"
    p.write_text(hub_svg(i), encoding="utf-8")

# ── 8 Cinematic Sections ──────────────────────────
SECTION_DATA = [
    ("Vision",        "Proof-First Agent Ops — une infra qui produit sa preuve"),
    ("Architecture",  "Multi-VM (Proxmox) + openSUSE + systemd + GitHub"),
    ("Agents",        "TriluxIA / ChromIAlux — orchestration, outbox, ledger"),
    ("Proof",         "No change without evidence — rapports, checks, artefacts"),
    ("Infra",         "Timers, healthchecks, snapshots, CI — tout est traçable"),
    ("Security",      "Accès contrôlés, règles repo, PR-only, audit en continu"),
    ("Storage",       "ZFS/Btrfs, caches, logs, Vault — vitesse + robustesse"),
    ("Roadmap",       "Phases, DoD, vérifications — progression incrémentale"),
]

GALLERY = REPO / "assets/readme/gallery"

def section_svg(idx, title, subtitle, photo):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="420" viewBox="0 0 1200 420">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#05070f"/><stop offset="1" stop-color="#0b1024"/>
    </linearGradient>
    <linearGradient id="ov" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#000" stop-opacity="0.70"/>
      <stop offset="0.55" stop-color="#000" stop-opacity="0.42"/>
      <stop offset="1" stop-color="#000" stop-opacity="0.70"/>
    </linearGradient>
    <filter id="sg" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="5" result="b"/>
      <feColorMatrix in="b" type="matrix"
        values="1 0 0 0 0  0 1 0 0 0.2  0 0 1 0 0.6  0 0 0 0.9 0" result="c"/>
      <feMerge><feMergeNode in="c"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <pattern id="scan" patternUnits="userSpaceOnUse" width="6" height="6">
      <rect width="6" height="6" fill="none"/>
      <rect y="0" width="6" height="1" fill="#fff" opacity="0.05"/>
    </pattern>
    <filter id="ts"><feDropShadow dx="0" dy="2" stdDeviation="3" flood-color="#000" flood-opacity="0.9"/></filter>
  </defs>
  <rect width="1200" height="420" fill="url(#bg)"/>
  <image href="{photo}" x="0" y="0" width="1200" height="420"
    preserveAspectRatio="xMidYMid slice" opacity="0.92"/>
  <rect width="1200" height="420" fill="url(#ov)"/>
  <rect width="1200" height="420" fill="url(#scan)" opacity="0.5"/>
  <rect x="20" y="20" width="1160" height="380" rx="20"
    fill="none" stroke="#4efcff" stroke-opacity="0.5" stroke-width="2" filter="url(#sg)"/>
  <rect x="28" y="28" width="1144" height="364" rx="16"
    fill="none" stroke="#ff6a00" stroke-opacity="0.30" stroke-width="1.5"/>
  <g filter="url(#ts)">
    <text x="68" y="170" font-family="Inter,Segoe UI,Arial"
      font-size="58" font-weight="900" fill="#fff" opacity="0.96"
      paint-order="stroke fill" stroke="#000" stroke-width="6" stroke-linejoin="round">
      {title}
    </text>
    <text x="68" y="218" font-family="Inter,Segoe UI,Arial"
      font-size="21" font-weight="600" fill="#dbe6ff" opacity="0.90"
      paint-order="stroke fill" stroke="#000" stroke-width="4" stroke-linejoin="round">
      {subtitle}
    </text>
    <text x="68" y="258" font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace"
      font-size="13" font-weight="700" fill="#4efcff" opacity="0.88"
      paint-order="stroke fill" stroke="#000" stroke-width="3" stroke-linejoin="round">
      SECTION_{idx:02d} • CYBER/NASA/MATRIX • CINEMATIC
    </text>
  </g>
  <g transform="translate(68,336)" filter="url(#sg)">
    <rect x="0" y="0" width="200" height="32" rx="16" fill="#0b1024" opacity="0.78" stroke="#4efcff" stroke-opacity="0.35"/>
    <text x="16" y="21" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#cfe7ff">Proof-first • Ops • CI</text>
    <rect x="220" y="0" width="230" height="32" rx="16" fill="#0b1024" opacity="0.78" stroke="#ff6a00" stroke-opacity="0.35"/>
    <text x="236" y="21" font-family="ui-monospace,Menlo,Consolas,monospace" font-size="12" fill="#ffe7d1">Multi-VM • openSUSE • systemd</text>
  </g>
</svg>"""

for idx,(title,subtitle) in enumerate(SECTION_DATA, 1):
    photo_file = GALLERY / f"p{idx:02d}.jpg"
    photo_ref = f"../gallery/p{idx:02d}.jpg" if photo_file.exists() else ""
    fname = SECTIONS / f"section_{idx:02d}_{title.lower()}.svg"
    fname.write_text(section_svg(idx, title, subtitle, photo_ref), encoding="utf-8")

PY

# --------------------------------------------------
# STEP 04: README
# --------------------------------------------------
cat > README.md <<'EOF'
# 🧠 LinuxIA — Proof-First Agent Ops

<p align="center">
  <img src="assets/readme/sections/section_01_vision.svg" width="1000" alt="Vision"/>
</p>

> **LinuxIA n'est pas un projet. C'est un organisme informatique distribué.**
> Chaque action laisse une preuve. Chaque agent a un rôle. Chaque VM est un organe.

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
EOF

# --------------------------------------------------
# DONE
# --------------------------------------------------
ls assets/readme/anims/anim_*.svg | wc -l
ls assets/readme/sections/section_*.svg | wc -l
ls assets/readme/gallery/p*.jpg 2>/dev/null | wc -l || true
