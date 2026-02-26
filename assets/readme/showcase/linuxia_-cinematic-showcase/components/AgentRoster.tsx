/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Cpu, Activity, Stethoscope, RefreshCw, AlertCircle, CheckCircle } from "lucide-react";
import {
  generateAvatarImage,
  revokeAvatarUrl,
  type AvatarResult,
} from "../services/sparkImageService";

const COLORS = {
  proxmox: "#ff6a00",
  matrix: "#00ff7b",
  cyber: "#00b3ff",
  bgDeep: "#050505",
};

interface AgentDef {
  id: string;
  name: string;
  role: string;
  description: string;
  accent: string;
  avatarPrompt: string;
}

const AGENTS: AgentDef[] = [
  {
    id: "builder",
    name: "Builder",
    role: "Deployment & Synthesis",
    description:
      "Orchestrates VM provisioning, configuration deployments and infrastructure changes using proof-first methodology.",
    accent: COLORS.cyber,
    avatarPrompt:
      "A futuristic cyberpunk AI agent avatar: a robotic builder with neon blue highlights, circuit board patterns, dark background, cinematic lighting, digital art, 8k resolution",
  },
  {
    id: "sentinel",
    name: "Sentinel",
    role: "Monitoring & Health",
    description:
      "Continuously monitors system health, emits structured JSONL events and triggers automatic remediation workflows.",
    accent: COLORS.matrix,
    avatarPrompt:
      "A futuristic cyberpunk AI agent avatar: a vigilant sentinel robot with neon green scanning beam, dark background, cinematic lighting, digital art, 8k resolution",
  },
  {
    id: "auditor",
    name: "Auditor",
    role: "Proof Verification",
    description:
      "Verifies cryptographic integrity of all system changes, audits JSONL ledgers and flags anomalies in real time.",
    accent: COLORS.proxmox,
    avatarPrompt:
      "A futuristic cyberpunk AI agent avatar: an auditor robot with orange neon glow and holographic data streams, dark background, cinematic lighting, digital art, 8k resolution",
  },
  {
    id: "archivist",
    name: "Archivist",
    role: "Dynamic Documentation",
    description:
      "Generates and maintains living documentation by parsing agent events and synthesizing structured runbooks.",
    accent: COLORS.cyber,
    avatarPrompt:
      "A futuristic cyberpunk AI agent avatar: an archivist robot holding glowing scrolls of code, blue highlights, dark background, cinematic lighting, digital art, 8k resolution",
  },
];

// ─── Diagnostics panel ─────────────────────────────────────────────────────────

interface DiagnosticsState {
  apiReachable: boolean | null;
  tokenPresent: boolean;
  avatarsGenerated: number;
  totalAgents: number;
  lastError: string | null;
}

const DiagnosticsPanel: React.FC<{
  state: DiagnosticsState;
  onClose: () => void;
}> = ({ state, onClose }) => {
  const Row = ({
    label,
    ok,
    value,
  }: {
    label: string;
    ok: boolean | null;
    value?: string;
  }) => (
    <div className="flex items-center justify-between py-2 border-b border-white/5">
      <span className="text-xs font-mono text-white/60">{label}</span>
      <span
        className="text-xs font-mono flex items-center gap-1"
        style={{ color: ok === null ? "#888" : ok ? COLORS.matrix : COLORS.proxmox }}
      >
        {ok === null ? (
          "…"
        ) : ok ? (
          <CheckCircle className="w-3 h-3" />
        ) : (
          <AlertCircle className="w-3 h-3" />
        )}
        {value ?? (ok === null ? "Checking" : ok ? "OK" : "FAIL")}
      </span>
    </div>
  );

  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      className="absolute top-14 right-0 z-50 w-80 bg-black/90 border border-white/10 rounded-2xl p-5 backdrop-blur-xl shadow-2xl"
    >
      <div className="flex items-center justify-between mb-4">
        <h4 className="text-sm font-bold font-mono uppercase tracking-widest text-white">
          System Diagnostics
        </h4>
        <button
          onClick={onClose}
          className="text-white/40 hover:text-white transition-colors text-xs"
        >
          ✕
        </button>
      </div>

      <div className="flex flex-col">
        <Row label="GITHUB_TOKEN present" ok={state.tokenPresent} />
        <Row
          label="Spark API reachable"
          ok={state.apiReachable}
          value={
            state.apiReachable === null
              ? "Checking"
              : state.apiReachable
              ? "Reachable"
              : "Unreachable"
          }
        />
        <Row
          label="Avatars generated"
          ok={state.avatarsGenerated > 0}
          value={`${state.avatarsGenerated} / ${state.totalAgents}`}
        />
      </div>

      {state.lastError && (
        <div className="mt-3 p-3 bg-red-900/20 border border-red-500/20 rounded-lg">
          <p className="text-[10px] font-mono text-red-400 break-all">{state.lastError}</p>
        </div>
      )}

      <p className="text-[10px] font-mono text-white/20 mt-4">
        Spark endpoint: models.inference.ai.azure.com
      </p>
    </motion.div>
  );
};

// ─── Individual agent card ──────────────────────────────────────────────────────

const AgentCard: React.FC<{
  agent: AgentDef;
  avatar: AvatarResult | null;
  loading: boolean;
  error: string | null;
}> = ({ agent, avatar, loading, error }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true }}
    whileHover={{ y: -6 }}
    className="relative p-5 border border-white/10 bg-black/40 backdrop-blur-md rounded-2xl flex flex-col gap-4 group overflow-hidden"
  >
    {/* Corner accent */}
    <div
      className="absolute top-0 left-0 w-1 h-12 opacity-0 group-hover:opacity-100 transition-opacity"
      style={{ backgroundColor: agent.accent }}
    />

    {/* Avatar */}
    <div
      className="relative w-20 h-20 rounded-2xl overflow-hidden border border-white/10 flex-shrink-0 mx-auto"
      style={{ boxShadow: `0 0 24px ${agent.accent}40` }}
    >
      {loading && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/60">
          <RefreshCw
            className="w-6 h-6 animate-spin"
            style={{ color: agent.accent }}
          />
        </div>
      )}

      {!loading && avatar && (
        <img
          src={avatar.objectUrl}
          alt={`${agent.name} avatar`}
          className="w-full h-full object-cover"
          onError={(e) => {
            /* Fallback to fileUrl if objectUrl becomes invalid */
            if (avatar.fileUrl && (e.target as HTMLImageElement).src !== avatar.fileUrl) {
              (e.target as HTMLImageElement).src = avatar.fileUrl;
            }
          }}
        />
      )}

      {!loading && !avatar && (
        <div
          className="absolute inset-0 flex items-center justify-center"
          style={{ backgroundColor: `${agent.accent}20` }}
        >
          <Cpu className="w-8 h-8" style={{ color: agent.accent }} />
        </div>
      )}
    </div>

    {/* Info */}
    <div className="text-center">
      <h4 className="text-lg font-bold text-white mb-1">{agent.name}</h4>
      <p
        className="text-xs font-mono uppercase tracking-widest mb-2"
        style={{ color: agent.accent }}
      >
        {agent.role}
      </p>
      <p className="text-xs text-white/50 leading-relaxed">{agent.description}</p>
    </div>

    {/* Status */}
    <div className="flex items-center justify-center gap-2">
      <div
        className="w-1.5 h-1.5 rounded-full animate-pulse"
        style={{ backgroundColor: agent.accent }}
      />
      <span className="text-[10px] font-mono text-white/30 uppercase">
        {loading ? "Generating avatar…" : error ? "Placeholder" : "Active"}
      </span>
    </div>
  </motion.div>
);

// ─── Main AgentRoster section ───────────────────────────────────────────────────

export const AgentRoster: React.FC = () => {
  const [avatars, setAvatars] = useState<Record<string, AvatarResult | null>>({});
  const [loading, setLoading] = useState<Record<string, boolean>>({});
  const [errors, setErrors] = useState<Record<string, string | null>>({});
  const [diagOpen, setDiagOpen] = useState(false);
  const [diagState, setDiagState] = useState<DiagnosticsState>({
    apiReachable: null,
    tokenPresent: false,
    avatarsGenerated: 0,
    totalAgents: AGENTS.length,
    lastError: null,
  });

  // Track all created object URLs so we can revoke them on unmount,
  // regardless of which state snapshot the cleanup closure captures.
  const createdUrlsRef = React.useRef<string[]>([]);

  const token: string = (typeof process !== "undefined" && process.env?.GITHUB_TOKEN) || "";

  // Generate all avatars on mount
  const generateAll = useCallback(async () => {
    const hasToken = !!token;
    setDiagState((prev) => ({ ...prev, tokenPresent: hasToken, apiReachable: null, lastError: null }));

    if (!hasToken) {
      setDiagState((prev) => ({
        ...prev,
        apiReachable: false,
        lastError: "GITHUB_TOKEN env var not set – avatars use fallback icons.",
      }));
      return;
    }

    for (const agent of AGENTS) {
      setLoading((prev) => ({ ...prev, [agent.id]: true }));
      try {
        const result = await generateAvatarImage(agent.avatarPrompt, token);
        createdUrlsRef.current.push(result.objectUrl);
        setAvatars((prev) => ({ ...prev, [agent.id]: result }));
        setErrors((prev) => ({ ...prev, [agent.id]: null }));
        setDiagState((prev) => ({
          ...prev,
          apiReachable: true,
          avatarsGenerated: prev.avatarsGenerated + 1,
        }));
      } catch (err: any) {
        const msg = err?.message ?? String(err);
        setErrors((prev) => ({ ...prev, [agent.id]: msg }));
        setDiagState((prev) => ({
          ...prev,
          apiReachable: prev.apiReachable ?? false,
          lastError: msg,
        }));
      } finally {
        setLoading((prev) => ({ ...prev, [agent.id]: false }));
      }
    }
  }, [token]);

  useEffect(() => {
    generateAll();

    // Clean up object URLs on unmount using the ref which always has current URLs.
    return () => {
      createdUrlsRef.current.forEach(revokeAvatarUrl);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <section className="mt-40 relative">
      {/* Background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[400px] bg-cyber/5 blur-[120px] rounded-full pointer-events-none" />

      {/* Header row */}
      <div className="relative z-10 flex items-center justify-between mb-12 flex-wrap gap-4">
        <div>
          <motion.h2
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="text-5xl font-black uppercase tracking-tighter"
          >
            Agent Roster
          </motion.h2>
          <p className="text-white/40 font-mono text-xs uppercase tracking-[0.3em] mt-2">
            AI-generated avatars via Spark Image API
          </p>
        </div>

        {/* Diagnostics button */}
        <div className="relative">
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.97 }}
            onClick={() => setDiagOpen((o) => !o)}
            className="flex items-center gap-2 px-4 py-2 border border-white/15 bg-white/5 rounded-xl text-xs font-mono uppercase tracking-widest text-white/60 hover:text-white hover:border-white/30 transition-all"
          >
            <Stethoscope className="w-4 h-4" />
            Diagnostics
          </motion.button>

          <AnimatePresence>
            {diagOpen && (
              <DiagnosticsPanel
                state={diagState}
                onClose={() => setDiagOpen(false)}
              />
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Agent cards grid */}
      <div className="relative z-10 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {AGENTS.map((agent) => (
          <AgentCard
            key={agent.id}
            agent={agent}
            avatar={avatars[agent.id] ?? null}
            loading={loading[agent.id] ?? false}
            error={errors[agent.id] ?? null}
          />
        ))}
      </div>
    </section>
  );
};
