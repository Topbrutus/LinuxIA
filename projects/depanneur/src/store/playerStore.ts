import { create } from "zustand";
import { DEFAULT_ANCHOR } from "@/data/storeMap";
import { findPath } from "@/lib/pathfinding";
import type { Waypoint } from "@/lib/pathfinding";

interface PlayerState {
  /** Position courante (mise à jour par PlayerAvatar à chaque arrêt de waypoint) */
  posX: number;
  posY: number;
  /** Destination finale */
  targetX: number;
  targetY: number;
  /** Chemin restant (waypoints non encore atteints) */
  currentPath: Waypoint[];

  /** PlayerAvatar appelle ceci à chaque arrêt (waypoint ou destination finale) */
  setPosition: (x: number, y: number) => void;
  /**
   * Calcule le chemin A* depuis posX/posY vers (tx,ty).
   * Met à jour currentPath + target en une seule action.
   */
  setTargetWithPath: (tx: number, ty: number) => void;
  /** Avance d'un cran dans currentPath (appelé quand un waypoint est atteint). */
  shiftPath: () => void;
}

export const usePlayerStore = create<PlayerState>()((set, get) => ({
  posX:        DEFAULT_ANCHOR.ax,
  posY:        DEFAULT_ANCHOR.ay,
  targetX:     DEFAULT_ANCHOR.ax,
  targetY:     DEFAULT_ANCHOR.ay,
  currentPath: [],

  setPosition: (posX, posY) => set({ posX, posY }),

  setTargetWithPath: (tx, ty) => {
    const { posX, posY } = get();
    const path = findPath(posX, posY, tx, ty);
    set({ targetX: tx, targetY: ty, currentPath: path });
  },

  shiftPath: () => {
    const [, ...rest] = get().currentPath;
    set({ currentPath: rest });
  },
}));
