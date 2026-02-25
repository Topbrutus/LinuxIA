/**
 * Positions des zones sur l'image du magasin, exprimées en % (top-left origin).
 * Ces coordonnées correspondent au SVG placeholder (1200×800).
 * À ajuster quand store.png sera fourni.
 */
export interface ZoneHotspot {
  /** Zone id — doit correspondre à StoreZone.id */
  zoneId: string;
  /** Distance depuis le bord gauche, en % */
  x: number;
  /** Distance depuis le bord haut, en % */
  y: number;
  /** Largeur en % */
  w: number;
  /** Hauteur en % */
  h: number;
}

export const hotspots: ZoneHotspot[] = [
  { zoneId: "frigo-1",   x: 75.0, y:  5.0, w: 20.8, h: 35.0 },
  { zoneId: "frigo-2",   x: 75.0, y: 45.0, w: 20.8, h: 35.0 },
  { zoneId: "etagere-a", x:  3.3, y:  5.0, w: 25.0, h: 30.0 },
  { zoneId: "etagere-b", x:  3.3, y: 41.3, w: 25.0, h: 37.5 },
  { zoneId: "menage",    x: 35.0, y: 57.5, w: 31.7, h: 35.0 },
  { zoneId: "caisse",    x: 35.0, y:  5.0, w: 25.0, h: 20.0 },
];
