import os
from pathlib import Path

# Configuration
COLORS = {
    "proxmox": "#ff6a00",
    "matrix": "#00ff7b",
    "cyber": "#00b3ff",
    "nasa_red": "#fc3d21",
    "nasa_blue": "#0b3d91",
    "bg": "#050505"
}

def create_dir_structure():
    paths = [
        "assets/readme/anims",
        "assets/readme/sections",
        "assets/readme/gallery"
    ]
    for p in paths:
        os.makedirs(p, exist_ok=True)

def gen_hub_animation(filename, color, label):
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="320" height="320" viewBox="0 0 320 320">
  <style>
    @keyframes rotate {{ from {{ transform: rotate(0deg); }} to {{ transform: rotate(360deg); }} }}
    @keyframes pulse {{ 0%, 100% {{ opacity: 0.3; }} 50% {{ opacity: 1; }} }}
    @keyframes scan {{ 0% {{ transform: translateY(-160px); }} 100% {{ transform: translateY(160px); }} }}
    .rot {{ transform-origin: center; animation: rotate 10s linear infinite; }}
    .rot-rev {{ transform-origin: center; animation: rotate 15s linear infinite reverse; }}
    .pulse {{ animation: pulse 2s ease-in-out infinite; }}
  </style>
  <rect width="320" height="320" fill="{COLORS['bg']}" rx="20"/>
  
  <!-- Grid -->
  <path d="M0 160 H320 M160 0 V320" stroke="white" stroke-width="0.5" opacity="0.1"/>
  <circle cx="160" cy="160" r="150" fill="none" stroke="{color}" stroke-width="1" stroke-dasharray="5,5" opacity="0.2"/>
  
  <!-- Rotating Elements -->
  <g class="rot">
    <circle cx="160" cy="160" r="120" fill="none" stroke="{color}" stroke-width="2" stroke-dasharray="100,20"/>
    <circle cx="280" cy="160" r="5" fill="{color}"/>
  </g>
  
  <g class="rot-rev">
    <circle cx="160" cy="160" r="90" fill="none" stroke="{color}" stroke-width="1" stroke-dasharray="10,10"/>
    <rect x="245" y="155" width="10" height="10" fill="{color}" opacity="0.5"/>
  </g>
  
  <!-- Center Piece -->
  <circle cx="160" cy="160" r="40" fill="none" stroke="{color}" stroke-width="4" class="pulse"/>
  <path d="M140 160 L160 140 L180 160 L160 180 Z" fill="{color}"/>
  
  <!-- Text -->
  <text x="160" y="290" text-anchor="middle" font-family="monospace" font-size="14" fill="{color}" font-weight="bold">{label}</text>
  <text x="160" y="305" text-anchor="middle" font-family="monospace" font-size="10" fill="{color}" opacity="0.5">VIRTUAL_OS_CORE_v1.5</text>
</svg>"""
    with open(f"assets/readme/anims/{filename}.svg", "w") as f:
        f.write(svg)

def gen_cinematic_section(filename, title, subtitle, color, image_seed):
    # Simulating 3D with skewed layers and gradients
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="400" viewBox="0 0 1000 400">
  <style>
    @keyframes slide {{ 0% {{ background-position: 0% 50%; }} 100% {{ background-position: 100% 50%; }} }}
    @keyframes float {{ 0%, 100% {{ transform: translateY(0px); }} 50% {{ transform: translateY(-10px); }} }}
    .float {{ animation: float 4s ease-in-out infinite; }}
  </style>
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:{COLORS['bg']};stop-opacity:1" />
      <stop offset="100%" style="stop-color:{color};stop-opacity:0.1" />
    </linearGradient>
    <clipPath id="round">
      <rect width="1000" height="400" rx="40"/>
    </clipPath>
  </defs>
  
  <rect width="1000" height="400" fill="{COLORS['bg']}" rx="40"/>
  
  <!-- Background Image with 3D feel -->
  <g clip-path="url(#round)">
    <image href="https://picsum.photos/seed/{image_seed}/1200/600" width="1200" height="600" x="-100" y="-100" opacity="0.4">
      <animateTransform attributeName="transform" type="translate" from="-50 -50" to="50 50" dur="20s" repeatCount="indefinite" />
    </image>
  </g>
  
  <!-- Overlay Gradients -->
  <rect width="1000" height="400" fill="url(#grad)" rx="40" opacity="0.8"/>
  
  <!-- Technical Frame -->
  <rect x="20" y="20" width="960" height="360" rx="30" fill="none" stroke="{color}" stroke-width="2" opacity="0.3"/>
  <path d="M20 100 H980 M20 300 H980" stroke="{color}" stroke-width="0.5" opacity="0.2"/>
  
  <!-- Content -->
  <g class="float">
    <text x="60" y="180" font-family="sans-serif" font-size="80" font-weight="900" fill="white" style="letter-spacing:-2px">{title}</text>
    <text x="60" y="230" font-family="monospace" font-size="20" fill="{color}" font-weight="bold" opacity="0.8">{subtitle}</text>
  </g>
  
  <!-- Corner Accents -->
  <path d="M20 60 V20 H60" fill="none" stroke="{color}" stroke-width="4"/>
  <path d="M940 20 H980 V60" fill="none" stroke="{color}" stroke-width="4"/>
  <path d="M20 340 V380 H60" fill="none" stroke="{color}" stroke-width="4"/>
  <path d="M940 380 H980 V340" fill="none" stroke="{color}" stroke-width="4"/>
  
  <!-- Data Stream Simulation -->
  <rect x="800" y="50" width="150" height="300" fill="black" opacity="0.3" rx="10"/>
  <g font-family="monospace" font-size="8" fill="{color}" opacity="0.6">
    <text x="810" y="70">SYS_LOG_INIT...</text>
    <text x="810" y="85">NODE_01: ACTIVE</text>
    <text x="810" y="100">LEDGER_SYNC: 100%</text>
    <text x="810" y="115">PROOF_GEN: OK</text>
    <text x="810" y="130">----------------</text>
    <text x="810" y="145">TRILUXIA_v2.4</text>
    <text x="810" y="160">UPTIME: 99.99%</text>
  </g>
</svg>"""
    with open(f"assets/readme/sections/{filename}.svg", "w") as f:
        f.write(svg)

def gen_readme():
    content = f"""# 🧠 LinuxIA — Proof-First Agent Orchestration

<p align="center">
  <img src="assets/readme/sections/vision.svg" width="1000" alt="LinuxIA Vision" />
</p>

> **LinuxIA n’est pas un projet. C’est un organisme informatique distribué.**
> Chaque action laisse une preuve. Chaque agent a un rôle. Chaque VM est un organe.

---

## 🌌 Architecture & Vision

<p align="center">
  <img src="assets/readme/sections/architecture.svg" width="1000" alt="Architecture" />
</p>

LinuxIA est un framework d’orchestration multi-machines, orienté preuve, conçu pour transformer l'infrastructure en un système nerveux vérifiable.

- **Orchestration**: Proxmox VE 9.x + GPU Passthrough.
- **État Global**: Logs JSONL événementiels immuables.
- **Agents**: TriluxIA services pilotés par systemd.

---

## 🧩 Hub d'Animations (Real-time Status)

<p align="center">
  <img src="assets/readme/anims/proxmox.svg" width="310" />
  <img src="assets/readme/anims/matrix.svg" width="310" />
  <img src="assets/readme/anims/cyber.svg" width="310" />
</p>

---

## 🤖 Agents & Intelligence

<p align="center">
  <img src="assets/readme/sections/agents.svg" width="1000" alt="Agents" />
</p>

Les agents **TriluxIA** et **ChromIAlux** coordonnent le cycle de vie des services via un Ledger JSONL asynchrone.

| Agent | Rôle | Statut |
| :--- | :--- | :--- |
| **Builder** | Déploiement & Synthèse | `ACTIVE` |
| **Sentinel** | Surveillance & Health | `ACTIVE` |
| **Auditor** | Vérification de Preuve | `ACTIVE` |
| **Archivist** | Documentation Dynamique | `ACTIVE` |

---

## 🛡️ Proof & Security

<p align="center">
  <img src="assets/readme/sections/proof.svg" width="1000" alt="Proof" />
</p>

**No change without evidence.** Chaque commit déclenche une validation d'intégrité.

---

## 🧱 Infrastructure & Storage

<p align="center">
  <img src="assets/readme/sections/infra.svg" width="1000" alt="Infra" />
</p>

---

<p align="center">
  <img src="assets/readme/anims/nasa.svg" width="120" />
  <br/>
  <sub>© 2026 LINUXIA PROJECT • MISSION CONTROL v1.5.0</sub>
</p>
"""
    with open("README_GITHUB.md", "w") as f:
        f.write(content)

if __name__ == "__main__":
    create_dir_structure()
    
    # Hub Anims
    gen_hub_animation("proxmox", COLORS["proxmox"], "PROXMOX_CORE")
    gen_hub_animation("matrix", COLORS["matrix"], "MATRIX_SYNC")
    gen_hub_animation("cyber", COLORS["cyber"], "CYBER_LINK")
    gen_hub_animation("nasa", COLORS["nasa_red"], "NASA_MISSION")
    
    # Sections
    gen_cinematic_section("vision", "VISION", "PROOF-FIRST OPERATIONS", COLORS["proxmox"], "linuxia1")
    gen_cinematic_section("architecture", "ARCHITECTURE", "MULTI-VM ORCHESTRATION", COLORS["cyber"], "linuxia2")
    gen_cinematic_section("agents", "AGENTS", "TRILUXIA COORDINATION", COLORS["matrix"], "linuxia3")
    gen_cinematic_section("proof", "PROOF", "IMMUTABLE EVIDENCE", COLORS["proxmox"], "linuxia4")
    gen_cinematic_section("infra", "INFRASTRUCTURE", "REPRODUCIBLE STACK", COLORS["cyber"], "linuxia5")
    
    gen_readme()
    print("GitHub assets generated successfully.")
