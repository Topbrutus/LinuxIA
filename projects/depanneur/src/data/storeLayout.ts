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
  { id: "frigo-1",   label: "Frigo boissons",    capacity: 40, zoneType: "fridge"  },
  { id: "frigo-2",   label: "Frigo produits",    capacity: 40, zoneType: "fridge"  },
  { id: "etagere-a", label: "Étagère snacks",    capacity: 60, zoneType: "shelf"   },
  { id: "etagere-b", label: "Étagère épicerie",  capacity: 80, zoneType: "shelf"   },
  { id: "menage",    label: "Produits ménagers", capacity: 50, zoneType: "shelf"   },
  { id: "caisse",    label: "Caisse",            capacity: 20, zoneType: "counter" },
];
