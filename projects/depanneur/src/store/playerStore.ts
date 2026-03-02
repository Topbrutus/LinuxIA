import { create } from "zustand";
import { DEFAULT_ANCHOR } from "@/data/storeMap";
import { findPath } from "@/lib/pathfinding";
import type { Waypoint } from "@/lib/pathfinding";

interface PlayerState {
  posX: number;
  posY: number;
  targetX: number;
  targetY: number;
  currentPath: Waypoint[];
  /** Dernier point cliqué — affiché comme marqueur au sol. Null = arrivé. */
  lastClickTarget: { x: number; y: number } | null;

  setPosition: (x: number, y: number) => void;
  setTargetWithPath: (tx: number, ty: number) => void;
  shiftPath: () => void;
}

export const usePlayerStore = create<PlayerState>()((set, get) => ({
  posX:            DEFAULT_ANCHOR.ax,
  posY:            DEFAULT_ANCHOR.ay,
  targetX:         DEFAULT_ANCHOR.ax,
  targetY:         DEFAULT_ANCHOR.ay,
  currentPath:     [],
  lastClickTarget: null,

  setPosition: (posX, posY) => set({ posX, posY }),

  setTargetWithPath: (tx, ty) => {
    const { posX, posY } = get();
    const path = findPath(posX, posY, tx, ty);
    set({ targetX: tx, targetY: ty, currentPath: path, lastClickTarget: { x: tx, y: ty } });
  },

  shiftPath: () => {
    const [, ...rest] = get().currentPath;
    /* Efface le marqueur quand le chemin est épuisé */
    set({ currentPath: rest, ...(rest.length === 0 ? { lastClickTarget: null } : {}) });
  },
}));
