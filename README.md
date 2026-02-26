<div align="center">
<svg width="600" height="600" viewBox="0 0 600 600" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="svg-title svg-desc">
  <title id="svg-title">LinuxIA — Proof-First Agent Orchestration</title>
  <desc id="svg-desc">Animated diagram of LinuxIA: four architecture layers (L0 Proxmox Orchestrateur, L1 VM100 Usine, L2 Outils Duplicables, L3 GPU Workers), a signal trace connecting them, storage tiers (tmpfs RAM, NVMe Hot, SATA Cold, zRAM), the Proof-First pipeline (PLAN, EXECUTE, VERIFY, CRITIQUE, LOG), and a live status footer.</desc>
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0b0f14"/>
      <stop offset="1" stop-color="#111827"/>
    </linearGradient>
    <linearGradient id="orange" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ff7a18"/>
      <stop offset="1" stop-color="#ffb000"/>
    </linearGradient>
    <linearGradient id="green" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#00ff9d" stop-opacity="0"/>
      <stop offset="0.3" stop-color="#00ff9d" stop-opacity="0.8"/>
      <stop offset="0.7" stop-color="#ff7a18" stop-opacity="0.8"/>
      <stop offset="1" stop-color="#ff7a18" stop-opacity="0"/>
    </linearGradient>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="6" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="glow2" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="10" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <pattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse">
      <path d="M30 0H0V30" fill="none" stroke="#ffffff" stroke-opacity="0.04" stroke-width="1"/>
    </pattern>
    <style>
      .title { font: 900 52px ui-sans-serif, system-ui, Arial; letter-spacing: 3px; }
      .sub   { font: 500 13px ui-sans-serif, system-ui, Arial; letter-spacing: 0.5px; }
      .mono  { font: 600 11px ui-monospace, 'Courier New', monospace; letter-spacing: 0.3px; }
      .layer-label { font: 700 10px ui-monospace, 'Courier New', monospace; }
      .scan  { animation: scan 5s linear infinite; }
      .pulse { animation: pulse 2.8s ease-in-out infinite; }
      .drift { animation: drift 7s ease-in-out infinite; }
      .flow  { fill: none; stroke: url(#green); stroke-width: 2.5; stroke-linecap: round;
               stroke-dasharray: 50 450; animation: flow 3.2s linear infinite; }
      .wire  { fill: none; stroke: #ffffff; stroke-opacity: 0.08; stroke-width: 1; }
      .dot   { animation: dotpulse 1.8s ease-in-out infinite; transform-origin: 50% 50%; }
      .border-anim { animation: borderGlow 4s ease-in-out infinite; }
      .corner-blink { animation: blink 2s step-end infinite; }
      @keyframes scan    { 0%{transform:translateY(-40px)} 100%{transform:translateY(640px)} }
      @keyframes pulse   { 0%,100%{opacity:0.7} 50%{opacity:1} }
      @keyframes drift   { 0%,100%{transform:translate(0,0)} 50%{transform:translate(8px,-5px)} }
      @keyframes flow    { from{stroke-dashoffset:500} to{stroke-dashoffset:0} }
      @keyframes dotpulse{ 0%,100%{transform:scale(1);opacity:0.5} 50%{transform:scale(1.4);opacity:1} }
      @keyframes borderGlow { 0%,100%{stroke-opacity:0.35} 50%{stroke-opacity:0.9} }
      @keyframes blink   { 0%,100%{opacity:1} 50%{opacity:0.2} }
      @media (prefers-reduced-motion: reduce) {
        .scan,.pulse,.drift,.flow,.dot,.border-anim,.corner-blink { animation: none; }
      }
    </style>
  </defs>

  <!-- Background -->
  <rect width="600" height="600" rx="24" fill="url(#bg)"/>
  <rect width="600" height="600" rx="24" fill="url(#grid)"/>

  <!-- Animated border -->
  <rect x="3" y="3" width="594" height="594" rx="22" fill="none" stroke="url(#orange)" stroke-width="2" class="border-anim"/>

  <!-- Scan line -->
  <g class="scan" opacity="0.07">
    <rect x="0" y="0" width="600" height="50" rx="0" fill="#ff7a18"/>
  </g>

  <!-- Orbit ellipses (right side) -->
  <g opacity="0.6">
    <ellipse cx="440" cy="180" rx="130" ry="46" fill="none" stroke="#ffffff" stroke-opacity="0.07" stroke-width="1"/>
    <ellipse cx="440" cy="180" rx="100" ry="34" fill="none" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1"
             stroke-dasharray="6 8"/>
  </g>

  <!-- Drifting orb -->
  <g class="drift" filter="url(#glow2)">
    <circle cx="500" cy="130" r="9" fill="url(#orange)" opacity="0.95"/>
    <circle cx="500" cy="130" r="22" fill="none" stroke="#ff7a18" stroke-opacity="0.2" stroke-width="1.5"/>
    <circle cx="500" cy="130" r="36" fill="none" stroke="#ff7a18" stroke-opacity="0.08" stroke-width="1"/>
  </g>

  <!-- TITLE -->
  <text x="50" y="116" class="title" fill="#ffffff">LINUXIA</text>
  <rect x="50" y="128" width="320" height="5" rx="2.5" fill="url(#orange)" class="pulse"/>

  <!-- Subtitle -->
  <text x="50" y="158" class="sub" fill="#c9d1d9" opacity="0.9">Proof-First Agent Orchestration Framework</text>
  <text x="50" y="176" class="mono" fill="#8b949e">Proxmox VE · KVM + LXC · Multi-Layer · Low-Latency</text>

  <!-- Divider -->
  <line x1="50" y1="196" x2="550" y2="196" stroke="#ffffff" stroke-opacity="0.08" stroke-width="1"/>

  <!-- Architecture layers (4 boxes) -->
  <!-- L0 -->
  <g filter="url(#glow)">
    <rect x="50" y="216" width="112" height="62" rx="10" fill="#0b0f14" stroke="#ff7a18" stroke-opacity="0.5" stroke-width="1.2"/>
    <text x="106" y="240" class="layer-label" fill="#ff7a18" text-anchor="middle">L0</text>
    <text x="106" y="254" class="mono" fill="#c9d1d9" text-anchor="middle" opacity="0.9">Proxmox</text>
    <text x="106" y="268" class="mono" fill="#8b949e" text-anchor="middle">Orchestrateur</text>
  </g>
  <!-- L1 -->
  <g filter="url(#glow)">
    <rect x="196" y="216" width="112" height="62" rx="10" fill="#0b0f14" stroke="#00ff9d" stroke-opacity="0.45" stroke-width="1.2"/>
    <text x="252" y="240" class="layer-label" fill="#00ff9d" text-anchor="middle">L1</text>
    <text x="252" y="254" class="mono" fill="#c9d1d9" text-anchor="middle" opacity="0.9">VM100</text>
    <text x="252" y="268" class="mono" fill="#8b949e" text-anchor="middle">Usine / Factory</text>
  </g>
  <!-- L2 -->
  <g filter="url(#glow)">
    <rect x="342" y="216" width="112" height="62" rx="10" fill="#0b0f14" stroke="#7c3aed" stroke-opacity="0.55" stroke-width="1.2"/>
    <text x="398" y="240" class="layer-label" fill="#a78bfa" text-anchor="middle">L2</text>
    <text x="398" y="254" class="mono" fill="#c9d1d9" text-anchor="middle" opacity="0.9">Outils</text>
    <text x="398" y="268" class="mono" fill="#8b949e" text-anchor="middle">Duplicables</text>
  </g>
  <!-- L3 -->
  <g filter="url(#glow)">
    <rect x="488" y="216" width="62" height="62" rx="10" fill="#0b0f14" stroke="#0ea5e9" stroke-opacity="0.5" stroke-width="1.2"/>
    <text x="519" y="240" class="layer-label" fill="#38bdf8" text-anchor="middle">L3</text>
    <text x="519" y="254" class="mono" fill="#c9d1d9" text-anchor="middle" opacity="0.9">GPU</text>
    <text x="519" y="268" class="mono" fill="#8b949e" text-anchor="middle">Workers</text>
  </g>

  <!-- Arrows between boxes -->
  <g opacity="0.5">
    <line x1="162" y1="247" x2="193" y2="247" stroke="url(#orange)" stroke-width="1.5"/>
    <polygon points="193,243 196,247 193,251" fill="#ff7a18" opacity="0.7"/>
    <line x1="308" y1="247" x2="339" y2="247" stroke="#00ff9d" stroke-width="1.5" stroke-opacity="0.6"/>
    <polygon points="339,243 342,247 339,251" fill="#00ff9d" opacity="0.6"/>
    <line x1="454" y1="247" x2="485" y2="247" stroke="#a78bfa" stroke-width="1.5" stroke-opacity="0.6"/>
    <polygon points="485,243 488,247 485,251" fill="#a78bfa" opacity="0.6"/>
  </g>

  <!-- Divider -->
  <line x1="50" y1="300" x2="550" y2="300" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1"/>

  <!-- Matrix trace / signal wire -->
  <path class="wire" d="M50 340 C140 310, 210 310, 300 340 C390 370, 460 370, 550 340"/>
  <path class="flow" d="M50 340 C140 310, 210 310, 300 340 C390 370, 460 370, 550 340"/>

  <!-- Signal dots -->
  <circle class="dot" cx="50" cy="340" r="5" fill="#ff7a18"/>
  <circle class="dot" cx="300" cy="340" r="5" fill="#00ff9d" style="animation-delay:.4s"/>
  <circle class="dot" cx="550" cy="340" r="5" fill="#38bdf8" style="animation-delay:.8s"/>

  <!-- Signal labels -->
  <text x="40" y="328" class="mono" fill="#8b949e">L0</text>
  <text x="285" y="328" class="mono" fill="#8b949e">L1&#x2192;L2</text>
  <text x="535" y="328" class="mono" fill="#8b949e">L3</text>

  <!-- Divider -->
  <line x1="50" y1="372" x2="550" y2="372" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1"/>

  <!-- Storage tiers -->
  <text x="50" y="398" class="mono" fill="#8b949e">STORAGE TIERS</text>
  <g>
    <rect x="50" y="408" width="80" height="22" rx="5" fill="#ff7a18" fill-opacity="0.15" stroke="#ff7a18" stroke-opacity="0.4" stroke-width="1"/>
    <text x="90" y="423" class="mono" fill="#ffb000" text-anchor="middle">tmpfs RAM</text>
  </g>
  <g>
    <rect x="144" y="408" width="72" height="22" rx="5" fill="#00ff9d" fill-opacity="0.1" stroke="#00ff9d" stroke-opacity="0.35" stroke-width="1"/>
    <text x="180" y="423" class="mono" fill="#00ff9d" text-anchor="middle">NVMe Hot</text>
  </g>
  <g>
    <rect x="230" y="408" width="68" height="22" rx="5" fill="#38bdf8" fill-opacity="0.08" stroke="#38bdf8" stroke-opacity="0.3" stroke-width="1"/>
    <text x="264" y="423" class="mono" fill="#38bdf8" text-anchor="middle">SATA Cold</text>
  </g>
  <g>
    <rect x="312" y="408" width="52" height="22" rx="5" fill="#a78bfa" fill-opacity="0.1" stroke="#a78bfa" stroke-opacity="0.35" stroke-width="1"/>
    <text x="338" y="423" class="mono" fill="#a78bfa" text-anchor="middle">zRAM</text>
  </g>

  <!-- Divider -->
  <line x1="50" y1="446" x2="550" y2="446" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1"/>

  <!-- Proof-First pipeline -->
  <text x="50" y="472" class="mono" fill="#8b949e">PROOF-FIRST PIPELINE</text>
  <g>
    <rect x="50" y="480" width="56" height="20" rx="4" fill="#0b0f14" stroke="#ff7a18" stroke-opacity="0.5" stroke-width="1"/>
    <text x="78" y="494" class="mono" fill="#ff7a18" text-anchor="middle">PLAN</text>
  </g>
  <text x="108" y="493" class="mono" fill="#ff7a18" opacity="0.5">&#x2192;</text>
  <g>
    <rect x="122" y="480" width="72" height="20" rx="4" fill="#0b0f14" stroke="#00ff9d" stroke-opacity="0.45" stroke-width="1"/>
    <text x="158" y="494" class="mono" fill="#00ff9d" text-anchor="middle">EXECUTE</text>
  </g>
  <text x="196" y="493" class="mono" fill="#00ff9d" opacity="0.5">&#x2192;</text>
  <g>
    <rect x="210" y="480" width="62" height="20" rx="4" fill="#0b0f14" stroke="#38bdf8" stroke-opacity="0.45" stroke-width="1"/>
    <text x="241" y="494" class="mono" fill="#38bdf8" text-anchor="middle">VERIFY</text>
  </g>
  <text x="274" y="493" class="mono" fill="#38bdf8" opacity="0.5">&#x2192;</text>
  <g>
    <rect x="288" y="480" width="72" height="20" rx="4" fill="#0b0f14" stroke="#a78bfa" stroke-opacity="0.45" stroke-width="1"/>
    <text x="324" y="494" class="mono" fill="#a78bfa" text-anchor="middle">CRITIQUE</text>
  </g>
  <text x="362" y="493" class="mono" fill="#a78bfa" opacity="0.5">&#x2192;</text>
  <g>
    <rect x="376" y="480" width="52" height="20" rx="4" fill="#0b0f14" stroke="#ffb000" stroke-opacity="0.5" stroke-width="1"/>
    <text x="402" y="494" class="mono" fill="#ffb000" text-anchor="middle">LOG</text>
  </g>

  <!-- Divider -->
  <line x1="50" y1="516" x2="550" y2="516" stroke="#ffffff" stroke-opacity="0.06" stroke-width="1"/>

  <!-- Footer status -->
  <circle cx="64" cy="536" r="4" fill="#00ff9d" class="pulse"/>
  <text x="76" y="540" class="mono" fill="#00ff9d">ONLINE</text>
  <text x="144" y="540" class="mono" fill="#8b949e">&#x00B7;  Agents actifs  &#x00B7;  Logs append-only  &#x00B7;  DoD enforced</text>

  <!-- Corner tag -->
  <g class="corner-blink">
    <rect x="468" y="524" width="80" height="20" rx="5" fill="#0b0f14" stroke="#ff7a18" stroke-opacity="0.4" stroke-width="1"/>
    <text x="508" y="538" class="mono" fill="#ffb000" text-anchor="middle">v2 &#x00B7; 2025</text>
  </g>

  <!-- Bottom border accent -->
  <rect x="50" y="570" width="500" height="3" rx="1.5" fill="url(#orange)" class="pulse" opacity="0.6"/>
</svg>
</div>
