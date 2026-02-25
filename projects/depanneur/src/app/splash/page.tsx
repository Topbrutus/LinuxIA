"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { useUserStore } from "@/store/userStore";

const TIPS = [
  "Astuce : glisse pour voir plus de produits dans les étagères.",
  "Astuce : clique sur une zone de la carte pour explorer les rayons.",
  "Astuce : ton panier est sauvegardé pendant ta session.",
  "Astuce : les frigos sont tout au fond du magasin.",
  "Astuce : utilise le menu pour retrouver les promotions.",
];

const DURATION_MS = 1800;
const TICK_MS     = 30;

export default function SplashPage() {
  const router   = useRouter();
  const user     = useUserStore((s) => s.user);
  const hasInit  = useRef(false);

  const [progress, setProgress]   = useState(0);
  const [tipIndex, setTipIndex]   = useState(0);
  const [done, setDone]           = useState(false);

  /* Précharge store.png */
  useEffect(() => {
    const img = new window.Image();
    img.src = "/store.png";
  }, []);

  /* Barre de progression fake */
  useEffect(() => {
    if (hasInit.current) return;
    hasInit.current = true;

    const steps  = DURATION_MS / TICK_MS;
    let   current = 0;

    const interval = setInterval(() => {
      current += 1;
      /* Courbe d'accélération : rapide au début, ralentit vers 100 */
      const raw  = current / steps;
      const eased = raw < 0.8 ? raw * 1.1 : 0.88 + (raw - 0.8) * 0.6;
      setProgress(Math.min(Math.round(eased * 100), 100));

      if (current >= steps) {
        clearInterval(interval);
        setProgress(100);
        setDone(true);
      }
    }, TICK_MS);

    /* Rotation tips */
    const tipInterval = setInterval(() => {
      setTipIndex((i) => (i + 1) % TIPS.length);
    }, 2200);

    return () => {
      clearInterval(interval);
      clearInterval(tipInterval);
    };
  }, []);

  /* Redirection après chargement */
  useEffect(() => {
    if (!done) return;
    const timeout = setTimeout(() => {
      router.replace(user ? "/store" : "/welcome");
    }, 350);
    return () => clearTimeout(timeout);
  }, [done, user, router]);

  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-gray-950 px-6 text-center select-none">

      {/* Bruit d'ambiance — overlay grain */}
      <div
        className="pointer-events-none absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage:
            "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E\")",
        }}
        aria-hidden="true"
      />

      {/* Halo glow */}
      <div
        className="pointer-events-none absolute left-1/2 top-1/2 h-[36rem] w-[36rem] -translate-x-1/2 -translate-y-1/2 rounded-full bg-emerald-600/10 blur-3xl"
        aria-hidden="true"
      />

      {/* Logo + titre */}
      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
        className="relative z-10 flex flex-col items-center gap-4"
      >
        <div className="flex h-20 w-20 items-center justify-center rounded-2xl border border-emerald-700/40 bg-emerald-950/60 text-5xl shadow-xl ring-1 ring-emerald-500/20 backdrop-blur-sm">
          🛍️
        </div>

        <h1 className="text-3xl font-extrabold tracking-tight text-white sm:text-4xl">
          Supermarché du Quartier
        </h1>

        <p className="text-sm font-medium text-emerald-400">
          Chargement du magasin…
        </p>
      </motion.div>

      {/* Barre de progression */}
      <motion.div
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="relative z-10 mt-12 w-full max-w-sm"
        role="progressbar"
        aria-valuenow={progress}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label="Chargement du magasin"
      >
        <div className="overflow-hidden rounded-full bg-white/10 h-2">
          <motion.div
            className="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-400 shadow-[0_0_12px_2px_rgba(52,211,153,0.4)]"
            style={{ width: `${progress}%` }}
            transition={{ duration: 0.03 }}
          />
        </div>
        <p className="mt-2 text-right text-xs tabular-nums text-emerald-500/70">
          {progress} %
        </p>
      </motion.div>

      {/* Tips rotatifs */}
      <div className="relative z-10 mt-8 h-6 w-full max-w-sm overflow-hidden">
        <AnimatePresence mode="wait">
          <motion.p
            key={tipIndex}
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.35 }}
            className="text-center text-xs text-gray-500"
          >
            {TIPS[tipIndex]}
          </motion.p>
        </AnimatePresence>
      </div>

      {/* Flash de sortie */}
      <AnimatePresence>
        {done && (
          <motion.div
            key="flash"
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 0.15, 0] }}
            transition={{ duration: 0.4 }}
            className="pointer-events-none absolute inset-0 bg-white"
            aria-hidden="true"
          />
        )}
      </AnimatePresence>
    </div>
  );
}
