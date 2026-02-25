export type ProductShape = "box" | "can" | "pouch" | "bottle" | "round";

export interface ProductPlacement {
  zone: string;
  slot: number;
}

export interface Product {
  id: string;
  name: string;
  description: string;
  shape: ProductShape;
  image: string;
  category: string;
  stock: number;
  placement: ProductPlacement;
}

/** Sous-ensemble utilisé à la création (sans id généré) */
export type ProductDraft = Omit<Product, "id">;
