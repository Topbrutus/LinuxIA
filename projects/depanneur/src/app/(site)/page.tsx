"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import Container from "@/components/ui/Container";

/* ── Animation variants ─────────────────────────────────────────── */
const EASE_EXPO: [number, number, number, number] = [0.22, 1, 0.36, 1];

const fadeUp = {
  hidden: { opacity: 0, y: 32 },
  visible: (delay: number) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.65, delay, ease: EASE_EXPO },
  }),
};

const scaleIn = {
  hidden: { opacity: 0, scale: 0.92 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: { duration: 0.5, ease: EASE_EXPO },
  },
};

/* ── Feature cards ──────────────────────────────────────────────── */
const features = [
  {
    icon: "🥦",
    title: "Produits frais",
    desc: "Fruits, légumes et viandes sélectionnés chaque matin auprès de producteurs locaux.",
  },
  {
    icon: "🏷️",
    title: "Prix compétitifs",
    desc: "Des promotions renouvelées chaque semaine pour faire des économies au quotidien.",
  },
  {
    icon: "🚶",
    title: "À deux pas de chez vous",
    desc: "Un accès facile, une équipe disponible et un service chaleureux.",
  },
] as const;

/* ── Page ───────────────────────────────────────────────────────── */
export default function HomePage() {
  return (
    <>
      {/* ── Hero ───────────────────────────────────────────────── */}
      <section
        className="relative flex min-h-[calc(100vh-4rem)] items-center overflow-hidden bg-gradient-to-br from-emerald-700 via-emerald-600 to-teal-500"
        aria-label="Bannière principale"
      >
        {/* Cercles décoratifs */}
        <div
          className="pointer-events-none absolute -right-40 -top-40 h-[28rem] w-[28rem] rounded-full bg-white/5"
          aria-hidden="true"
        />
        <div
          className="pointer-events-none absolute -bottom-24 -left-24 h-80 w-80 rounded-full bg-white/5"
          aria-hidden="true"
        />
        <div
          className="pointer-events-none absolute bottom-10 right-10 h-48 w-48 rounded-full bg-teal-400/20"
          aria-hidden="true"
        />

        <Container className="relative z-10 py-24">
          <motion.p
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            custom={0}
            className="mb-4 text-sm font-semibold uppercase tracking-widest text-emerald-200"
          >
            Bienvenue dans votre quartier
          </motion.p>

          <motion.h1
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            custom={0.12}
            className="mb-6 max-w-2xl text-5xl font-extrabold leading-tight tracking-tight text-white sm:text-6xl lg:text-7xl"
          >
            Le Supermarché
            <br />
            <span className="text-emerald-200">du Quartier</span>
          </motion.h1>

          <motion.p
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            custom={0.26}
            className="mb-10 max-w-xl text-lg leading-relaxed text-emerald-100"
          >
            Produits frais, promotions du moment et service de proximité —
            tout ce dont vous avez besoin, près de chez vous.
          </motion.p>

          <motion.div
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            custom={0.4}
            className="flex flex-wrap gap-4"
          >
            <Link
              href="/catalogue"
              className="inline-flex items-center justify-center rounded-full bg-white px-8 py-4 text-base font-bold text-emerald-700 shadow-lg transition-all duration-200 hover:bg-emerald-50 hover:shadow-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-emerald-600"
            >
              Voir le catalogue →
            </Link>
            <Link
              href="/promotions"
              className="inline-flex items-center justify-center rounded-full border-2 border-white/70 px-8 py-4 text-base font-bold text-white transition-all duration-200 hover:border-white hover:bg-white/10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-emerald-600"
            >
              Nos promotions ✨
            </Link>
          </motion.div>
        </Container>
      </section>

      {/* ── Features ───────────────────────────────────────────── */}
      <section className="border-b border-gray-100 bg-white py-20">
        <Container>
          <motion.div
            variants={scaleIn}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-80px" }}
            className="mb-12 text-center"
          >
            <h2 className="text-3xl font-extrabold text-gray-900">
              Pourquoi nous choisir ?
            </h2>
            <p className="mt-3 text-base text-gray-500">
              La qualité d&apos;un grand marché, la chaleur d&apos;un commerce de
              proximité.
            </p>
          </motion.div>

          <div className="grid gap-8 sm:grid-cols-3">
            {features.map((feature, i) => (
              <motion.div
                key={feature.title}
                variants={fadeUp}
                initial="hidden"
                whileInView="visible"
                viewport={{ once: true, margin: "-60px" }}
                custom={i * 0.12}
                className="flex flex-col items-center gap-4 rounded-2xl border border-gray-100 bg-gray-50 p-8 text-center shadow-sm transition-shadow hover:shadow-md"
              >
                <span className="text-5xl" aria-hidden="true">
                  {feature.icon}
                </span>
                <h3 className="text-lg font-bold text-gray-900">
                  {feature.title}
                </h3>
                <p className="text-sm leading-relaxed text-gray-500">
                  {feature.desc}
                </p>
              </motion.div>
            ))}
          </div>
        </Container>
      </section>

      {/* ── CTA Banner ─────────────────────────────────────────── */}
      <section className="bg-emerald-50 py-20">
        <Container className="text-center">
          <motion.div
            variants={fadeUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            custom={0}
          >
            <h2 className="text-3xl font-extrabold text-emerald-800">
              Profitez de nos offres de la semaine
            </h2>
            <p className="mx-auto mt-3 max-w-md text-base text-emerald-700">
              Des réductions exclusives sur des centaines de produits,
              disponibles en magasin et en ligne.
            </p>
            <Link
              href="/promotions"
              className="mt-8 inline-flex items-center justify-center rounded-full bg-emerald-600 px-8 py-4 text-base font-bold text-white shadow-md transition-all duration-200 hover:bg-emerald-700 hover:shadow-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2"
            >
              Voir toutes les promotions
            </Link>
          </motion.div>
        </Container>
      </section>
    </>
  );
}
