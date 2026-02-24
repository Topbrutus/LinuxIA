#!/usr/bin/env bash
# LinuxIA — GitHub Assets Generator
set -euo pipefail

mkdir -p assets/readme/anims
mkdir -p assets/readme/sections

# Colors
PROXMOX="#ff6a00"
MATRIX="#00ff7b"
CYBER="#00b3ff"
NASA_RED="#fc3d21"
BG="#050505"

echo "Generating Hub Animations..."

# Helper to generate Hub SVG
gen_hub() {
  local file=$1
  local color=$2
  local label=$3
  cat > "assets/readme/anims/$file.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="320" height="320" viewBox="0 0 320 320">
  <rect width="320" height="320" fill="$BG" rx="20"/>
  <circle cx="160" cy="160" r="150" fill="none" stroke="$color" stroke-width="0.5" stroke-dasharray="5,5" opacity="0.2"/>
  <g transform="translate(160 160)">
    <animateTransform attributeName="transform" type="rotate" from="0 0 0" to="360 0 0" dur="10s" repeatCount="indefinite"/>
    <circle cx="120" cy="0" r="120" fill="none" stroke="$color" stroke-width="2" stroke-dasharray="100,20"/>
    <circle cx="120" cy="0" r="5" fill="$color"/>
  </g>
  <circle cx="160" cy="160" r="40" fill="none" stroke="$color" stroke-width="4">
    <animate attributeName="opacity" values="0.3;1;0.3" dur="2s" repeatCount="indefinite" />
  </circle>
  <text x="160" y="290" text-anchor="middle" font-family="monospace" font-size="14" fill="$color" font-weight="bold">$label</text>
</svg>
EOF
}

gen_hub "proxmox" "$PROXMOX" "PROXMOX_CORE"
gen_hub "matrix" "$MATRIX" "MATRIX_SYNC"
gen_hub "cyber" "$CYBER" "CYBER_LINK"
gen_hub "nasa" "$NASA_RED" "NASA_MISSION"

echo "Generating Cinematic Sections..."

# Helper to generate Section SVG
gen_section() {
  local file=$1
  local title=$2
  local subtitle=$3
  local color=$4
  local seed=$5
  cat > "assets/readme/sections/$file.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="400" viewBox="0 0 1000 400">
  <rect width="1000" height="400" fill="$BG" rx="40"/>
  <image href="https://picsum.photos/seed/$seed/1200/600" width="1200" height="600" x="-100" y="-100" opacity="0.4">
    <animateTransform attributeName="transform" type="translate" from="-50 -50" to="50 50" dur="20s" repeatCount="indefinite" />
  </image>
  <rect width="1000" height="400" fill="none" stroke="$color" stroke-width="2" opacity="0.3" rx="40"/>
  <g transform="translate(60, 180)">
    <animateTransform attributeName="transform" type="translate" values="60 180; 60 170; 60 180" dur="4s" repeatCount="indefinite" />
    <text font-family="sans-serif" font-size="80" font-weight="900" fill="white">$title</text>
    <text y="50" font-family="monospace" font-size="20" fill="$color" font-weight="bold">$subtitle</text>
  </g>
</svg>
EOF
}

gen_section "vision" "VISION" "PROOF-FIRST OPERATIONS" "$PROXMOX" "linuxia1"
gen_section "architecture" "ARCHITECTURE" "MULTI-VM ORCHESTRATION" "$CYBER" "linuxia2"
gen_section "agents" "AGENTS" "TRILUXIA COORDINATION" "$MATRIX" "linuxia3"
gen_section "proof" "PROOF" "IMMUTABLE EVIDENCE" "$PROXMOX" "linuxia4"
gen_section "infra" "INFRASTRUCTURE" "REPRODUCIBLE STACK" "$CYBER" "linuxia5"

echo "Assets generated."
