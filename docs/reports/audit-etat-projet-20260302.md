# AUDIT D'ÉTAT DU PROJET — LinuxIA
**Date :** 2026-03-02  
**Auteur :** Copilot (audit read-only, aucun fichier modifié)

---

## 1. Nom exact du dépôt

`Topbrutus/LinuxIA`

---

## 2. Framework frontend utilisé

**React + Vite** (TypeScript)

Stack complète :
- React `^19.2.4`
- Vite `^7.3.1` (conflit de version, voir §7)
- Tailwind CSS `^4.2.1` (via `@tailwindcss/vite`)
- Framer Motion `^12.34.3`
- Three.js `^0.182.0` + `@react-three/fiber` + `@react-three/drei`
- `@google/genai` `^1.38.0` (SDK Gemini)
- `lucide-react`, `react-device-detect`

---

## 3. Point d'entrée du site

```
assets/readme/showcase/linuxia_-cinematic-showcase/index.tsx
```

HTML racine :
```
assets/readme/showcase/linuxia_-cinematic-showcase/index.html
```

Il existe également une page HTML statique séparée (aucune dépendance JS) :
```
showcase/index.html
```

---

## 4. Intégrations existantes

### Google Cloud (GCP)
- **Aucune intégration GCP** n'est présente.
- Seul `@google/genai` (Gemini AI SDK) est utilisé dans `services/geminiService.ts`, pour des commentaires de caddy dans le mini-golf.
- Pas de `gcloud`, Firebase, Cloud Run, Cloud Functions, ni de credentials GCP dans le repo.

### Backend (Cloud Run / Functions)
- **Aucun backend** côté serveur.
- Le projet est entièrement front-end statique (SPA Vite).
- `geminiService.ts` appelle l'API Gemini directement depuis le navigateur via `process.env.API_KEY`.

### CI/CD GitHub → GCP
- **Aucun workflow CI/CD déployant vers GCP.**
- Les 3 workflows GitHub Actions présents sont uniquement des vérifications de scripts Bash :
  - `.github/workflows/ci.yml` — `bash -n` + ShellCheck sur `scripts/*.sh`
  - `.github/workflows/linuxia-ci.yml` — même chose via `scripts/ci.sh`
  - `.github/workflows/smoke-verify.yml` — smoke test du CLI `scripts/linuxia`

---

## 5. Fichiers liés à génération de personnages, avatars, images

### Génération de personnages (in-game)
| Fichier | Rôle |
|---|---|
| `assets/readme/showcase/linuxia_-cinematic-showcase/components/GameCanvas.tsx` | Moteur de rendu Canvas 2D du mini-golf. Dessine les personnages ANDROID (robot) et TREX (dinosaure) comme obstacles dynamiques sur les niveaux. |
| `assets/readme/showcase/linuxia_-cinematic-showcase/components/Icons.tsx` | Données SVG path pour les icônes Android, Dino, Golf, Trophée, etc. Utilisées par GameCanvas. |
| `assets/readme/showcase/linuxia_-cinematic-showcase/types.ts` | Type `Decoration` : `{ type: 'ANDROID' \| 'TREX' \| 'BOUNCY_PAD', pos, vel, ... }`. Définit la structure des personnages. |
| `assets/readme/showcase/linuxia_-cinematic-showcase/levels.ts` | Niveaux du jeu (grilles ASCII + positions des personnages par niveau). |

### Génération d'assets README (SVG)
| Fichier | Rôle |
|---|---|
| `assets/readme/showcase/linuxia_-cinematic-showcase/generate_github_assets.py` | Script Python : génère des SVG animés (hubs, sections de README) et un `README_GITHUB.md`. |
| `assets/readme/showcase/linuxia_-cinematic-showcase/scripts/gen.sh` | Script Bash : génère les SVG hub/animations + copie médias depuis `/home/gaby/pour_copilot` (chemin local machine). |
| `assets/readme/showcase/linuxia_-cinematic-showcase/build_assets.sh` | Identique à `gen.sh` — pipeline master de génération d'assets. |
| `assets/readme/showcase/linuxia_-cinematic-showcase/gen-assets.sh` | Variante légère de génération SVG. |
| `gen-readme-linuxia.sh` | Script racine du repo : génère des animations SVG dans `assets/readme/animations/`. |

### Images existantes dans le repo
| Dossier | Contenu |
|---|---|
| `assets/readme/showcase/photos/` | 8 photos JPG (p01.jpg → p08.jpg) |
| `assets/readme/gallery/` | Photos JPG `LinuxIA_XX.jpg` |
| `assets/readme/showcase/cards/` | 8 PNG `section_0X.png` |
| `assets/readme/showcase/video_thumbs/` | Thumbs vidéo `Trailer_01.jpg`, `Trailer_02.jpg` |
| `assets/readme/animations/` | SVGs animés (hubs, sections, scores) |
| `assets/cinematic/` | 3 SVGs cinématiques |
| `ChatGPT Image 30 juin 2025, 21 h 59 min 49 s.png` | Image PNG à la racine |

### Répertoires médias vides (placeholders)
| Dossier | État |
|---|---|
| `pour_copilot/photos/` | Vide (`.gitkeep` uniquement) |
| `pour_copilot/videos/` | Vide (`.gitkeep` uniquement) |
| `pour_copilot/audio/` | Vide (`.gitkeep` uniquement) |

---

## 6. Ce qui est fonctionnel aujourd'hui

| Composant | État |
|---|---|
| **CI/CD GitHub Actions** | ✅ Opérationnel — 3 workflows actifs vérifiant la syntaxe Bash et ShellCheck sur tous les scripts `.sh` |
| **Scripts Bash** (`scripts/*.sh`) | ✅ Syntaxe validée (`bash -n` + ShellCheck) |
| **CLI `scripts/linuxia`** | ✅ Présent et exécutable (Bash script), référencé dans `smoke-verify.yml` |
| **App React/Vite (build compilé)** | ✅ Un `dist/` est présent (`dist/assets/index-DaEm6cKH.js` + CSS) — l'app a été buildée |
| **App React — UI Showcase** | ✅ `App.tsx` : landing page LinuxIA avec navigation, hero animé, 4 sections (Vision/Architecture/Agents/Proof), galerie, footer |
| **App React — Jeu mini-golf** | ✅ `GameCanvas.tsx` : moteur de jeu 2D Canvas complet (9 niveaux, obstacles, portails, sable, eau) |
| **Documentation** | ✅ Riche et structurée : `docs/`, `sessions/`, `macros/`, `ops/`, `templates/` |
| **Assets SVG animés** | ✅ Présents dans `assets/readme/animations/` et `assets/readme/showcase/` |

---

## 7. Ce qui est expérimental ou cassé

| Élément | Problème |
|---|---|
| **`geminiService.ts` — modèle inexistant** | Le code appelle `model: 'gemini-3-flash-preview'`. Ce modèle n'existe pas dans l'API Gemini (les modèles valides sont `gemini-1.5-flash`, `gemini-2.0-flash`, etc.). L'AI caddy ne fonctionnera pas. |
| **`package.json` — conflit de version Vite** | `vite` est déclaré à la fois dans `dependencies` (`^7.3.1`) et dans `devDependencies` (`^6.2.0`). Incohérence potentielle au build. |
| **`showcase/index.html` — divs non peuplés** | La page statique déclare 3 divs (`id="photos"`, `id="videos"`, `id="audios"`) mais n'inclut aucun JavaScript pour les remplir. La page s'affiche vide. |
| **`pour_copilot/` — médias absents** | Les dossiers `photos/`, `videos/`, `audio/` sont vides (uniquement `.gitkeep`). Les scripts de génération qui en dépendent (`gen.sh`, `build_assets.sh`) échoueront si exécutés en CI. |
| **Scripts de génération — chemins locaux hardcodés** | `scripts/gen.sh` et `build_assets.sh` contiennent des chemins absolus `/opt/linuxia` et `/home/gaby/pour_copilot` inexistants hors de la machine de développement. |
| **Intégration 3D (Three.js)** | `@react-three/fiber` et `@react-three/drei` sont dans les dépendances mais `GameCanvas.tsx` utilise l'API Canvas 2D native. Aucun composant Three.js n'est utilisé dans le code actuel. |
| **`@11ty/eleventy-plugin-vite`** | Listé dans les dépendances mais aucun fichier `.11ty.tsx` ni configuration Eleventy n'est présent à la racine du projet. |
| **Aucun backend / API** | `geminiService.ts` expose la clé API Gemini directement dans le bundle client via `process.env.API_KEY`. En l'absence d'un backend proxy, la clé est exposée. |
| **`showcase/index.html` vs app Vite** | Deux "frontends" coexistent sans lien entre eux : la page HTML statique (`showcase/index.html`) et l'app React/Vite (`linuxia_-cinematic-showcase/`). |
