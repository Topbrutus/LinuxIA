/** fridge  → scroll vertical (haut/bas)
 *  shelf   → scroll horizontal (gauche/droite)
 *  counter → caisse (liste compacte)
 */
export type ZoneType = "fridge" | "shelf" | "counter";

export interface StoreZone {
  id: string;
  label: string;
  capacity: number;
  zoneType: ZoneType;
}

export const zones: StoreZone[] = [
  { id: "frigo-1",   label: "Bières & Vin",       capacity: 40, zoneType: "fridge"  },
  { id: "frigo-2",   label: "Jus & Eaux",          capacity: 40, zoneType: "fridge"  },
  { id: "frigo-3",   label: "Produits Laitiers",   capacity: 40, zoneType: "fridge"  },
  { id: "frigo-4",   label: "Produits Frais",      capacity: 40, zoneType: "fridge"  },
  { id: "etagere-a", label: "Îlot gauche",         capacity: 60, zoneType: "shelf"   },
  { id: "etagere-b", label: "Îlot centre",         capacity: 80, zoneType: "shelf"   },
  { id: "menage",    label: "Îlot droite",         capacity: 50, zoneType: "shelf"   },
  { id: "caisse",    label: "Comptoir caisse",     capacity: 20, zoneType: "counter" },
];
