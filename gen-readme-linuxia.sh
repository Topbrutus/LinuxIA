#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/opt/linuxia}"
cd "$ROOT"

ASSETS="assets/readme"
mkdir -p "$ASSETS"

cat > "$ASSETS/divider-hyperline.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="84" viewBox="0 0 1600 84" role="img" aria-label="Divider Hyperline">
  <defs>
    <linearGradient id="h" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ff6a00"/>
      <stop offset="0.5" stop-color="#00ff7b"/>
      <stop offset="0.85" stop-color="#00b3ff"/>
      <stop offset="1" stop-color="#ff6a00"/>
      <animate attributeName="x1" dur="6.5s" values="0;1;0" repeatCount="indefinite"/>
      <animate attributeName="x2" dur="6.5s" values="1;0;1" repeatCount="indefinite"/>
    </linearGradient>
    <filter id="g" x="-25%" y="-60%" width="150%" height="220%">
      <feGaussianBlur stdDeviation="2.6" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <rect width="1600" height="84" fill="#070A10"/>
  <g filter="url(#g)" opacity="0.95">
    <path d="M0 42 C 240 10, 420 74, 640 42 S 1040 10, 1260 42 S 1400 74, 1600 42"
          fill="none" stroke="url(#h)" stroke-width="2.4" stroke-linecap="round">
      <animate attributeName="stroke-width" dur="2.8s" values="2.4;3.2;2.4" repeatCount="indefinite"/>
    </path>
    <circle cx="220" cy="42" r="3.2" fill="#00ff7b">
      <animate attributeName="cx" dur="4.8s" values="220;1480;220" repeatCount="indefinite"/>
    </circle>
    <circle cx="1480" cy="42" r="3.2" fill="#ff6a00">
      <animate attributeName="cx" dur="5.2s" values="1480;220;1480" repeatCount="indefinite"/>
    </circle>
  </g>
</svg>
SVG

cat > "$ASSETS/hero-linuxia.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="520" viewBox="0 0 1600 520" role="img" aria-label="LinuxIA Hero">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#050712"/>
      <stop offset="1" stop-color="#060913"/>
    </linearGradient>
    <linearGradient id="a" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ff6a00"/>
      <stop offset="0.5" stop-color="#00ff7b"/>
      <stop offset="0.85" stop-color="#00b3ff"/>
      <stop offset="1" stop-color="#ff6a00"/>
      <animate attributeName="x1" dur="9s" values="0;1;0" repeatCount="indefinite"/>
      <animate attributeName="x2" dur="9s" values="1;0;1" repeatCount="indefinite"/>
    </linearGradient>
    <pattern id="grid" width="44" height="44" patternUnits="userSpaceOnUse">
      <path d="M44 0H0V44" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1"/>
      <path d="M22 0V44 M0 22H44" fill="none" stroke="rgba(0,255,123,0.05)" stroke-width="1"/>
    </pattern>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="2.4" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <mask id="scan">
      <rect width="1600" height="520" fill="white"/>
      <rect x="-520" y="0" width="520" height="520" fill="black">
        <animate attributeName="x" dur="6.2s" values="-520;1700" repeatCount="indefinite"/>
      </rect>
    </mask>
    <radialGradient id="vig" cx="52%" cy="38%" r="70%">
      <stop offset="0" stop-color="rgba(0,0,0,0)"/>
      <stop offset="1" stop-color="rgba(0,0,0,.55)"/>
    </radialGradient>
  </defs>

  <rect width="1600" height="520" fill="url(#bg)"/>
  <rect width="1600" height="520" fill="url(#grid)" opacity="0.95"/>

  <g filter="url(#glow)">
    <text x="72" y="140"
      font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial"
      font-size="54" font-weight="950" fill="rgba(255,255,255,0.95)">LinuxIA</text>

    <text x="72" y="178"
      font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace"
      font-size="15" fill="rgba(0,255,123,0.78)">
      PROOF-FIRST · AGENT OPS · PROXMOX · ZFS · SYSTEMD · JSONL
    </text>

    <rect x="72" y="206" width="760" height="2.6" fill="url(#a)" opacity="0.85"/>

    <rect x="72" y="240" width="740" height="220" rx="18" fill="rgba(0,0,0,0.55)" stroke="rgba(255,255,255,0.12)"/>
    <text x="92" y="276" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="13" fill="rgba(255,255,255,0.90)">STATUS / HEALTH</text>
    <text x="92" y="312" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="13" fill="rgba(0,255,123,0.85)">OK=24</text>
    <text x="182" y="312" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="13" fill="rgba(255,255,255,0.70)">WARN=0</text>
    <text x="292" y="312" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="13" fill="rgba(255,255,255,0.70)">FAIL=0</text>

    <text x="92" y="354" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="12" fill="rgba(255,255,255,0.70)">Rule:</text>
    <text x="140" y="354" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="12" fill="rgba(255,255,255,0.92)">Every change → timestamped proof</text>

    <rect x="92" y="386" width="680" height="2.2" fill="url(#a)" opacity="0.65"/>
    <rect x="92" y="402" width="10" height="16" fill="url(#a)" opacity="0.9">
      <animate attributeName="opacity" dur="0.9s" values="0;1;0" repeatCount="indefinite"/>
    </rect>
    <text x="110" y="415" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="12" fill="rgba(255,255,255,0.75)">ledger/state.jsonl</text>

    <g opacity="0.62">
      <ellipse cx="1230" cy="310" rx="280" ry="110" fill="none" stroke="rgba(255,106,0,0.22)" stroke-width="2"/>
      <ellipse cx="1230" cy="310" rx="220" ry="88" fill="none" stroke="rgba(0,255,123,0.18)" stroke-width="2"/>
      <ellipse cx="1230" cy="310" rx="160" ry="62" fill="none" stroke="rgba(0,179,255,0.18)" stroke-width="2"/>
      <g>
        <circle cx="1510" cy="310" r="4.2" fill="#ff6a00"/>
        <animateTransform attributeName="transform" type="rotate" dur="9.8s" values="0 1230 310;360 1230 310" repeatCount="indefinite"/>
      </g>
      <g>
        <circle cx="1450" cy="310" r="3.8" fill="#00ff7b"/>
        <animateTransform attributeName="transform" type="rotate" dur="8.2s" values="360 1230 310;0 1230 310" repeatCount="indefinite"/>
      </g>
      <g>
        <circle cx="1390" cy="310" r="3.4" fill="#00b3ff"/>
        <animateTransform attributeName="transform" type="rotate" dur="6.9s" values="0 1230 310;360 1230 310" repeatCount="indefinite"/>
      </g>
    </g>
  </g>

  <g mask="url(#scan)" opacity="0.18">
    <rect x="-520" y="0" width="520" height="520" fill="url(#a)"/>
  </g>
  <rect width="1600" height="520" fill="url(#vig)"/>
</svg>
SVG

make_section_svg () {
  local out="$1" title="$2" subtitle="$3" lines="$4"
  cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="420" viewBox="0 0 1600 420" role="img" aria-label="$title">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#070A10"/>
      <stop offset="1" stop-color="#050712"/>
    </linearGradient>
    <linearGradient id="a" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ff6a00"/>
      <stop offset="0.5" stop-color="#00ff7b"/>
      <stop offset="0.85" stop-color="#00b3ff"/>
      <stop offset="1" stop-color="#ff6a00"/>
      <animate attributeName="x1" dur="8s" values="0;1;0" repeatCount="indefinite"/>
      <animate attributeName="x2" dur="8s" values="1;0;1" repeatCount="indefinite"/>
    </linearGradient>
    <pattern id="grid" width="44" height="44" patternUnits="userSpaceOnUse">
      <path d="M44 0H0V44" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1"/>
      <path d="M22 0V44 M0 22H44" fill="none" stroke="rgba(0,255,123,0.05)" stroke-width="1"/>
    </pattern>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="2.2" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <rect width="1600" height="420" fill="url(#bg)"/>
  <rect width="1600" height="420" fill="url(#grid)" opacity="0.85"/>

  <rect x="56" y="64" width="1488" height="292" rx="20" fill="rgba(0,0,0,0.52)" stroke="rgba(255,255,255,0.12)"/>
  <rect x="56" y="64" width="1488" height="292" rx="20" fill="none" stroke="url(#a)" stroke-width="2.2" opacity="0.60">
    <animate attributeName="opacity" dur="3.8s" values="0.45;0.72;0.45" repeatCount="indefinite"/>
  </rect>

  <g filter="url(#glow)">
    <text x="96" y="132"
      font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial"
      font-size="34" font-weight="950" fill="rgba(255,255,255,0.95)">$title</text>

    <text x="96" y="164"
      font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace"
      font-size="14" fill="rgba(255,255,255,0.74)">$subtitle</text>

    <rect x="96" y="188" width="760" height="2.6" fill="url(#a)" opacity="0.75"/>

    <g font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" font-size="13" opacity="0.92" fill="rgba(255,255,255,0.74)">
      $lines
    </g>

    <rect x="96" y="310" width="10" height="16" fill="url(#a)" opacity="0.9">
      <animate attributeName="opacity" dur="0.9s" values="0;1;0" repeatCount="indefinite"/>
    </rect>
    <text x="114" y="323"
      font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace"
      font-size="12" fill="rgba(255,255,255,0.75)">LinuxIA · Proof-First Suite</text>
  </g>
</svg>
SVG
}

make_section_svg "$ASSETS/section-vision.svg" \
  "Vision" \
  "Proof-first : déclencheur → vérification → rapport → preuve" \
  '<text x="96" y="232">• Objectif: infra reproductible + traçable</text>
   <text x="96" y="262">• Chaque changement génère une preuve horodatée</text>
   <text x="96" y="292">• L'"'"'esthétique sert la lisibilité (NASA-tech)</text>'

make_section_svg "$ASSETS/section-architecture.svg" \
  "Architecture" \
  "Proxmox → VM100 Factory → ShareA (SMB evidence)" \
  '<text x="96" y="232">• Proxmox VE: templates · GPU passthrough · ZFS</text>
   <text x="96" y="262">• VM100: systemd timers + scripts verify</text>
   <text x="96" y="292">• ShareA: miroir de preuves (parité)</text>'

make_section_svg "$ASSETS/section-agents.svg" \
  "Agents" \
  "TriluxIA: rôles spécialisés, coordination par événements" \
  '<text x="96" y="232">• Sentinel: surveille + alerte</text>
   <text x="96" y="262">• Builder: génère + vérifie</text>
   <text x="96" y="292">• Auditor: compare local ↔ shareA</text>'

make_section_svg "$ASSETS/section-proof.svg" \
  "Proof" \
  "Reports + logs + evidence : audit-friendly, append-only" \
  '<text x="96" y="232">• Health reports: /opt/linuxia/logs/health/</text>
   <text x="96" y="262">• Ledger: JSONL append-only</text>
   <text x="96" y="292">• Option: hash + parity checks</text>'

README="README.md"
[[ -f "$README" ]] || printf "# LinuxIA\n" > "$README"

BEGIN="<!-- LINUXIA_README_SUITE_BEGIN -->"
END="<!-- LINUXIA_README_SUITE_END -->"

BLOCK="$(cat <<'MD'
<!-- LINUXIA_README_SUITE_BEGIN -->

<p align="center">
  <img src="assets/readme/hero-linuxia.svg" width="100%" alt="LinuxIA Hero"/>
</p>

<p align="center">
  <img src="assets/readme/divider-hyperline.svg" width="100%" alt="divider"/>
</p>

## 🚀 LinuxIA — Proof-First Agent Ops

LinuxIA est un framework d'opérations infra **orienté preuves** : chaque changement déclenche des vérifications,
génère des rapports, et dépose des éléments d'évidence exploitables (audit).

### 🧠 Suite (symétrique, bloc → bloc)

<p align="center">
  <img src="assets/readme/section-vision.svg" width="100%" alt="Vision"/>
</p>

<p align="center">
  <img src="assets/readme/divider-hyperline.svg" width="100%" alt="divider"/>
</p>

<p align="center">
  <img src="assets/readme/section-architecture.svg" width="100%" alt="Architecture"/>
</p>

<p align="center">
  <img src="assets/readme/divider-hyperline.svg" width="100%" alt="divider"/>
</p>

<p align="center">
  <img src="assets/readme/section-agents.svg" width="100%" alt="Agents"/>
</p>

<p align="center">
  <img src="assets/readme/divider-hyperline.svg" width="100%" alt="divider"/>
</p>

<p align="center">
  <img src="assets/readme/section-proof.svg" width="100%" alt="Proof"/>
</p>

### ✅ Règle d'or

> **Every change → timestamped proof.**

<!-- LINUXIA_README_SUITE_END -->
MD
)"

tmp="$(mktemp)"
if grep -qF "$BEGIN" "$README"; then
  awk -v b="$BEGIN" -v e="$END" '
    BEGIN{skip=0}
    index($0,b){skip=1; next}
    index($0,e){skip=0; next}
    skip==0{print}
  ' "$README" > "$tmp"
  mv "$tmp" "$README"
fi

printf "\n%s\n" "$BLOCK" >> "$README"

printf "✅ Generated README suite + assets:\n"
printf "  - %s/hero-linuxia.svg\n" "$ASSETS"
printf "  - %s/section-vision.svg\n" "$ASSETS"
printf "  - %s/section-architecture.svg\n" "$ASSETS"
printf "  - %s/section-agents.svg\n" "$ASSETS"
printf "  - %s/section-proof.svg\n" "$ASSETS"
printf "  - %s/divider-hyperline.svg\n" "$ASSETS"
printf "  - README.md (injected between markers)\n"
