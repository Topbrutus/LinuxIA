/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
*/

import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence, useScroll, useTransform } from 'framer-motion';
import { 
  Shield, 
  Cpu, 
  Network, 
  Terminal, 
  Activity, 
  Database, 
  ChevronRight,
  Monitor,
  Lock,
  Layers,
  FileText,
  BookOpen,
  Copy,
  CheckCircle,
  Brain,
  Box
} from 'lucide-react';

import { CoreFeatures } from './components/CoreFeatures';

// --- Constants & Theme ---
const COLORS = {
  proxmox: '#ff6a00',
  matrix: '#00ff7b',
  cyber: '#00b3ff',
  bgDeep: '#050505',
  glass: 'rgba(255, 255, 255, 0.03)',
  border: 'rgba(255, 255, 255, 0.1)'
};

// --- Components ---

const Scanlines = () => (
  <div className="absolute inset-0 pointer-events-none z-50 opacity-[0.03]" 
       style={{ background: 'linear-gradient(to bottom, transparent 50%, #fff 51%)', backgroundSize: '100% 4px' }} />
);

const TechGrid = () => (
  <div className="absolute inset-0 pointer-events-none opacity-20"
       style={{ 
         backgroundImage: `linear-gradient(${COLORS.border} 1px, transparent 1px), linear-gradient(90deg, ${COLORS.border} 1px, transparent 1px)`,
         backgroundSize: '40px 40px'
       }} />
);

const SectionFrame = ({ children, title, accent = COLORS.cyber }: { children: React.ReactNode, title: string, accent?: string }) => (
  <div className="relative p-8 border border-white/10 bg-black/40 backdrop-blur-md rounded-2xl overflow-hidden group">
    {/* Corner Accents */}
    <div className="absolute top-0 left-0 w-8 h-8 border-t-2 border-l-2" style={{ borderColor: accent }} />
    <div className="absolute top-0 right-0 w-8 h-8 border-t-2 border-r-2 opacity-30" style={{ borderColor: accent }} />
    <div className="absolute bottom-0 left-0 w-8 h-8 border-b-2 border-l-2 opacity-30" style={{ borderColor: accent }} />
    <div className="absolute bottom-0 right-0 w-8 h-8 border-b-2 border-r-2" style={{ borderColor: accent }} />
    
    <div className="flex items-center gap-3 mb-6">
      <div className="w-2 h-6" style={{ backgroundColor: accent }} />
      <h3 className="text-xl font-bold tracking-widest uppercase font-mono">{title}</h3>
    </div>
    
    {children}
  </div>
);

const ParallaxImage = ({ src, accent, id }: { src: string, accent: string, id: string }) => {
  const containerRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"]
  });

  // Map scroll progress to vertical movement (-100 to -50 range to keep it centered in the 450px view)
  const y = useTransform(scrollYProgress, [0, 1], [-100, -20]);

  return (
    <div ref={containerRef} className="relative aspect-video rounded-xl overflow-hidden border border-white/5">
      <svg viewBox="0 0 800 450" className="w-full h-full">
        <defs>
          <clipPath id={`clip-${id}`}>
            <rect x="10" y="10" width="780" height="430" rx="20" />
          </clipPath>
        </defs>
        <motion.image 
          href={src} 
          width="800" 
          height="550" // Taller to allow for parallax movement
          y={y}
          preserveAspectRatio="xMidYMid slice"
          clipPath={`url(#clip-${id})`}
        />
        {/* Technical Overlays */}
        <rect x="0" y="0" width="800" height="450" fill="none" stroke={accent} strokeWidth="2" opacity="0.2" />
        <g opacity="0.5" style={{ color: accent }}>
          <text x="30" y="40" fill="currentColor" fontSize="12" fontFamily="monospace">REF_ID: {id.toUpperCase()}_001</text>
          <text x="30" y="60" fill="currentColor" fontSize="10" fontFamily="monospace">LATENCY: 12ms</text>
          <rect x="740" y="20" width="40" height="40" fill="none" stroke="currentColor" strokeWidth="1" />
          <path d="M 750 30 L 770 50 M 770 30 L 750 50" stroke="currentColor" strokeWidth="1" />
        </g>
      </svg>
    </div>
  );
};

const App: React.FC = () => {
  const [activeSection, setActiveSection] = useState(0);

  const sections = [
    {
      id: 'vision',
      title: 'Vision',
      subtitle: 'Proof-First Agent Ops',
      description: 'Une infrastructure qui produit sa propre preuve. Chaque action, chaque changement, est documenté par un artefact immuable.',
      icon: <Shield className="w-12 h-12" />,
      accent: COLORS.proxmox,
      image: 'https://picsum.photos/seed/linuxia1/800/450'
    },
    {
      id: 'architecture',
      title: 'Architecture',
      subtitle: 'Multi-VM Orchestration',
      description: 'Déploiement distribué sur Proxmox VE. Isolation totale, redondance ZFS et orchestration par agents systemd.',
      icon: <Layers className="w-12 h-12" />,
      accent: COLORS.cyber,
      image: 'https://picsum.photos/seed/linuxia2/800/450'
    },
    {
      id: 'agents',
      title: 'Agents',
      subtitle: 'TriluxIA / ChromIAlux',
      description: 'Des agents intelligents pilotant le cycle de vie des services. Communication asynchrone via Ledger JSONL.',
      icon: <Cpu className="w-12 h-12" />,
      accent: COLORS.matrix,
      image: 'https://picsum.photos/seed/linuxia3/800/450'
    },
    {
      id: 'proof',
      title: 'Proof',
      subtitle: 'Immutable Evidence',
      description: 'Auditabilité totale. Chaque commit GitHub déclenche une vérification de plateforme avec preuve cryptographique.',
      icon: <Lock className="w-12 h-12" />,
      accent: COLORS.proxmox,
      image: 'https://picsum.photos/seed/linuxia4/800/450'
    }
  ];

  return (
    <div className="min-h-screen bg-[#050505] text-white font-sans selection:bg-proxmox/30 overflow-x-hidden">
      <Scanlines />
      <TechGrid />

      {/* --- Navigation Header --- */}
      <header className="fixed top-0 left-0 right-0 z-[100] border-b border-white/5 bg-black/80 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-proxmox flex items-center justify-center rounded-lg rotate-45 group hover:rotate-0 transition-transform duration-500">
              <Terminal className="w-6 h-6 -rotate-45 group-hover:rotate-0 transition-transform duration-500" />
            </div>
            <div>
              <h1 className="text-2xl font-black tracking-tighter uppercase">LinuxIA</h1>
              <p className="text-[10px] font-mono text-matrix uppercase tracking-[0.2em] -mt-1">Mission Control v1.5.0</p>
            </div>
          </div>

          <nav className="hidden md:flex items-center gap-8">
            {sections.map((s, i) => (
              <button 
                key={s.id}
                onClick={() => setActiveSection(i)}
                className={`text-xs font-mono uppercase tracking-widest transition-colors ${activeSection === i ? 'text-proxmox' : 'text-white/40 hover:text-white'}`}
              >
                {s.title}
              </button>
            ))}
          </nav>

          <div className="flex items-center gap-4">
            <div className="flex flex-col items-end">
              <span className="text-[10px] font-mono text-white/40 uppercase">System Status</span>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-matrix animate-pulse" />
                <span className="text-xs font-mono text-matrix uppercase">Operational</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      <main className="pt-32 pb-20 px-6 max-w-7xl mx-auto">
        {/* --- Hero Section --- */}
        <section className="mb-32 text-center relative">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <h2 className="text-7xl md:text-9xl font-black tracking-tighter uppercase mb-6 bg-gradient-to-b from-white to-white/20 bg-clip-text text-transparent">
              LinuxIA
            </h2>
            <p className="text-xl md:text-2xl text-white/60 max-w-2xl mx-auto font-light leading-relaxed">
              L'orchestration d'agents nouvelle génération. 
              <span className="text-proxmox font-medium"> La preuve avant tout.</span>
            </p>
          </motion.div>

          {/* Animated SVG Hero Element */}
          <div className="mt-16 relative h-64 flex items-center justify-center">
            <svg viewBox="0 0 400 200" className="w-full max-w-lg h-full">
              <defs>
                <linearGradient id="heroGrad" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor={COLORS.proxmox} />
                  <stop offset="50%" stopColor={COLORS.matrix} />
                  <stop offset="100%" stopColor={COLORS.cyber} />
                </linearGradient>
              </defs>
              <motion.path
                d="M 50 100 Q 200 20 350 100 T 50 100"
                fill="none"
                stroke="url(#heroGrad)"
                strokeWidth="2"
                initial={{ pathLength: 0, opacity: 0 }}
                animate={{ pathLength: 1, opacity: 1 }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              />
              <circle cx="200" cy="100" r="40" fill="none" stroke={COLORS.cyber} strokeWidth="0.5" className="animate-pulse" />
              <circle cx="200" cy="100" r="60" fill="none" stroke={COLORS.matrix} strokeWidth="0.5" opacity="0.3" />
            </svg>
          </div>
        </section>

        {/* --- Symmetric Content Blocks --- */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
          {sections.map((section, index) => (
            <motion.div
              key={section.id}
              initial={{ opacity: 0, x: index % 2 === 0 ? -50 : 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
            >
              <SectionFrame title={section.title} accent={section.accent}>
                <div className="flex flex-col gap-6">
                  <div className="flex items-start gap-4">
                    <div className="p-3 bg-white/5 rounded-xl" style={{ color: section.accent }}>
                      {section.icon}
                    </div>
                    <div>
                      <motion.h4 
                        whileHover={{ x: 5, color: section.accent }}
                        transition={{ type: "spring", stiffness: 300 }}
                        className="text-2xl font-bold mb-2 cursor-default"
                      >
                        {section.subtitle}
                      </motion.h4>
                      <p className="text-white/60 leading-relaxed">{section.description}</p>
                    </div>
                  </div>
                  
                  {/* Image inside SVG Frame with Parallax */}
                  <ParallaxImage src={section.image} accent={section.accent} id={section.id} />

                  <button className="flex items-center gap-2 text-xs font-mono uppercase tracking-widest group" style={{ color: section.accent }}>
                    Explore Module <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                  </button>
                </div>
              </SectionFrame>
            </motion.div>
          ))}
        </div>

        {/* --- Core Features Section --- */}
        <CoreFeatures />

        {/* --- Gallery Section --- */}
        <section className="mt-40">
          <div className="text-center mb-20">
            <h2 className="text-5xl font-black uppercase tracking-tighter mb-4">Gallery</h2>
            <div className="w-24 h-1 bg-proxmox mx-auto" />
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
              <motion.div
                key={i}
                whileHover={{ scale: 1.05 }}
                className="relative aspect-square rounded-xl overflow-hidden border border-white/10 group"
              >
                <svg viewBox="0 0 300 300" className="w-full h-full">
                  <clipPath id={`clip-gal-${i}`}>
                    <rect x="5" y="5" width="290" height="290" rx="15" />
                  </clipPath>
                  <image 
                    href={`https://picsum.photos/seed/linuxia_gal_${i}/600/600`} 
                    width="300" 
                    height="300" 
                    preserveAspectRatio="xMidYMid slice"
                    clipPath={`url(#clip-gal-${i})`}
                  />
                  <rect x="0" y="0" width="300" height="300" fill="black" opacity="0.4" className="group-hover:opacity-0 transition-opacity" />
                  <text x="20" y="280" fill="white" fontSize="10" fontFamily="monospace" opacity="0.6">IMG_00{i}.RAW</text>
                </svg>
              </motion.div>
            ))}
          </div>
        </section>
      </main>

      {/* --- Footer --- */}
      <footer className="border-t border-white/5 py-12 px-6 bg-black/40 backdrop-blur-md">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="flex items-center gap-4">
            <Terminal className="w-8 h-8 text-proxmox" />
            <span className="text-sm font-mono text-white/40">© 2026 LINUXIA PROJECT. ALL RIGHTS RESERVED.</span>
          </div>
          
          <div className="flex gap-8">
            <a href="#" className="text-xs font-mono uppercase tracking-widest text-white/40 hover:text-matrix transition-colors">Documentation</a>
            <a href="#" className="text-xs font-mono uppercase tracking-widest text-white/40 hover:text-matrix transition-colors">GitHub</a>
            <a href="#" className="text-xs font-mono uppercase tracking-widest text-white/40 hover:text-matrix transition-colors">Security</a>
          </div>

          <div className="flex items-center gap-6">
            <div className="flex flex-col items-end">
              <span className="text-[10px] font-mono text-white/40 uppercase">Ledger Sync</span>
              <span className="text-xs font-mono text-proxmox uppercase">Verified</span>
            </div>
            <Activity className="w-6 h-6 text-matrix" />
          </div>
        </div>
      </footer>
    </div>
  );
};

export default App;
