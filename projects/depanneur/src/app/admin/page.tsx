"use client";

import { useState } from "react";
import type { Product, ProductDraft, ProductShape } from "@/types/product";
import { zones } from "@/data/storeLayout";
import Container from "@/components/ui/Container";

/* ── Constantes ─────────────────────────────────────────────────── */
const SHAPES: { value: ProductShape; label: string }[] = [
  { value: "box",    label: "Boîte" },
  { value: "can",    label: "Canette / Conserve" },
  { value: "pouch",  label: "Sachet / Poche" },
  { value: "bottle", label: "Bouteille" },
  { value: "round",  label: "Rond (fruit, bocal…)" },
];

const EMPTY_DRAFT: ProductDraft = {
  name:        "",
  description: "",
  shape:       "box",
  image:       "",
  category:    "",
  price:       0,
  stock:       1,
  placement:   { zone: zones[0].id, slot: 1 },
};

/* ── Helpers UI ─────────────────────────────────────────────────── */
function Field({
  label,
  children,
  required,
}: {
  label: string;
  children: React.ReactNode;
  required?: boolean;
}) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-semibold text-gray-700">
        {label}
        {required && <span className="ml-1 text-red-500" aria-hidden="true">*</span>}
      </label>
      {children}
    </div>
  );
}

const inputCls =
  "rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm transition-colors focus:border-emerald-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/30";

const SHAPE_ICON: Record<ProductShape, string> = {
  box:    "📦",
  can:    "🥫",
  pouch:  "🛍️",
  bottle: "🍶",
  round:  "🍎",
};

/* ── Page ───────────────────────────────────────────────────────── */
export default function AdminPage() {
  const [draft, setDraft]       = useState<ProductDraft>(EMPTY_DRAFT);
  const [products, setProducts] = useState<Product[]>([]);
  const [error, setError]       = useState<string | null>(null);

  /* Mise à jour champ simple */
  function setField<K extends keyof ProductDraft>(
    key: K,
    value: ProductDraft[K]
  ) {
    setDraft((prev) => ({ ...prev, [key]: value }));
  }

  /* Mise à jour placement */
  function setPlacement<K extends keyof ProductDraft["placement"]>(
    key: K,
    value: ProductDraft["placement"][K]
  ) {
    setDraft((prev) => ({
      ...prev,
      placement: { ...prev.placement, [key]: value },
    }));
  }

  /* Validation & ajout */
  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);

    if (!draft.name.trim())     return setError("Le nom est requis.");
    if (!draft.category.trim()) return setError("La catégorie est requise.");
    if (draft.stock < 0)        return setError("Le stock ne peut pas être négatif.");
    if (draft.placement.slot < 1)
      return setError("Le slot doit être ≥ 1.");

    const zone = zones.find((z) => z.id === draft.placement.zone);
    if (zone && draft.placement.slot > zone.capacity)
      return setError(`Slot max pour cette zone : ${zone.capacity}.`);

    const newProduct: Product = {
      ...draft,
      id:    crypto.randomUUID(),
      name:  draft.name.trim(),
      image: draft.image.trim() || "/placeholder.png",
    };

    setProducts((prev) => [newProduct, ...prev]);
    setDraft(EMPTY_DRAFT);
  }

  return (
    <Container className="py-12">
      <header className="mb-10">
        <p className="mb-1 text-sm font-semibold uppercase tracking-widest text-emerald-600">
          Administration
        </p>
        <h1 className="text-3xl font-extrabold text-gray-900">
          Gestion des produits
        </h1>
        <p className="mt-1 text-sm text-gray-500">
          Ajoutez des produits au catalogue. Les données sont en mémoire pour
          l&apos;instant — connecteur backend prévu en Phase 3.
        </p>
      </header>

      <div className="grid gap-10 lg:grid-cols-[1fr_2fr]">
        {/* ── Formulaire ─────────────────────────────────────────── */}
        <section aria-labelledby="form-title">
          <h2
            id="form-title"
            className="mb-5 text-lg font-bold text-gray-800"
          >
            Ajouter un produit
          </h2>

          <form
            onSubmit={handleSubmit}
            noValidate
            className="flex flex-col gap-5 rounded-2xl border border-gray-100 bg-gray-50 p-6 shadow-sm"
          >
            <Field label="Nom" required>
              <input
                className={inputCls}
                type="text"
                value={draft.name}
                onChange={(e) => setField("name", e.target.value)}
                placeholder="Ex : Coca-Cola 33cl"
                autoComplete="off"
              />
            </Field>

            <Field label="Description">
              <textarea
                className={`${inputCls} resize-none`}
                rows={3}
                value={draft.description}
                onChange={(e) => setField("description", e.target.value)}
                placeholder="Courte description du produit…"
              />
            </Field>

            <div className="grid grid-cols-2 gap-4">
              <Field label="Forme" required>
                <select
                  className={inputCls}
                  value={draft.shape}
                  onChange={(e) =>
                    setField("shape", e.target.value as ProductShape)
                  }
                >
                  {SHAPES.map((s) => (
                    <option key={s.value} value={s.value}>
                      {s.label}
                    </option>
                  ))}
                </select>
              </Field>

              <Field label="Catégorie" required>
                <input
                  className={inputCls}
                  type="text"
                  value={draft.category}
                  onChange={(e) => setField("category", e.target.value)}
                  placeholder="Ex : Boissons"
                />
              </Field>
            </div>

            <Field label="Stock">
              <input
                className={inputCls}
                type="number"
                min={0}
                value={draft.stock}
                onChange={(e) =>
                  setField("stock", parseInt(e.target.value, 10) || 0)
                }
              />
            </Field>

            <div className="grid grid-cols-2 gap-4">
              <Field label="Zone" required>
                <select
                  className={inputCls}
                  value={draft.placement.zone}
                  onChange={(e) => setPlacement("zone", e.target.value)}
                >
                  {zones.map((z) => (
                    <option key={z.id} value={z.id}>
                      {z.label}
                    </option>
                  ))}
                </select>
              </Field>

              <Field label="Slot" required>
                <input
                  className={inputCls}
                  type="number"
                  min={1}
                  value={draft.placement.slot}
                  onChange={(e) =>
                    setPlacement("slot", parseInt(e.target.value, 10) || 1)
                  }
                />
              </Field>
            </div>

            <Field label="URL de l'image">
              <input
                className={inputCls}
                type="url"
                value={draft.image}
                onChange={(e) => setField("image", e.target.value)}
                placeholder="https://…"
              />
            </Field>

            {error && (
              <p
                role="alert"
                className="rounded-lg border border-red-200 bg-red-50 px-4 py-2 text-sm font-medium text-red-700"
              >
                ⚠️ {error}
              </p>
            )}

            <button
              type="submit"
              className="mt-1 rounded-full bg-emerald-600 px-6 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-emerald-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2"
            >
              + Ajouter le produit
            </button>
          </form>
        </section>

        {/* ── Liste produits ──────────────────────────────────────── */}
        <section aria-labelledby="list-title">
          <h2
            id="list-title"
            className="mb-5 text-lg font-bold text-gray-800"
          >
            Produits ajoutés{" "}
            <span className="ml-1 inline-flex h-6 w-6 items-center justify-center rounded-full bg-emerald-100 text-xs font-bold text-emerald-700">
              {products.length}
            </span>
          </h2>

          {products.length === 0 ? (
            <div className="flex flex-col items-center justify-center rounded-2xl border-2 border-dashed border-gray-200 py-20 text-center text-gray-400">
              <span className="mb-3 text-4xl" aria-hidden="true">
                📋
              </span>
              <p className="text-sm">Aucun produit ajouté pour l&apos;instant.</p>
              <p className="text-xs">Utilisez le formulaire pour commencer.</p>
            </div>
          ) : (
            <ul className="flex flex-col gap-3" role="list">
              {products.map((p) => {
                const zone = zones.find((z) => z.id === p.placement.zone);
                return (
                  <li
                    key={p.id}
                    className="flex items-start gap-4 rounded-xl border border-gray-100 bg-white p-4 shadow-sm"
                  >
                    {/* Icône forme */}
                    <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-2xl">
                      {SHAPE_ICON[p.shape]}
                    </div>

                    {/* Infos */}
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="font-bold text-gray-900">
                          {p.name}
                        </span>
                        <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-500">
                          {p.category}
                        </span>
                        <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-semibold text-emerald-700">
                          {p.shape}
                        </span>
                      </div>
                      {p.description && (
                        <p className="mt-1 truncate text-xs text-gray-500">
                          {p.description}
                        </p>
                      )}
                      <div className="mt-2 flex flex-wrap gap-3 text-xs text-gray-400">
                        <span>
                          📦 Stock :{" "}
                          <strong className="text-gray-700">{p.stock}</strong>
                        </span>
                        <span>
                          📍{" "}
                          <strong className="text-gray-700">
                            {zone?.label ?? p.placement.zone}
                          </strong>{" "}
                          — slot {p.placement.slot}
                        </span>
                      </div>
                    </div>

                    {/* Supprimer */}
                    <button
                      onClick={() =>
                        setProducts((prev) =>
                          prev.filter((x) => x.id !== p.id)
                        )
                      }
                      className="shrink-0 rounded-lg p-1.5 text-gray-300 transition-colors hover:bg-red-50 hover:text-red-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-red-400"
                      aria-label={`Supprimer ${p.name}`}
                    >
                      ✕
                    </button>
                  </li>
                );
              })}
            </ul>
          )}
        </section>
      </div>
    </Container>
  );
}
