import { create } from "zustand";
import { DEFAULT_ANCHOR } from "@/data/storeMap";

interface PlayerState {
  /** Position cible (set depuis l'extérieur) */
  targetX: number;
  targetY: number;
  setTarget: (x: number, y: number) => void;
}

export const usePlayerStore = create<PlayerState>()((set) => ({
  targetX: DEFAULT_ANCHOR.ax,
  targetY: DEFAULT_ANCHOR.ay,
  setTarget: (targetX, targetY) => set({ targetX, targetY }),
}));
