import type { Metadata } from "next";
import Container from "@/components/ui/Container";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Panier",
  description: "Votre panier d'achats — vérifiez vos articles avant de passer commande.",
};

export default function PanierPage() {
  return (
    <Container className="py-20">
      <div className="max-w-xl">
        <p className="mb-3 text-sm font-semibold uppercase tracking-widest text-emerald-600">
          Votre panier
        </p>
        <h1 className="mb-4 text-4xl font-extrabold text-gray-900">
          Panier 🛒
        </h1>
        <p className="mb-8 text-base leading-relaxed text-gray-500">
          Votre panier est vide pour le moment. Le système de commande complet
          arrive en Phase 2.
        </p>
        <Link
          href="/catalogue"
          className="inline-flex items-center justify-center rounded-full bg-emerald-600 px-6 py-3 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-emerald-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2"
        >
          Voir le catalogue →
        </Link>
      </div>
    </Container>
  );
}
