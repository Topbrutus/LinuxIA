/**
 * Smooth pseudo-noise — combinaison de trois ondes sinus déphasées.
 * Sortie ∈ [-1, 1], variation lente, sans jitter.
 *
 * @param t    temps en secondes (ex: performance.now() / 1000)
 * @param seed décalage de phase (0–1000 recommandé)
 */
export function smoothNoise(t: number, seed: number): number {
  // Trois fréquences + phases différentes ; poids → max |sortie| = 1.0
  return (
    Math.sin(t * 0.71 + seed * 1.37) * 0.50 +
    Math.sin(t * 1.13 + seed * 2.71) * 0.30 +
    Math.sin(t * 0.29 + seed * 0.91) * 0.20
  );
}

/**
 * djb2 hash d'une chaîne → entier dans [0, 1000).
 * Seed stable et unique par nom d'utilisateur.
 */
export function hashSeed(str: string): number {
  let h = 5381;
  for (let i = 0; i < str.length; i++) {
    h = (((h << 5) + h) + str.charCodeAt(i)) >>> 0;
  }
  return h % 1000;
}
