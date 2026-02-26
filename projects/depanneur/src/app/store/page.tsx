"use client";

import {
  useState,
  useEffect,
  useRef,
  useCallback,
} from "react";
import Image from "next/image";
import { motion, AnimatePresence, type Variants } from "framer-motion";
import { zones } from "@/data/storeLayout";
import type { StoreZone, ZoneType } from "@/data/storeLayout";
import { hotspots, getZoneAnchor } from "@/data/storeMap";
import { products } from "@/data/products";
import type { Product } from "@/types/product";
import { useCartStore } from "@/store/cartStore";
import { usePlayerStore } from "@/store/playerStore";
import PlayerAvatar from "@/components/store/PlayerAvatar";
import { cn } from "@/lib/utils";

/* ── Drawer config by zoneType ──────────────────────────────────── */
interface DrawerConfig {
  side: "right" | "bottom";
  panelCls: string;
  variants: Variants;
}

const EASE_SPRING = { type: "spring", stiffness: 320, damping: 32 } as const;

const DRAWER_CONFIG: Record<ZoneType, DrawerConfig> = {
  fridge: {
    side: "right",
    panelCls: "top-0 right-0 h-full w-96 max-w-full flex-col overflow-y-auto",
    variants: {
      hidden:  { x: "100%", opacity: 0 },
      visible: { x: 0,      opacity: 1, transition: EASE_SPRING },
      exit:    { x: "100%", opacity: 0, transition: { duration: 0.22 } },
    },
  },
  shelf: {
    side: "bottom",
    panelCls:
      "bottom-0 left-0 right-0 h-80 w-full flex-row overflow-x-auto snap-x snap-mandatory",
    variants: {
      hidden:  { y: "100%", opacity: 0 },
      visible: { y: 0,      opacity: 1, transition: EASE_SPRING },
      exit:    { y: "100%", opacity: 0, transition: { duration: 0.22 } },
    },
  },
  counter: {
    side: "right",
    panelCls: "top-0 right-0 h-full w-80 max-w-full flex-col overflow-y-auto",
    variants: {
      hidden:  { x: "100%", opacity: 0 },
      visible: { x: 0,      opacity: 1, transition: EASE_SPRING },
      exit:    { x: "100%", opacity: 0, transition: { duration: 0.22 } },
    },
  },
};

/* ── Zone badge colors ──────────────────────────────────────────── */
const ZONE_COLORS: Record<ZoneType, string> = {
  fridge:  "bg-blue-500/20 border-blue-400 text-blue-900 hover:bg-blue-400/40",
  shelf:   "bg-emerald-500/20 border-emerald-400 text-emerald-900 hover:bg-emerald-400/40",
  counter: "bg-pink-500/20 border-pink-400 text-pink-900 hover:bg-pink-400/40",
};
const ZONE_LABEL_COLORS: Record<ZoneType, string> = {
  fridge:  "bg-blue-600",
  shelf:   "bg-emerald-600",
  counter: "bg-pink-600",
};

const SHAPE_ICON: Record<Product["shape"], string> = {
  can:    "🥫",
  bottle: "🍶",
  pouch:  "🛍️",
  round:  "🍎",
  box:    "📦",
};

/* ── ProductCard ────────────────────────────────────────────────── */
function ProductCard({ product }: { product: Product }) {
  const addItem = useCartStore((s) => s.addItem);
  const [added, setAdded] = useState(false);

  function handleAdd() {
    addItem({ id: product.id, name: product.name, price: product.price, quantity: 1, image: product.image });
    setAdded(true);
    setTimeout(() => setAdded(false), 1500);
  }

  return (
    <div className="flex w-52 shrink-0 snap-start flex-col rounded-xl border border-gray-100 bg-white shadow-sm overflow-hidden">
      {/* Image / icône */}
      <div className="relative flex h-28 w-full items-center justify-center bg-gray-50">
        <Image
          src={product.image}
          alt={product.name}
          fill
          className="object-contain p-3"
          onError={() => {/* fallback géré par le span ci-dessous */}}
          sizes="208px"
          unoptimized
        />
        <span className="relative z-10 text-4xl select-none" aria-hidden="true">
          {SHAPE_ICON[product.shape]}
        </span>
      </div>

      {/* Infos */}
      <div className="flex flex-1 flex-col gap-1.5 p-3">
        <p className="line-clamp-1 text-sm font-bold text-gray-900">{product.name}</p>
        <p className="line-clamp-2 text-xs leading-relaxed text-gray-400">{product.description}</p>

        <div className="mt-1 flex flex-wrap gap-1">
          <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-500">
            {product.category}
          </span>
          <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-500">
            slot {product.placement.slot}
          </span>
        </div>

        <div className="mt-auto flex items-center justify-between pt-2">
          <div>
            <span className="inline-block rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-700">
              Paiement à la livraison
            </span>
            <p className="mt-0.5 text-xs text-gray-400">Stock : {product.stock}</p>
          </div>

          <button
            onClick={handleAdd}
            disabled={added || product.stock === 0}
            aria-label={`Ajouter ${product.name} au panier`}
            className={cn(
              "rounded-full px-3 py-1.5 text-xs font-bold transition-all duration-200",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-1",
              added
                ? "bg-emerald-100 text-emerald-700"
                : product.stock === 0
                ? "cursor-not-allowed bg-gray-100 text-gray-400"
                : "bg-emerald-600 text-white hover:bg-emerald-700 active:scale-95"
            )}
          >
            <AnimatePresence mode="wait" initial={false}>
              {added ? (
                <motion.span
                  key="added"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0 }}
                  className="flex items-center gap-1"
                >
                  ✓ Ajouté
                </motion.span>
              ) : (
                <motion.span
                  key="add"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0 }}
                >
                  {product.stock === 0 ? "Épuisé" : "+ Panier"}
                </motion.span>
              )}
            </AnimatePresence>
          </button>
        </div>
      </div>
    </div>
  );
}

/* ── Empty state ────────────────────────────────────────────────── */
function EmptyState({ zone }: { zone: StoreZone }) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-3 py-12 text-center">
      <span className="text-4xl" aria-hidden="true">
        {zone.zoneType === "fridge" ? "🧊" : zone.zoneType === "counter" ? "🏷️" : "📦"}
      </span>
      <p className="text-sm font-semibold text-gray-500">
        Aucun produit dans cette zone
      </p>
      <p className="text-xs text-gray-400">
        Ajoutez des produits via l&apos;admin pour les voir ici.
      </p>
    </div>
  );
}

/* ── Drawer ─────────────────────────────────────────────────────── */
interface DrawerProps {
  zone: StoreZone;
  zoneProducts: Product[];
  onClose: () => void;
}

function Drawer({ zone, zoneProducts, onClose }: DrawerProps) {
  const closeRef = useRef<HTMLButtonElement>(null);
  const config = DRAWER_CONFIG[zone.zoneType];

  /* Focus le bouton fermer à l'ouverture */
  useEffect(() => {
    closeRef.current?.focus();
  }, []);

  return (
    <>
      {/* Overlay backdrop */}
      <motion.div
        key="backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
        className="absolute inset-0 z-20 bg-black/40"
        aria-hidden="true"
        onClick={onClose}
      />

      {/* Drawer panel */}
      <motion.div
        key="panel"
        role="dialog"
        aria-modal="true"
        aria-label={`Zone : ${zone.label}`}
        initial="hidden"
        animate="visible"
        exit="exit"
        variants={config.variants}
        className={cn(
          "absolute z-30 flex bg-white shadow-2xl",
          config.panelCls
        )}
      >
        {/* Header */}
        <div className="flex shrink-0 items-center justify-between border-b border-gray-100 px-5 py-4">
          <div>
            <p className="text-xs font-semibold uppercase tracking-widest text-gray-400">
              {zone.zoneType}
            </p>
            <h2 className="text-lg font-extrabold text-gray-900">
              {zone.label}
            </h2>
            <p className="text-xs text-gray-400">
              {zoneProducts.length} produit{zoneProducts.length !== 1 ? "s" : ""}
              {" "}· capacité {zone.capacity}
            </p>
          </div>
          <button
            ref={closeRef}
            onClick={onClose}
            aria-label="Fermer le panneau"
            className="ml-4 rounded-full p-2 text-gray-400 transition-colors hover:bg-gray-100 hover:text-gray-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500"
          >
            <svg
              aria-hidden="true"
              className="h-5 w-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={2}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>

        {/* Content */}
        <div
          className={cn(
            "flex flex-1 gap-4 p-5",
            zone.zoneType === "shelf"
              ? "flex-row items-stretch overflow-x-auto"
              : "flex-col overflow-y-auto"
          )}
        >
          {zoneProducts.length === 0 ? (
            <EmptyState zone={zone} />
          ) : (
            zoneProducts.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))
          )}
        </div>
      </motion.div>
    </>
  );
}

/* ── Store page ─────────────────────────────────────────────────── */
export default function StorePage() {
  const [selectedZoneId, setSelectedZoneId] = useState<string | null>(null);
  const [hoveredZoneId, setHoveredZoneId]   = useState<string | null>(null);
  const triggerRefs    = useRef<Map<string, HTMLButtonElement>>(new Map());
  const setPlayerTarget = usePlayerStore((s) => s.setTarget);

  const selectedZone = selectedZoneId
    ? (zones.find((z) => z.id === selectedZoneId) ?? null)
    : null;

  const zoneProducts: Product[] = selectedZoneId
    ? products.filter((p) => p.placement.zone === selectedZoneId)
    : [];

  /* ESC ferme le drawer */
  const handleKeyDown = useCallback(
    (e: globalThis.KeyboardEvent) => {
      if (e.key === "Escape" && selectedZoneId) {
        triggerRefs.current.get(selectedZoneId)?.focus();
        setSelectedZoneId(null);
      }
    },
    [selectedZoneId]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  /** Ouvre le drawer ET déplace le sprite vers l'ancre de la zone */
  function openZone(zoneId: string) {
    setSelectedZoneId(zoneId);
    const anchor = getZoneAnchor(zoneId);
    setPlayerTarget(anchor.ax, anchor.ay);
  }

  /**
   * Clic sur le fond de la carte → déplace le sprite vers ce point.
   * Les clics sur les boutons de zone sont ignorés (gérés par openZone).
   */
  function handleMapClick(e: React.MouseEvent<HTMLDivElement>) {
    if ((e.target as HTMLElement).closest("button")) return;
    const rect = e.currentTarget.getBoundingClientRect();
    const x = Math.max(2, Math.min(98, ((e.clientX - rect.left)  / rect.width)  * 100));
    const y = Math.max(5, Math.min(95, ((e.clientY - rect.top)   / rect.height) * 100));
    setPlayerTarget(x, y);
  }

  function closeDrawer() {
    if (selectedZoneId) triggerRefs.current.get(selectedZoneId)?.focus();
    setSelectedZoneId(null);
  }

  return (
    <div className="bg-gray-950 pb-8">
      {/* Page header */}
      <div className="border-b border-white/10 bg-gray-900 px-6 py-5">
        <p className="mb-0.5 text-xs font-semibold uppercase tracking-widest text-emerald-400">
          Vue magasin
        </p>
        <h1 className="text-2xl font-extrabold text-white">
          Carte du magasin
        </h1>
        <p className="mt-0.5 text-sm text-gray-400">
          Cliquez sur une zone pour voir les produits.
        </p>
      </div>

      {/* Map container — aspect-[2/3] = ratio exact de store.png (1024×1536), pas de recadrage */}
      <div
        className="relative mx-auto w-full max-w-4xl aspect-[2/3] overflow-hidden cursor-crosshair"
        onClick={handleMapClick}
        aria-label="Carte du magasin — cliquez pour déplacer votre personnage"
      >
        {/* Fond magasin */}
        <Image
          src="/store.png"
          alt="Plan du magasin — Supermarché du Quartier"
          fill
          className="object-cover"
          priority
          sizes="(max-width: 896px) 100vw, 896px"
        />

        {/* Zone overlays */}
        {hotspots.map((hs) => {
          const zone = zones.find((z) => z.id === hs.zoneId);
          if (!zone) return null;

          const isHovered  = hoveredZoneId === zone.id;
          const isSelected = selectedZoneId === zone.id;

          return (
            <button
              key={zone.id}
              ref={(el) => {
                if (el) triggerRefs.current.set(zone.id, el);
                else triggerRefs.current.delete(zone.id);
              }}
              onClick={() => openZone(zone.id)}
              onMouseEnter={() => setHoveredZoneId(zone.id)}
              onMouseLeave={() => setHoveredZoneId(null)}
              onFocus={() => setHoveredZoneId(zone.id)}
              onBlur={() => setHoveredZoneId(null)}
              aria-label={`Ouvrir la zone : ${zone.label}`}
              aria-pressed={isSelected}
              style={{
                position: "absolute",
                left:   `${hs.x}%`,
                top:    `${hs.y}%`,
                width:  `${hs.w}%`,
                height: `${hs.h}%`,
              }}
              className={cn(
                "rounded-xl border-2 transition-all duration-150",
                "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-1",
                ZONE_COLORS[zone.zoneType],
                isSelected && "ring-2 ring-white ring-offset-1"
              )}
            >
              {/* Label on hover/focus */}
              <AnimatePresence>
                {(isHovered || isSelected) && (
                  <motion.span
                    key="label"
                    initial={{ opacity: 0, y: 4 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: 4 }}
                    transition={{ duration: 0.15 }}
                    className={cn(
                      "pointer-events-none absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2",
                      "whitespace-nowrap rounded-full px-3 py-1 text-xs font-bold text-white shadow-lg",
                      ZONE_LABEL_COLORS[zone.zoneType]
                    )}
                  >
                    {zone.label}
                  </motion.span>
                )}
              </AnimatePresence>
            </button>
          );
        })}

        {/* Drawer (rendered inside the map container for overlay effect) */}
        <AnimatePresence>
          {selectedZone && (
            <Drawer
              key={selectedZone.id}
              zone={selectedZone}
              zoneProducts={zoneProducts}
              onClose={closeDrawer}
            />
          )}
        </AnimatePresence>

        {/* ── PlayerAvatar (absolu dans la carte, click-to-move) ──── */}
        <PlayerAvatar onZoneReached={(zoneId) => setSelectedZoneId(zoneId)} />
      </div>

      {/* Legend */}
      <div className="flex flex-wrap items-center gap-4 border-t border-white/10 bg-gray-900 px-6 py-3">
        {(["fridge", "shelf", "counter"] as ZoneType[]).map((type) => (
          <span key={type} className="flex items-center gap-1.5 text-xs text-gray-400">
            <span
              className={cn(
                "inline-block h-3 w-3 rounded-sm border",
                type === "fridge"  ? "bg-blue-500/40 border-blue-400"
                : type === "shelf"   ? "bg-emerald-500/40 border-emerald-400"
                :                      "bg-pink-500/40 border-pink-400"
              )}
              aria-hidden="true"
            />
            {type === "fridge"  ? "Frigo (scroll vertical)"
            : type === "shelf"  ? "Étagère (scroll horizontal)"
            :                     "Caisse (liste compacte)"}
          </span>
        ))}
      </div>
    </div>
  );
}
