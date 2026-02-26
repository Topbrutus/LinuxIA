"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import { usePlayerStore } from "@/store/playerStore";
import { useUserStore } from "@/store/userStore";
import { hotspots, DEFAULT_ANCHOR } from "@/data/storeMap";
import { smoothNoise, hashSeed } from "@/lib/noise";
import { cn } from "@/lib/utils";

/* ── Movement constants ─────────────────────────────────────────── */
const BASE_SPEED     = 13;   // %/sec vitesse normale
const SLOW_RADIUS    = 4.5;  // % — commence à décélérer
const STOP_THRESHOLD = 0.25; // % — considéré arrivé
const SPEED_LERP     = 0.09; // lissage accélération/décélération
const VEL_LERP       = 0.14; // lissage vélocité pour le tilt
const WALK_FREQ      = 4.2;  // foulées/sec (rebond)

function pointInHotspot(
  x: number,
  y: number,
  hs: (typeof hotspots)[number],
): boolean {
  return x >= hs.x && x <= hs.x + hs.w && y >= hs.y && y <= hs.y + hs.h;
}

interface PlayerAvatarProps {
  onZoneReached?: (zoneId: string) => void;
}

export default function PlayerAvatar({ onZoneReached }: PlayerAvatarProps) {
  const user     = useUserStore((s) => s.user);
  const avatarId = user?.avatarId ?? "blank-white";
  const name     = user?.name     ?? "Invité";
  const src      = avatarId.startsWith("blank-")
    ? `/avatars/${avatarId}.svg`
    : `/avatars/${avatarId}.webp`;

  /* Seed stable par nom — change si l'utilisateur change */
  const seed = hashSeed(name);

  /* ── DOM refs ─────────────────────────────────────────────────── */
  const containerRef = useRef<HTMLDivElement>(null); // position left/top %
  const animRef      = useRef<HTMLDivElement>(null);  // mouvements organiques
  const shadowRef    = useRef<HTMLDivElement>(null);  // ombre au sol

  /* ── State refs (aucun re-render React) ──────────────────────── */
  const posRef          = useRef({ x: DEFAULT_ANCHOR.ax, y: DEFAULT_ANCHOR.ay });
  const targetRef       = useRef({ x: DEFAULT_ANCHOR.ax, y: DEFAULT_ANCHOR.ay });
  const currentSpeedRef = useRef(0);
  const velRef          = useRef({ x: 0, y: 0 }); // vélocité lissée pour tilt
  const movingRef       = useRef(false);
  const lastZoneRef     = useRef<string | null>(null);

  /* Callback stable */
  const onZoneReachedRef = useRef(onZoneReached);
  useEffect(() => { onZoneReachedRef.current = onZoneReached; }, [onZoneReached]);

  /* Sync cible depuis playerStore (subscribe = pas de re-render) */
  useEffect(() =>
    usePlayerStore.subscribe((state) => {
      targetRef.current = { x: state.targetX, y: state.targetY };
    }),
  []);

  /* ── Boucle rAF principale ────────────────────────────────────── */
  useEffect(() => {
    let rafId: number;
    let lastTime = performance.now();

    function tick(now: number) {
      /* Delta-time (capé à 50 ms pour éviter les sauts après perte de focus) */
      const dt   = Math.min((now - lastTime) / 1000, 0.05);
      lastTime   = now;
      const t    = now / 1000;

      const pos    = posRef.current;
      const target = targetRef.current;
      const dx     = target.x - pos.x;
      const dy     = target.y - pos.y;
      const dist   = Math.sqrt(dx * dx + dy * dy);

      /* ── Mouvement ─────────────────────────────────────────────── */
      if (dist < STOP_THRESHOLD) {
        if (movingRef.current) {
          pos.x = target.x;
          pos.y = target.y;
          currentSpeedRef.current = 0;
          velRef.current          = { x: 0, y: 0 };
          movingRef.current       = false;

          /* Détection d'entrée dans une zone */
          const entered = hotspots.find((hs) => pointInHotspot(pos.x, pos.y, hs));
          if (entered && entered.zoneId !== lastZoneRef.current) {
            lastZoneRef.current = entered.zoneId;
            onZoneReachedRef.current?.(entered.zoneId);
          } else if (!entered) {
            lastZoneRef.current = null;
          }
        }
      } else {
        const nx = dx / dist;
        const ny = dy / dist;

        /* Vitesse cible : pleine jusqu'à SLOW_RADIUS, puis décélération */
        const targetSpeed =
          dist > SLOW_RADIUS ? BASE_SPEED : BASE_SPEED * (dist / SLOW_RADIUS);

        /* Accélération/décélération lisse */
        currentSpeedRef.current +=
          (targetSpeed - currentSpeedRef.current) * SPEED_LERP;

        const step = currentSpeedRef.current * dt;
        pos.x += nx * Math.min(step, dist);
        pos.y += ny * Math.min(step, dist);

        /* Vélocité lissée (pour tilt directionnel) */
        velRef.current.x += (nx * currentSpeedRef.current - velRef.current.x) * VEL_LERP;
        velRef.current.y += (ny * currentSpeedRef.current - velRef.current.y) * VEL_LERP;

        if (!movingRef.current) movingRef.current = true;
      }

      /* ── Mise à jour position DOM ──────────────────────────────── */
      if (containerRef.current) {
        containerRef.current.style.left = `${pos.x}%`;
        containerRef.current.style.top  = `${pos.y}%`;
      }

      /* ── Animations organiques (direct DOM, 0 re-render) ─────────
           Idle  : sway doux + respiration + légère rotation
           Moving: rebond de marche + tilt directionnel + swing bras
      */
      if (animRef.current) {
        let transform: string;

        if (!movingRef.current) {
          /* Idle */
          const swayX   = smoothNoise(t * 0.55, seed)         * 2.0;
          const breathY = Math.sin(t * 0.8  + seed * 0.01)    * 1.5;
          const rotDeg  = smoothNoise(t * 0.38, seed + 137)   * 1.2;
          transform = `translateX(${swayX}px) translateY(${breathY}px) rotate(${rotDeg}deg)`;
        } else {
          /* Moving */
          const bounceY   = -Math.abs(Math.sin(t * WALK_FREQ * Math.PI)) * 3.2;
          const tiltBase  = Math.max(-9, Math.min(9, velRef.current.x * 0.38));
          const tiltNoise = smoothNoise(t * 1.4, seed + 42)   * 0.7;
          const swingX    = smoothNoise(t * WALK_FREQ * 0.45, seed + 73) * 1.6;
          transform = `translateX(${swingX}px) translateY(${bounceY}px) rotate(${tiltBase + tiltNoise}deg)`;
        }

        animRef.current.style.transform = transform;
      }

      /* ── Ombre dynamique ───────────────────────────────────────── */
      if (shadowRef.current) {
        const speedRatio = currentSpeedRef.current / BASE_SPEED; // 0–1
        const wPx  = 28 - speedRatio * 12;                       // 28px → 16px
        const op   = Math.max(0.15, 0.45 - speedRatio * 0.20);   // 0.45 → 0.25
        shadowRef.current.style.width   = `${wPx}px`;
        shadowRef.current.style.opacity = String(op);
      }

      rafId = requestAnimationFrame(tick);
    }

    rafId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafId);
  }, [seed]); // seed stable ; redémarre uniquement si le nom change

  return (
    <div
      ref={containerRef}
      className="pointer-events-none absolute z-40"
      style={{
        left:      `${DEFAULT_ANCHOR.ax}%`,
        top:       `${DEFAULT_ANCHOR.ay}%`,
        transform: "translateX(-50%) translateY(-100%)",
      }}
      aria-label={`Personnage : ${name}`}
      role="img"
    >
      {/* Wrapper organique — piloté par animRef dans le rAF */}
      <div
        ref={animRef}
        className="flex flex-col items-center gap-0.5"
        style={{ willChange: "transform" }}
      >
        {/* Bulle nom */}
        <span className="mb-0.5 whitespace-nowrap rounded-full bg-gray-900/85 px-2 py-0.5 text-[10px] font-bold text-white shadow-md backdrop-blur-sm">
          {name}
        </span>

        {/* Silhouette */}
        <div
          className={cn(
            "relative overflow-hidden rounded-lg shadow-lg",
            "h-12 w-8 sm:h-14 sm:w-9 md:h-16 md:w-10",
            avatarId === "blank-black" ? "bg-gray-200" : "bg-gray-700",
          )}
        >
          <Image
            src={src}
            alt={name}
            fill
            className="object-contain"
            unoptimized
            sizes="40px"
          />
        </div>

        {/* Ombre dynamique — pilotée par shadowRef dans le rAF */}
        <div
          ref={shadowRef}
          className="h-1 rounded-full bg-black/35 blur-sm"
          style={{ width: "28px", opacity: 0.45, willChange: "width, opacity" }}
          aria-hidden="true"
        />
      </div>
    </div>
  );
}
