"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { useUserStore } from "@/store/userStore";
import type { UserGender } from "@/store/userStore";
import Container from "@/components/ui/Container";

const GENDER_OPTIONS: { value: UserGender; label: string }[] = [
  { value: "homme",               label: "Homme" },
  { value: "femme",               label: "Femme" },
  { value: "autre",               label: "Autre" },
  { value: "prefere-ne-pas-dire", label: "Préfère ne pas dire" },
];

const inputCls =
  "w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-gray-500 backdrop-blur-sm " +
  "transition-colors focus:border-emerald-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/30";

export default function WelcomePage() {
  const router  = useRouter();
  const setUser = useUserStore((s) => s.setUser);
  const user    = useUserStore((s) => s.user);

  const [name,    setName]    = useState("");
  const [address, setAddress] = useState("");
  const [gender,  setGender]  = useState<UserGender>("prefere-ne-pas-dire");
  const [error,   setError]   = useState<string | null>(null);

  /* Déjà un profil → /store directement */
  useEffect(() => {
    if (user) router.replace("/store");
  }, [user, router]);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);

    if (!name.trim())    return setError("Votre prénom est requis.");
    if (!address.trim()) return setError("Votre adresse est requise.");

    setUser({ name: name.trim(), address: address.trim(), gender });
    router.replace("/store");
  }

  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-gray-950 px-4">

      {/* Halo */}
      <div
        className="pointer-events-none absolute left-1/2 top-1/2 h-[40rem] w-[40rem] -translate-x-1/2 -translate-y-1/2 rounded-full bg-emerald-600/10 blur-3xl"
        aria-hidden="true"
      />

      <Container className="relative z-10 max-w-md">
        <motion.div
          initial={{ opacity: 0, y: 28 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
        >
          {/* Header */}
          <div className="mb-8 text-center">
            <span className="text-5xl" aria-hidden="true">🛍️</span>
            <h1 className="mt-4 text-3xl font-extrabold text-white">
              Bienvenue !
            </h1>
            <p className="mt-2 text-sm text-gray-400">
              Quelques informations pour personnaliser votre expérience.
            </p>
          </div>

          {/* Formulaire */}
          <form
            onSubmit={handleSubmit}
            noValidate
            className="flex flex-col gap-5 rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm shadow-2xl"
          >
            {/* Nom */}
            <div className="flex flex-col gap-1.5">
              <label
                htmlFor="name"
                className="text-sm font-semibold text-gray-300"
              >
                Prénom <span className="text-red-400" aria-hidden="true">*</span>
              </label>
              <input
                id="name"
                type="text"
                className={inputCls}
                placeholder="Ex : Jean"
                value={name}
                onChange={(e) => setName(e.target.value)}
                autoComplete="given-name"
                autoFocus
              />
            </div>

            {/* Adresse */}
            <div className="flex flex-col gap-1.5">
              <label
                htmlFor="address"
                className="text-sm font-semibold text-gray-300"
              >
                Adresse <span className="text-red-400" aria-hidden="true">*</span>
              </label>
              <input
                id="address"
                type="text"
                className={inputCls}
                placeholder="Ex : 12 rue des Lilas, Paris"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                autoComplete="street-address"
              />
            </div>

            {/* Genre */}
            <div className="flex flex-col gap-1.5">
              <label
                htmlFor="gender"
                className="text-sm font-semibold text-gray-300"
              >
                Genre
              </label>
              <select
                id="gender"
                value={gender}
                onChange={(e) => setGender(e.target.value as UserGender)}
                className={inputCls}
              >
                {GENDER_OPTIONS.map((opt) => (
                  <option
                    key={opt.value}
                    value={opt.value}
                    className="bg-gray-900 text-white"
                  >
                    {opt.label}
                  </option>
                ))}
              </select>
            </div>

            {/* Erreur */}
            {error && (
              <p
                role="alert"
                className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-2.5 text-sm font-medium text-red-400"
              >
                ⚠️ {error}
              </p>
            )}

            {/* Submit */}
            <button
              type="submit"
              className="mt-1 rounded-full bg-emerald-600 px-6 py-3.5 text-sm font-bold text-white shadow-lg shadow-emerald-900/40 transition-all hover:bg-emerald-500 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950"
            >
              Entrer dans le magasin →
            </button>
          </form>

          <p className="mt-4 text-center text-xs text-gray-600">
            Ces informations restent sur votre appareil.
          </p>
        </motion.div>
      </Container>
    </div>
  );
}
