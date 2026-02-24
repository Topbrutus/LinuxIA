import React from 'react';
import { motion } from 'framer-motion';
import { 
  Network, 
  FileText, 
  BookOpen, 
  Activity, 
  Copy, 
  CheckCircle, 
  Brain, 
  Lock, 
  Box 
} from 'lucide-react';

const COLORS = {
  proxmox: '#ff6a00',
  matrix: '#00ff7b',
  cyber: '#00b3ff',
};

interface Feature {
  title: string;
  description: string;
  icon: any;
  accent: string;
  id: string;
}

const features: Feature[] = [
  { 
    id: 'ORCH',
    title: "Orchestration", 
    description: "Proxmox VE 9.x orchestration with GPU passthrough and multi-node support.", 
    icon: Network, 
    accent: COLORS.cyber 
  },
  { 
    id: 'AUDT',
    title: "Audit", 
    description: "Immutable JSONL event logs providing a complete audit trail of every action.", 
    icon: FileText, 
    accent: COLORS.proxmox 
  },
  { 
    id: 'DOCS',
    title: "Auto-Documentation", 
    description: "Dynamic documentation generated and updated by specialized Archivist agents.", 
    icon: BookOpen, 
    accent: COLORS.matrix 
  },
  { 
    id: 'SUPV',
    title: "Supervision", 
    description: "Real-time monitoring and automated health checks performed by Sentinel.", 
    icon: Activity, 
    accent: COLORS.cyber 
  },
  { 
    id: 'REPL',
    title: "Replication", 
    description: "High-availability clustering and ZFS-based data replication across nodes.", 
    icon: Copy, 
    accent: COLORS.proxmox 
  },
  { 
    id: 'INTG',
    title: "Integrity Check", 
    description: "Continuous system verification via automated systemd timers and health scripts.", 
    icon: CheckCircle, 
    accent: COLORS.matrix 
  },
  { 
    id: 'AI_I',
    title: "AI Integration", 
    description: "Leveraging Copilot and ChatGPT as co-architects for logic audit and generation.", 
    icon: Brain, 
    accent: COLORS.cyber 
  },
  { 
    id: 'CRYP',
    title: "Crypto-Proof", 
    description: "Cryptographic evidence and signatures for every system modification.", 
    icon: Lock, 
    accent: COLORS.proxmox 
  },
  { 
    id: 'REPR',
    title: "Reproducible Architecture", 
    description: "Standardized VM Factory for template-based, predictable deployments.", 
    icon: Box, 
    accent: COLORS.matrix 
  },
];

const FeatureCard = ({ feature, index }: { feature: Feature, index: number }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true }}
    transition={{ delay: index * 0.05 }}
    whileHover={{ y: -8 }}
    className="relative p-6 border border-white/5 bg-white/[0.02] rounded-2xl flex flex-col gap-5 group overflow-hidden"
  >
    {/* Technical Background Element */}
    <div className="absolute top-0 right-0 p-2 opacity-10 group-hover:opacity-20 transition-opacity">
      <span className="text-[40px] font-black font-mono select-none">{feature.id}</span>
    </div>

    {/* Icon Hub */}
    <div className="relative w-14 h-14 flex items-center justify-center">
      <div 
        className="absolute inset-0 rounded-xl opacity-20 blur-sm group-hover:opacity-40 transition-opacity" 
        style={{ backgroundColor: feature.accent }} 
      />
      <div 
        className="relative z-10 p-3 rounded-xl border border-white/10 bg-black/40" 
        style={{ color: feature.accent }}
      >
        <feature.icon className="w-7 h-7" />
      </div>
    </div>

    {/* Content */}
    <div className="relative z-10">
      <div className="flex items-center gap-2 mb-2">
        <div className="w-1 h-4 rounded-full" style={{ backgroundColor: feature.accent }} />
        <h5 className="text-xl font-bold tracking-tight text-white/90 group-hover:text-white transition-colors">
          {feature.title}
        </h5>
      </div>
      <p className="text-sm text-white/50 leading-relaxed font-light group-hover:text-white/70 transition-colors">
        {feature.description}
      </p>
    </div>

    {/* Bottom Meta */}
    <div className="mt-auto pt-4 border-t border-white/5 flex justify-between items-center">
      <span className="text-[10px] font-mono text-white/20 uppercase tracking-widest">
        Status: <span style={{ color: feature.accent }} className="opacity-80">Operational</span>
      </span>
      <div className="w-1.5 h-1.5 rounded-full animate-pulse" style={{ backgroundColor: feature.accent }} />
    </div>

    {/* Corner Accent */}
    <div 
      className="absolute top-0 left-0 w-1 h-8 opacity-0 group-hover:opacity-100 transition-opacity" 
      style={{ backgroundColor: feature.accent }} 
    />
  </motion.div>
);

export const CoreFeatures: React.FC = () => {
  return (
    <section className="mt-40 relative">
      {/* Background Glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[400px] bg-proxmox/5 blur-[120px] rounded-full pointer-events-none" />

      <div className="text-center mb-24 relative z-10">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
        >
          <h2 className="text-5xl md:text-6xl font-black uppercase tracking-tighter mb-4">
            Core Capabilities
          </h2>
          <div className="flex items-center justify-center gap-4">
            <div className="h-[1px] w-12 bg-white/10" />
            <p className="text-white/40 font-mono text-xs uppercase tracking-[0.3em]">
              System Nervous System Modules
            </p>
            <div className="h-[1px] w-12 bg-white/10" />
          </div>
        </motion.div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 relative z-10">
        {features.map((feature, index) => (
          <FeatureCard key={feature.id} feature={feature} index={index} />
        ))}
      </div>
    </section>
  );
};
