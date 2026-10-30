export const siteConfig = {
  name: "Supermarché du Quartier",
  shortName: "SDQ",
  description:
    "Votre supermarché de proximité — produits frais, promotions et service de qualité.",
  url: "https://supermarche-du-quartier.fr",
} as const;

export const navLinks = [
  { label: "Accueil", href: "/" },
  { label: "Catalogue", href: "/catalogue" },
  { label: "Promotions", href: "/promotions" },
] as const;

export type NavLink = (typeof navLinks)[number];
