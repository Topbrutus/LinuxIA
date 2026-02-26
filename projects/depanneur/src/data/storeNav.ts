/**
 * Navigation grid et obstacles du magasin.
 *
 * Coordonnées en % (0–100 × 0–100) — map aspect-[2/3].
 * Grille GRID_SIZE×GRID_SIZE, chaque cellule = (100/GRID_SIZE) %.
 *
 * Allées clés :
 *   - Allée devant frigos  : y 32–38 %, x  0–79 %   (3 cells)
 *   - Corridor central     : x 28–34 %, y  0–95 %   (3 cells) ← principal
 *   - Grand couloir avant  : y 58–95 %, x  0–79 %
 */
export const GRID_SIZE = 50; // chaque cellule = 2 %

export interface RectObstacle {
  x: number; // left  %
  y: number; // top   %
  w: number; // width  %
  h: number; // height %
}

/**
 * Obstacles physiques solides.
 * Légèrement inférieurs aux hotspots pour ménager des corridors navigables.
 */
export const obstacles: RectObstacle[] = [
  // ── Mur du haut ────────────────────────────────────────────────────
  { x:  0, y:  0, w: 79, h: 11 },

  // ── Frigos (y 11–32 %) — laisse y 32–38 comme allée devant frigos ─
  { x:  0, y: 11, w: 22, h: 21 }, // frigo-1
  { x: 22, y: 11, w: 23, h: 21 }, // frigo-2
  { x: 45, y: 11, w: 22, h: 21 }, // frigo-3
  { x: 67, y: 11, w: 12, h: 21 }, // frigo-4

  // ── Caisse (bloc droit) ────────────────────────────────────────────
  { x: 79, y:  0, w: 21, h: 45 },

  // ── Îlots au sol ──────────────────────────────────────────────────
  //   Corridors : x 0–2 (gauche), x 28–34 (centre), x 65–79 (droite)
  { x:  2, y: 40, w: 26, h: 17 }, // etagere-a  x 2–28, y 40–57
  { x: 34, y: 38, w: 31, h: 20 }, // etagere-b  x 34–65, y 38–58
  { x: 65, y: 40, w: 14, h: 17 }, // menage      x 65–79, y 40–57

  // ── Mur du bas ─────────────────────────────────────────────────────
  { x:  0, y: 95, w: 100, h: 5 },
];

/** Retourne `true` si (xPct, yPct) est à l'intérieur d'un obstacle. */
export function isBlocked(xPct: number, yPct: number): boolean {
  for (const obs of obstacles) {
    if (
      xPct >= obs.x &&
      xPct <= obs.x + obs.w &&
      yPct >= obs.y &&
      yPct <= obs.y + obs.h
    ) {
      return true;
    }
  }
  return false;
}
