"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import { usePlayerStore } from "@/store/playerStore";
import { useUserStore } from "@/store/userStore";
import { hotspots, DEFAULT_ANCHOR } from "@/data/storeMap";
import { smoothNoise, hashSeed } from "@/lib/noise";
import { cn } from "@/lib/utils";

/* ── Constantes de mouvement ─────────────────────────────────────────── */
const BASE_SPEED     = 13;   // %/sec vitesse normale
const SLOW_RADIUS    = 4.5;  // % — début de décélération
const STOP_THRESHOLD = 0.30; // % — considéré arrivé au waypoint
const SPEED_LERP     = 0.09;
const VEL_LERP       = 0.14;
const WALK_FREQ      = 4.2;  // foulées/sec

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

  const seed = hashSeed(name);

  /* ── DOM refs ──────────────────────────────────────────────────────── */
  const containerRef = useRef<HTMLDivElement>(null);
  const animRef      = useRef<HTMLDivElement>(null);
  const shadowRef    = useRef<HTMLDivElement>(null);

  /* ── State refs (aucun re-render) ────────────────────────────────── */
  const posRef          = useRef({ x: DEFAULT_ANCHOR.ax, y: DEFAULT_ANCHOR.ay });
  const targetRef       = useRef({ x: DEFAULT_ANCHOR.ax, y: DEFAULT_ANCHOR.ay });
  const currentSpeedRef = useRef(0);
  const velRef          = useRef({ x: 0, y: 0 });
  const movingRef       = useRef(false);
  const lastZoneRef     = useRef<string | null>(null);

  /* Callback stable */
  const onZoneReachedRef = useRef(onZoneReached);
  useEffect(() => { onZoneReachedRef.current = onZoneReached; }, [onZoneReached]);

  /* ── Sync cible depuis le store ───────────────────────────────────
     Deux types de changements :
     1. currentPath change → pointer sur le premier waypoint
     2. targetX/Y change sans path → destination directe
  */
  useEffect(() =>
    usePlayerStore.subscribe((state, prev) => {
      if (state.currentPath !== prev.currentPath) {
        const first = state.currentPath[0];
        targetRef.current = first
          ? { x: first.x, y: first.y }
          : { x: state.targetX, y: state.targetY };
      } else if (
        state.targetX !== prev.targetX ||
        state.targetY !== prev.targetY
      ) {
        if (state.currentPath.length === 0) {
          targetRef.current = { x: state.targetX, y: state.targetY };
        }
      }
    }),
  []);

  /* ── Boucle rAF ────────────────────────────────────────────────────── */
  useEffect(() => {
    let rafId: number;
    let lastTime = performance.now();

    function tick(now: number) {
      const dt   = Math.min((now - lastTime) / 1000, 0.05);
      lastTime   = now;
      const t    = now / 1000;

      const pos    = posRef.current;
      const target = targetRef.current;
      const dx     = target.x - pos.x;
      const dy     = target.y - pos.y;
      const dist   = Math.sqrt(dx * dx + dy * dy);

      /* ── Mouvement ────────────────────────────────────────────────── */
      if (dist < STOP_THRESHOLD) {
        pos.x = target.x;
        pos.y = target.y;

        const store = usePlayerStore.getState();

        if (store.currentPath.length > 0) {
          /* Waypoint intermédiaire atteint → avancer dans le chemin */
          store.setPosition(pos.x, pos.y);
          store.shiftPath(); // déclenche subscribe → met à jour targetRef
          /* movingRef reste true : mouvement continu sans pause */
        } else if (movingRef.current) {
          /* Destination finale atteinte */
          movingRef.current       = false;
          currentSpeedRef.current = 0;
          velRef.current          = { x: 0, y: 0 };
          store.setPosition(pos.x, pos.y);

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
        /* En mouvement */
        const nx = dx / dist;
        const ny = dy / dist;

        const targetSpeed =
          dist > SLOW_RADIUS ? BASE_SPEED : BASE_SPEED * (dist / SLOW_RADIUS);

        currentSpeedRef.current +=
          (targetSpeed - currentSpeedRef.current) * SPEED_LERP;

        const step = currentSpeedRef.current * dt;
        pos.x += nx * Math.min(step, dist);
        pos.y += ny * Math.min(step, dist);

        velRef.current.x += (nx * currentSpeedRef.current - velRef.current.x) * VEL_LERP;
        velRef.current.y += (ny * currentSpeedRef.current - velRef.current.y) * VEL_LERP;

        if (!movingRef.current) movingRef.current = true;
      }

      /* ── Position DOM ─────────────────────────────────────────────── */
      if (containerRef.current) {
        containerRef.current.style.left = `${pos.x}%`;
        containerRef.current.style.top  = `${pos.y}%`;
      }

      /* ── Animations organiques ────────────────────────────────────── */
      if (animRef.current) {
        let transform: string;
        if (!movingRef.current) {
          const swayX   = smoothNoise(t * 0.55, seed)       * 2.0;
          const breathY = Math.sin(t * 0.8 + seed * 0.01)   * 1.5;
          const rotDeg  = smoothNoise(t * 0.38, seed + 137)  * 1.2;
          transform = `translateX(${swayX}px) translateY(${breathY}px) rotate(${rotDeg}deg)`;
        } else {
          const bounceY   = -Math.abs(Math.sin(t * WALK_FREQ * Math.PI)) * 3.2;
          const tiltBase  = Math.max(-9, Math.min(9, velRef.current.x * 0.38));
          const tiltNoise = smoothNoise(t * 1.4, seed + 42)  * 0.7;
          const swingX    = smoothNoise(t * WALK_FREQ * 0.45, seed + 73) * 1.6;
          transform = `translateX(${swingX}px) translateY(${bounceY}px) rotate(${tiltBase + tiltNoise}deg)`;
        }
        animRef.current.style.transform = transform;
      }

      /* ── Ombre dynamique ──────────────────────────────────────────── */
      if (shadowRef.current) {
        const sr   = currentSpeedRef.current / BASE_SPEED;
        const wPx  = 28 - sr * 12;
        const op   = Math.max(0.15, 0.45 - sr * 0.20);
        shadowRef.current.style.width   = `${wPx}px`;
        shadowRef.current.style.opacity = String(op);
      }

      rafId = requestAnimationFrame(tick);
    }

    rafId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafId);
  }, [seed]);

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
      <div
        ref={animRef}
        className="flex flex-col items-center gap-0.5"
        style={{ willChange: "transform" }}
      >
        <span className="mb-0.5 whitespace-nowrap rounded-full bg-gray-900/85 px-2 py-0.5 text-[10px] font-bold text-white shadow-md backdrop-blur-sm">
          {name}
        </span>

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
