"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { usePlayerStore } from "@/store/playerStore";
import { useUserStore } from "@/store/userStore";
import { hotspots } from "@/data/storeMap";
import { DEFAULT_ANCHOR } from "@/data/storeMap";
import { cn } from "@/lib/utils";

const LERP            = 0.09;   // coefficient d'interpolation par frame
const STOP_THRESHOLD  = 0.3;    // seuil d'arrêt en %

function pointInHotspot(
  x: number,
  y: number,
  hs: (typeof hotspots)[number]
): boolean {
  return x >= hs.x && x <= hs.x + hs.w && y >= hs.y && y <= hs.y + hs.h;
}

interface PlayerAvatarProps {
  /** Appelé quand le sprite entre dans une zone (bounding-box hotspot) */
  onZoneReached?: (zoneId: string) => void;
}

export default function PlayerAvatar({ onZoneReached }: PlayerAvatarProps) {
  const user     = useUserStore((s) => s.user);
  const avatarId = user?.avatarId ?? "blank-white";
  const name     = user?.name     ?? "Invité";
  const src      = avatarId.startsWith("blank-")
    ? `/avatars/${avatarId}.svg`
    : `/avatars/${avatarId}.webp`;

  /* ── Refs pour position courante (mise à jour directe DOM) ─── */
  const containerRef = useRef<HTMLDivElement>(null);
  const posRef       = useRef({ x: DEFAULT_ANCHOR.ax, y: DEFAULT_ANCHOR.ay });
  const targetRef    = useRef({ x: DEFAULT_ANCHOR.ax, y: DEFAULT_ANCHOR.ay });
  const movingRef    = useRef(false);
  const lastZoneRef  = useRef<string | null>(null);

  /* isMoving comme state React → déclenchement animation Framer */
  const [isMoving, setIsMoving] = useState(false);

  /* Stable callback pour onZoneReached */
  const onZoneReachedRef = useRef(onZoneReached);
  useEffect(() => { onZoneReachedRef.current = onZoneReached; }, [onZoneReached]);

  /* ── Sync target depuis playerStore ─────────────────────────── */
  useEffect(() =>
    usePlayerStore.subscribe((state) => {
      targetRef.current = { x: state.targetX, y: state.targetY };
    }),
  []);

  /* ── rAF movement loop ───────────────────────────────────────── */
  useEffect(() => {
    let rafId: number;

    function tick() {
      const pos    = posRef.current;
      const target = targetRef.current;

      const dx   = target.x - pos.x;
      const dy   = target.y - pos.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < STOP_THRESHOLD) {
        /* Arrivé à destination */
        if (movingRef.current) {
          pos.x = target.x;
          pos.y = target.y;
          movingRef.current = false;
          setIsMoving(false);

          /* Détection zone */
          const entered = hotspots.find((hs) => pointInHotspot(pos.x, pos.y, hs));
          if (entered && entered.zoneId !== lastZoneRef.current) {
            lastZoneRef.current = entered.zoneId;
            onZoneReachedRef.current?.(entered.zoneId);
          } else if (!entered) {
            lastZoneRef.current = null;
          }
        }
      } else {
        /* En mouvement → lerp */
        pos.x += dx * LERP;
        pos.y += dy * LERP;

        if (!movingRef.current) {
          movingRef.current = true;
          setIsMoving(true);
        }
      }

      /* Mise à jour DOM directe (no re-render React) */
      if (containerRef.current) {
        containerRef.current.style.left = `${pos.x}%`;
        containerRef.current.style.top  = `${pos.y}%`;
      }

      rafId = requestAnimationFrame(tick);
    }

    rafId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafId);
  }, []);

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
      {/* Animation selon état */}
      <motion.div
        animate={
          isMoving
            ? { rotate: [-4, 4, -4], scaleX: [1, 0.88, 1] }
            : { y: [0, -5, 0] }
        }
        transition={
          isMoving
            ? { duration: 0.35, repeat: Infinity, ease: "easeInOut" }
            : { duration: 1.8,  repeat: Infinity, ease: "easeInOut" }
        }
        className="flex flex-col items-center gap-0.5"
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
            avatarId === "blank-black" ? "bg-gray-200" : "bg-gray-700"
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

        {/* Ombre dynamique */}
        <div
          className={cn(
            "h-1 rounded-full bg-black/35 blur-sm transition-all duration-200",
            isMoving ? "w-4 opacity-30" : "w-7 opacity-55"
          )}
          aria-hidden="true"
        />
      </motion.div>
    </div>
  );
}
