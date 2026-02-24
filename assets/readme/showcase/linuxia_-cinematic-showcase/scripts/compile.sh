#!/usr/bin/env bash
# LinuxIA — Professional Compilation Pipeline
set -euo pipefail

ORANGE='\033[0;33m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'

echo -e "${ORANGE}${BOLD}MISSION CONTROL COMPILER v1.5.0${NC}"
echo "--------------------------------------------------"

echo -e "\n${BOLD}STEP 01: PRE-FLIGHT CHECKS${NC}"
[[ -f "package.json" ]] || { echo "package.json missing"; exit 1; }
echo -e "${GREEN}[OK]${NC} Environment verified."

echo -e "\n${BOLD}STEP 02: DYNAMIC ASSET GENERATION${NC}"
mkdir -p assets/readme/anims
python3 - <<'PY'
from pathlib import Path
outdir = Path("assets/readme/anims")
outdir.mkdir(parents=True, exist_ok=True)
def svg(i):
    orbit_r = 110 + (i % 3) * 15
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="320" height="320" viewBox="0 0 320 320">
  <rect width="320" height="320" fill="#05070f" rx="20"/>
  <circle cx="160" cy="160" r="{orbit_r}" fill="none" stroke="#00ff7b" stroke-opacity="0.2" stroke-width="2"/>
  <g transform="translate(160 160)">
    <animateTransform attributeName="transform" type="rotate" from="0 0 0" to="360 0 0" dur="{5+i}s" repeatCount="indefinite"/>
    <circle cx="{orbit_r}" cy="0" r="5" fill="#ff6a00"/>
  </g>
  <text x="160" y="290" text-anchor="middle" font-family="monospace" font-size="12" fill="#00ff7b">HUB_ANIM_{i:02d}</text>
</svg>"""
for i in range(1, 10): (outdir / f"anim_{i:02d}.svg").write_text(svg(i))
PY
echo -e "${GREEN}[OK]${NC} 9 Hub Animations generated."

echo -e "\n${BOLD}STEP 03: REACT COMPILATION${NC}"
npm run build
echo -e "${GREEN}[OK]${NC} App compiled to dist/."

echo -e "\n--------------------------------------------------"
echo -e "${GREEN}${BOLD}MISSION ACCOMPLISHED.${NC}"
