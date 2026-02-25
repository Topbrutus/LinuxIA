import type { Metadata } from "next";
import Container from "@/components/ui/Container";

export const metadata: Metadata = {
  title: "Promotions",
  description:
    "Retrouvez toutes nos offres et promotions de la semaine sur une sélection de produits.",
};

export default function PromotionsPage() {
  return (
    <Container className="py-20">
      <div className="max-w-xl">
        <p className="mb-3 text-sm font-semibold uppercase tracking-widest text-emerald-600">
          Offres en cours
        </p>
        <h1 className="mb-4 text-4xl font-extrabold text-gray-900">
          Promotions ✨
        </h1>
        <p className="text-base leading-relaxed text-gray-500">
          Les promotions de la semaine arrivent en Phase 2 — réductions
          exclusives, ventes flash et offres spéciales.
        </p>
      </div>
    </Container>
  );
}
