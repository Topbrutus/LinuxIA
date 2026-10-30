/**
 * Positions des zones sur store.png (1024×1536, portrait 2/3).
 * Le conteneur de la carte utilise aspect-[2/3] → pas de recadrage.
 * Les coordonnées x/y/w/h sont donc des % directs de l'image originale.
 *
 * Repères visuels :
 *   - Mur du fond (frigos) : y ≈ 11 % → 35 %
 *   - Comptoir caisse (droite) : x ≈ 80 %, y ≈ 10 % → 45 %
 *   - Îlots au sol : y ≈ 34 % → 60 %
 *
 * Anchors (ax, ay) : point d'atterrissage du sprite (pieds du personnage).
 *   - Calculé comme centre-bas de la zone, légèrement décalé vers le joueur.
 */
export interface ZoneHotspot {
  zoneId: string;
  x: number;  // left en %
  y: number;  // top  en %
  w: number;  // width  en %
  h: number;  // height en %
  ax: number; // anchor left en % (pieds du sprite)
  ay: number; // anchor top  en % (pieds du sprite)
}

/** Position de départ du sprite (entrée du magasin, bas-centre) */
export const DEFAULT_ANCHOR = { ax: 48, ay: 90 };

export const hotspots: ZoneHotspot[] = [
  // ── Frigos (mur du fond, gauche → droite) ──────────────────────
  { zoneId: "frigo-1",   x:  1.5, y: 11.0, w: 20.5, h: 24.0, ax: 11.5, ay: 38.0 },
  { zoneId: "frigo-2",   x: 22.0, y: 11.0, w: 23.0, h: 24.0, ax: 33.5, ay: 38.0 },
  { zoneId: "frigo-3",   x: 45.0, y: 11.0, w: 22.0, h: 24.0, ax: 56.0, ay: 38.0 },
  { zoneId: "frigo-4",   x: 67.0, y: 11.0, w: 12.0, h: 24.0, ax: 73.0, ay: 38.0 },
  // ── Comptoir caisse ────────────────────────────────────────────
  { zoneId: "caisse",    x: 79.5, y: 10.0, w: 19.5, h: 35.0, ax: 87.0, ay: 48.0 },
  // ── Îlots au sol ───────────────────────────────────────────────
  { zoneId: "etagere-a", x:  1.0, y: 37.0, w: 31.0, h: 24.0, ax: 16.5, ay: 63.0 },
  { zoneId: "etagere-b", x: 28.0, y: 34.0, w: 38.0, h: 28.0, ax: 47.0, ay: 64.0 },
  { zoneId: "menage",    x: 60.0, y: 35.0, w: 36.0, h: 24.0, ax: 76.0, ay: 61.0 },
];

/** Retourne le point d'ancrage d'une zone, ou DEFAULT_ANCHOR si inconnue. */
export function getZoneAnchor(zoneId: string): { ax: number; ay: number } {
  return hotspots.find((h) => h.zoneId === zoneId) ?? DEFAULT_ANCHOR;
}
