import type { Metadata } from "next";
import Container from "@/components/ui/Container";

export const metadata: Metadata = {
  title: "Catalogue",
  description:
    "Découvrez l'intégralité de notre catalogue de produits frais et d'épicerie.",
};

export default function CataloguePage() {
  return (
    <Container className="py-20">
      <div className="max-w-xl">
        <p className="mb-3 text-sm font-semibold uppercase tracking-widest text-emerald-600">
          Bientôt disponible
        </p>
        <h1 className="mb-4 text-4xl font-extrabold text-gray-900">
          Catalogue
        </h1>
        <p className="text-base leading-relaxed text-gray-500">
          Notre catalogue complet arrive en Phase 2 — produits frais, épicerie,
          boissons et bien plus encore.
        </p>
      </div>
    </Container>
  );
}
