#!/usr/bin/env bash
# LinuxIA — Spectacular README & Asset Pipeline
set -euo pipefail

REPO_ROOT="/opt/linuxia"
SRC_MEDIA="/home/gaby/pour_copilot"
ASSETS_DIR="$REPO_ROOT/assets/readme"

ORANGE='\033[0;33m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

echo -e "${ORANGE}${BOLD}🚀 LINUXIA MASTER GENERATOR v3.0${NC}"

# 1. Structure
mkdir -p "$ASSETS_DIR"/{anims,sections,gallery,videos,audio}

# 2. Media Migration
cp -f "$SRC_MEDIA"/audio/Theme_01.mp3 "$ASSETS_DIR/audio/" 2>/dev/null || true
cp -f "$SRC_MEDIA"/videos/Trailer_*.mp4 "$ASSETS_DIR/videos/" 2>/dev/null || true
i=1
for n in 02 03 04 05 06 07 08 09; do
    cp -f "$SRC_MEDIA/photos/LinuxIA_$n.jpg" "$ASSETS_DIR/gallery/p0$i.jpg" 2>/dev/null || true
    i=$((i+1))
done

# 3. SVG Generation
python3 - <<'PY'
from pathlib import Path
def generate_hub_anims():
    out = Path("assets/readme/anims")
    out.mkdir(parents=True, exist_ok=True)
    for i in range(1, 10):
        orbit_r = 110 + (i % 3) * 15
        phase = (i * 40) % 360
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="320" height="320" viewBox="0 0 320 320">
            <rect width="320" height="320" fill="#05070f" rx="24"/>
            <circle cx="160" cy="160" r="{orbit_r}" fill="none" stroke="#4efcff" stroke-opacity="0.2" stroke-width="2" stroke-dasharray="4 8"/>
            <g transform="translate(160 160)">
                <animateTransform attributeName="transform" type="rotate" from="{phase} 0 0" to="{phase+360} 0 0" dur="{6+i}s" repeatCount="indefinite"/>
                <circle cx="{orbit_r}" cy="0" r="6" fill="#ff6a00"/>
            </g>
            <text x="160" y="285" text-anchor="middle" font-family="monospace" font-size="12" font-weight="900" fill="#00ff7b">HUB_ANIM_{i:02d}</text>
        </svg>"""
        (out / f"anim_{i:02d}.svg").write_text(svg)

def generate_sections():
    out = Path("assets/readme/sections")
    out.mkdir(parents=True, exist_ok=True)
    sections = [("VISION", "Agent Ops"), ("ARCHITECTURE", "Multi-VM"), ("AGENTS", "TriluxIA"), ("PROOF", "Evidence"), ("INFRA", "Systemd"), ("SECURITY", "Isolation"), ("STORAGE", "ZFS"), ("ROADMAP", "Phases")]
    for i, (t, s) in enumerate(sections, 1):
        photo = f"../gallery/p0{i}.jpg"
        svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="420" viewBox="0 0 1200 420">
            <rect width="1200" height="420" fill="#050505"/>
            <image href="{photo}" width="1200" height="420" preserveAspectRatio="xMidYMid slice" opacity="0.7"/>
            <rect x="30" y="30" width="1140" height="360" rx="30" fill="none" stroke="#4efcff" stroke-opacity="0.3" stroke-width="2"/>
            <text x="80" y="150" font-family="sans-serif" font-size="72" font-weight="900" fill="white">{t}</text>
            <text x="80" y="200" font-family="sans-serif" font-size="28" font-weight="600" fill="#ff6a00">{s}</text>
        </svg>"""
        (out / f"section_{i:02d}_{t.lower()}.svg").write_text(svg)
generate_hub_anims()
generate_sections()
PY

# 4. README Update
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
<p align="center"><img src="assets/readme/sections/section_04_proof.svg" width="1000" /></p>

### 🎬 Media
- [Trailer 01](assets/readme/videos/Trailer_01.mp4)
- [Theme Audio](assets/readme/audio/Theme_01.mp3)
EOF

echo -e "${GREEN}DONE.${NC}"
