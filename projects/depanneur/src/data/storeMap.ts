/**
 * Positions des zones sur store.png (1024×1536, portrait 2/3).
 * Le conteneur de la carte utilise aspect-[2/3] → pas de recadrage.
 * Les coordonnées x/y/w/h sont donc des % directs de l'image originale.
 *
 * Repères visuels :
 *   - Mur du fond (frigos) : y ≈ 11 % → 35 %
 *   - Comptoir caisse (droite) : x ≈ 80 %, y ≈ 10 % → 45 %
 *   - Îlots au sol : y ≈ 34 % → 60 %
 */
export interface ZoneHotspot {
  zoneId: string;
  x: number;  // left en %
  y: number;  // top  en %
  w: number;  // width  en %
  h: number;  // height en %
}

export const hotspots: ZoneHotspot[] = [
  // ── Frigos (mur du fond, gauche → droite) ──────────────────────
  { zoneId: "frigo-1",   x:  1.5, y: 11.0, w: 20.5, h: 24.0 }, // Bières & Vin
  { zoneId: "frigo-2",   x: 22.0, y: 11.0, w: 23.0, h: 24.0 }, // Jus & Eaux
  { zoneId: "frigo-3",   x: 45.0, y: 11.0, w: 22.0, h: 24.0 }, // Produits Laitiers
  { zoneId: "frigo-4",   x: 67.0, y: 11.0, w: 12.0, h: 24.0 }, // Produits Frais
  // ── Comptoir caisse (étagère murale droite + caisse) ───────────
  { zoneId: "caisse",    x: 79.5, y: 10.0, w: 19.5, h: 35.0 }, // Comptoir droite
  // ── Îlots au sol ───────────────────────────────────────────────
  { zoneId: "etagere-a", x:  1.0, y: 37.0, w: 31.0, h: 24.0 }, // Îlot gauche
  { zoneId: "etagere-b", x: 28.0, y: 34.0, w: 38.0, h: 28.0 }, // Îlot centre
  { zoneId: "menage",    x: 60.0, y: 35.0, w: 36.0, h: 24.0 }, // Îlot droite
];
