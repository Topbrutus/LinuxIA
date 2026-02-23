#!/usr/bin/env bash
# LinuxIA — Master Showcase Generator (Final Version)
# Paths updated from user screenshots
set -euo pipefail

REPO_ROOT="/home/gaby/pour_copilot/g_p/linuxia_-cinematic-showcase"
SRC_AUDIO="/home/gaby/pour_copilot/audio"
SRC_PHOTOS="/home/gaby/pour_copilot/photos"
SRC_VIDEOS="/home/gaby/pour_copilot/videos"
ASSETS_DIR="$REPO_ROOT/assets/readme"

# Colors
ORANGE='\033[0;33m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

echo -e "${ORANGE}${BOLD}🚀 LINUXIA MASTER GENERATOR v3.0${NC}"
echo "--------------------------------------------------"

# 1. Structure
mkdir -p "$ASSETS_DIR"/{anims,sections,gallery,videos,audio}

# 2. Media Migration
echo -e "${CYAN}[INFO]${NC} Migration des médias depuis vos dossiers personnels..."
cp -f "$SRC_AUDIO/Theme_01.mp3" "$ASSETS_DIR/audio/" 2>/dev/null || true
cp -f "$SRC_VIDEOS"/Trailer_*.mp4 "$ASSETS_DIR/videos/" 2>/dev/null || true

# Mapping précis LinuxIA_02..09 -> p01..p08
i=1
for n in 02 03 04 05 06 07 08 09; do
    cp -f "$SRC_PHOTOS/LinuxIA_$n.jpg" "$ASSETS_DIR/gallery/p0$i.jpg" 2>/dev/null || true
    i=$((i+1))
done

# 3. SVG Generation (Hub + Sections)
echo -e "${CYAN}[INFO]${NC} Génération des animations SVGs..."
python3 - <<'PY'
from pathlib import Path
import os

def gen():
    # Hub Anims
    out_anims = Path("assets/readme/anims")
    out_anims.mkdir(parents=True, exist_ok=True)
    for i in range(1, 10):
        r = 110 + (i % 3) * 15
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="320" height="320" viewBox="0 0 320 320">
            <rect width="320" height="320" fill="#05070f" rx="24"/>
            <circle cx="160" cy="160" r="{r}" fill="none" stroke="#4efcff" stroke-opacity="0.2" stroke-width="2" stroke-dasharray="4 8"/>
            <g transform="translate(160 160)">
                <animateTransform attributeName="transform" type="rotate" from="0 0 0" to="360 0 0" dur="{5+i}s" repeatCount="indefinite"/>
                <circle cx="{r}" cy="0" r="6" fill="#ff6a00"/>
            </g>
            <text x="160" y="285" text-anchor="middle" font-family="monospace" font-size="12" font-weight="900" fill="#00ff7b">HUB_ANIM_{i:02d}</text>
        </svg>"""
        (out_anims / f"anim_{i:02d}.svg").write_text(svg)

    # Cinematic Sections
    out_secs = Path("assets/readme/sections")
    out_secs.mkdir(parents=True, exist_ok=True)
    titles = ["VISION", "ARCHITECTURE", "AGENTS", "PROOF", "INFRA", "SECURITY", "STORAGE", "ROADMAP"]
    for i, t in enumerate(titles, 1):
        photo = f"assets/readme/gallery/p0{i}.jpg"
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="420" viewBox="0 0 1200 420">
            <rect width="1200" height="420" fill="#050505"/>
            <image href="{photo}" width="1200" height="420" preserveAspectRatio="xMidYMid slice" opacity="0.7"/>
            <rect x="30" y="30" width="1140" height="360" rx="30" fill="none" stroke="#4efcff" stroke-opacity="0.3" stroke-width="2"/>
            <text x="80" y="150" font-family="sans-serif" font-size="72" font-weight="900" fill="white">{t}</text>
        </svg>"""
        (out_secs / f"section_{i:02d}_{t.lower()}.svg").write_text(svg)

gen()
PY

# 4. README Update
echo -e "${CYAN}[INFO]${NC} Mise à jour du README.md..."
cat > README.md <<'EOF'
# 🧠 LinuxIA — Proof-First Agent Orchestration

<p align="center"><img src="assets/readme/sections/section_01_vision.svg" width="1000" /></p>

## 🧩 Status Hub
<p align="center">
  <img src="assets/readme/anims/anim_01.svg" width="310" />
  <img src="assets/readme/anims/anim_02.svg" width="310" />
  <img src="assets/readme/anims/anim_03.svg" width="310" />
</p>

<p align="center"><img src="assets/readme/sections/section_02_architecture.svg" width="1000" /></p>
<p align="center"><img src="assets/readme/sections/section_03_agents.svg" width="1000" /></p>

### 🎬 Media Vault
- [Trailer 01](assets/readme/videos/Trailer_01.mp4)
- [Theme Audio](assets/readme/audio/Theme_01.mp3)
EOF

echo -e "${GREEN}[OK]${NC} Tout est prêt. Vous pouvez maintenant faire : git add . && git commit -m 'LinuxIA Showcase' && git push"
