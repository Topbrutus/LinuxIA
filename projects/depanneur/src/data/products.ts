import type { Product } from "@/types/product";

export const products: Product[] = [
  // ── frigo-1 : Bières & Vin ──────────────────────────────────────
  {
    id: "p-001",
    name: "Bière Blonde 33cl",
    description: "Bière blonde légère, fraîche et dorée. Parfaite pour l'apéro.",
    shape: "can",
    image: "/placeholder.png",
    category: "Bières",
    price: 1.20,
    stock: 48,
    placement: { zone: "frigo-1", slot: 1 },
  },
  {
    id: "p-002",
    name: "Vin Rouge Côtes du Rhône",
    description: "Vin rouge fruité, tannins souples, idéal avec les viandes.",
    shape: "bottle",
    image: "/placeholder.png",
    category: "Vins",
    price: 6.90,
    stock: 18,
    placement: { zone: "frigo-1", slot: 2 },
  },

  // ── frigo-2 : Jus & Eaux ────────────────────────────────────────
  {
    id: "p-003",
    name: "Jus d'Orange Pressé 1L",
    description: "100 % pur jus, sans sucres ajoutés, pressé à froid.",
    shape: "bottle",
    image: "/placeholder.png",
    category: "Jus de fruits",
    price: 2.45,
    stock: 30,
    placement: { zone: "frigo-2", slot: 1 },
  },
  {
    id: "p-004",
    name: "Eau Minérale Plate 1.5L",
    description: "Eau de source naturelle, faible en sodium.",
    shape: "bottle",
    image: "/placeholder.png",
    category: "Eaux",
    price: 0.65,
    stock: 72,
    placement: { zone: "frigo-2", slot: 2 },
  },

  // ── frigo-3 : Produits Laitiers ─────────────────────────────────
  {
    id: "p-005",
    name: "Lait Entier Bio 1L",
    description: "Lait entier de vaches élevées en plein air, certifié bio.",
    shape: "bottle",
    image: "/placeholder.png",
    category: "Laitages",
    price: 1.35,
    stock: 40,
    placement: { zone: "frigo-3", slot: 1 },
  },
  {
    id: "p-006",
    name: "Yaourt Nature x4",
    description: "Yaourts brassés au lait entier, texture crémeuse.",
    shape: "round",
    image: "/placeholder.png",
    category: "Laitages",
    price: 1.89,
    stock: 25,
    placement: { zone: "frigo-3", slot: 2 },
  },

  // ── frigo-4 : Produits Frais ─────────────────────────────────────
  {
    id: "p-007",
    name: "Poulet Rôti",
    description: "Poulet fermier rôti à la broche, chaud et croustillant.",
    shape: "round",
    image: "/placeholder.png",
    category: "Traiteur",
    price: 8.50,
    stock: 6,
    placement: { zone: "frigo-4", slot: 1 },
  },

  // ── etagere-a : Îlot gauche (snacks) ────────────────────────────
  {
    id: "p-008",
    name: "Chips Nature 200g",
    description: "Chips croustillantes à la fleur de sel, cuites au chaudron.",
    shape: "pouch",
    image: "/placeholder.png",
    category: "Snacks",
    price: 1.99,
    stock: 55,
    placement: { zone: "etagere-a", slot: 1 },
  },

  // ── etagere-b : Îlot centre (épicerie) ──────────────────────────
  {
    id: "p-009",
    name: "Pâtes Penne 500g",
    description: "Pâtes de semoule de blé dur, cuisson 11 min.",
    shape: "box",
    image: "/placeholder.png",
    category: "Épicerie sèche",
    price: 1.10,
    stock: 80,
    placement: { zone: "etagere-b", slot: 1 },
  },

  // ── menage : Îlot droite ──────────────────────────────────────────
  {
    id: "p-010",
    name: "Liquide Vaisselle 500ml",
    description: "Dégraissant puissant, parfum citron, doux pour les mains.",
    shape: "bottle",
    image: "/placeholder.png",
    category: "Ménage",
    price: 1.55,
    stock: 35,
    placement: { zone: "menage", slot: 1 },
  },
];
