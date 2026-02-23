# LinuxIA — Inventaire complet (Scripts · Animations · Services · Installation)

> Référence exhaustive pour une installation sans erreur sur VM100.
> Chaque fichier est listé avec son nom exact, son extension, son rôle et le contexte d'exécution.

---

## Table des matières

1. [Scripts Bash (`scripts/*.sh`)](#1-scripts-bash)
2. [Générateurs README (`*.sh` racine)](#2-générateurs-readme-racine)
3. [Services & Timers systemd](#3-services--timers-systemd)
4. [Animations & Assets SVG](#4-animations--assets-svg)
5. [Extensions de fichiers présentes](#5-extensions-de-fichiers-présentes)
6. [Procédure d'installation sans erreur](#6-procédure-dinstallation-sans-erreur)
7. [Vérification post-installation](#7-vérification-post-installation)
8. [Variables d'environnement tunables](#8-variables-denvironnement-tunables)

---

## 1. Scripts Bash

Tous les scripts se trouvent dans `scripts/`. Extension : **`.sh`**. Shebang : `#!/usr/bin/env bash`. Tous ont passé `bash -n` (syntaxe valide).

### VM100 — Opérations principales

| Fichier | Rôle | Mode | Sudo requis |
|---------|------|------|-------------|
| `verify-platform.sh` | Vérification READ-ONLY complète (disques, timers, mounts, logs). Codes de sortie : 0=OK / 1=WARN / 2=FAIL | Read-only | Non |
| `health-report.sh` | Rapport diagnostique READ-ONLY → écrit dans `logs/health/` et copie dans `shareA/reports/health/` | Read-only | Non |
| `linuxia-healthcheck.sh` | Lance preflight + state-report + configsnap-index ; écrit `docs/STATE_HEALTHCHECK.md` | Read-only | Non |
| `linuxia-preflight.sh` | Vérifie que le repo git existe, que le timer configsnap est actif, et que les mounts shareA/shareB sont présents | Read-only | Non |
| `linuxia-state-report.sh` | Génère `docs/STATE_VM100.md` (état complet de la VM) | Write (docs/) | Non |
| `linuxia-config-snapshot.sh` | Capture une archive `.tar.zst` de tous les fichiers de config/infra dans `data/shareA/archives/configsnap/` | Write (shareA) | Non (besoin de `sudo` uniquement pour créer le répertoire la 1ère fois) |
| `linuxia-configsnap-index.sh` | Indexe les archives configsnap → `docs/CONFIGSNAP_LATEST.txt` | Write (docs/) | Non |
| `linuxia-repair.sh` | Ré-essaie le remount samba + vérifie shareA/shareB. Déclenché par `OnFailure=` du healthcheck | Write (logs) | Non |
| `health-retention.sh` | Supprime les anciens rapports health (garde les N derniers, défaut 30) | Write (logs/) | Non |
| `backup-configsnap-retention.sh` | Applique la rétention sur les archives configsnap | Write (shareA) | Non |
| `apply-share-acls.sh` | Applique les ACL par défaut sur shareA | Write (ACL) | Oui (`sudo`) |
| `systemd-install.sh` | Copie les unités systemd dans `/etc/systemd/system/`, active les timers | Write (système) | Oui (`sudo`) |
| `systemd-uninstall.sh` | Désactive et supprime les unités systemd LinuxIA | Write (système) | Oui (`sudo`) |
| `ci.sh` | Script CI local — lint + vérification syntaxe | Read-only | Non |
| `verify-systemd.sh` | Vérifie l'état des unités systemd LinuxIA | Read-only | Non |

### VM100 — Audit / Vérification storage

| Fichier | Rôle |
|---------|------|
| `01-verify-disks-mounts-vm100.sh` | Cohérence snapshot vs état réel (`lsblk`/`findmnt`), statut des 4 montages, génère preuve dans `docs/verifications/` |
| `03-audit-samba-vm100.sh` | Audit Samba (services, ports 139/445, firewalld, `testparm`, chemins des shares) |
| `append_verify_disks_result.sh` | Ajoute un bloc YAML `verify_disks_result` à la preuve la plus récente |

### VM101 — Bootstrap

| Fichier | Rôle |
|---------|------|
| `vm101-preflight.sh` | Vérifie les prérequis sur VM101 avant déploiement |
| `vm101-bootstrap-orchestrator.sh` | Déploie le rôle orchestrateur sur VM101 |
| `vm101-bootstrap-probe.sh` | Déploie le rôle probe/agent sur VM101 |
| `vm101-repo-hardening.sh` | Durcissement du repo git sur VM101 |
| `vm101-setup-observability.sh` | Configure l'observabilité sur VM101 |

### VM102 — Handoff

| Fichier | Rôle |
|---------|------|
| `vm102_discovery_handoff.sh` | Validation environnement VM102, mise à jour repo, découverte orchestrateur, preuves + handoff |

### Outils divers

| Fichier | Rôle |
|---------|------|
| `linuxia-phase6.sh` | Script de déploiement phase 6 (healthchecks) |
| `make_pack.sh` | Crée `linuxia_readme_showcase_pack.zip` des assets README |

---

## 2. Générateurs README (racine)

| Fichier | Extension | Rôle |
|---------|-----------|------|
| `master-linuxia.sh` | `.sh` | Génère toutes les animations SVG + sections + copie media dans `assets/readme/`. Nécessite Python 3 et les médias dans `pour_copilot/` |
| `gen-readme-linuxia.sh` | `.sh` | Génère un jeu de SVGs hero/sections + injecte un bloc dans `README.md` entre des marqueurs HTML. Doit être exécuté depuis `/opt/linuxia` |

---

## 3. Services & Timers systemd

Tous les fichiers sont dans `services/` ou `services/systemd/`.

### Timers critiques (installés par `systemd-install.sh`)

| Fichier | Extension | Déclenchement | Rôle |
|---------|-----------|---------------|------|
| `linuxia-configsnap.timer` | `.timer` | 03:00 quotidien | Déclenche le service configsnap |
| `linuxia-healthcheck.timer` | `.timer` | 03:05 quotidien | Déclenche le healthcheck |
| `linuxia-health-report.timer` | `.timer` | 03:10 quotidien | Déclenche le rapport diagnostique |

### Services (unités oneshot)

| Fichier | Extension | Rôle |
|---------|-----------|------|
| `linuxia-configsnap.service` | `.service` | Exécute `/usr/local/bin/linuxia-snapshot`. Requiert shareA/shareB montés |
| `linuxia-healthcheck.service` | `.service` | Exécute `linuxia-healthcheck.sh` en tant qu'utilisateur `gaby`. `OnFailure` → linuxia-repair.service |
| `linuxia-repair.service` | `.service` | Ré-essaie le remount samba + vérifie les bind mounts |
| `linuxia-health-report.service` | `.service` | Exécute `health-report.sh` |

### Mounts & Automounts (bind mounts)

| Fichier | Extension | Rôle |
|---------|-----------|------|
| `opt-linuxia-data-shareA.mount` | `.mount` | Bind mount : `/mnt/linuxia/DATA_1TB_A/LinuxIA_SMB` → `/opt/linuxia/data/shareA` |
| `opt-linuxia-data-shareB.mount` | `.mount` | Bind mount : `/mnt/linuxia/DATA_1TB_B/LinuxIA_SMB` → `/opt/linuxia/data/shareB` |
| `opt-linuxia-data-shareA.automount` | `.automount` | Automount shareA (timeout idle 300s) |
| `opt-linuxia-data-shareB.automount` | `.automount` | Automount shareB (timeout idle 300s) |

> **Note** : Les `.mount`/`.automount` nécessitent que `/mnt/linuxia/DATA_1TB_A/LinuxIA_SMB` et `/mnt/linuxia/DATA_1TB_B/LinuxIA_SMB` existent avant activation.

---

## 4. Animations & Assets SVG

### 4.1 Animations Hub (9 fichiers)

Répertoire : `assets/readme/anims/`  
Extension : **`.svg`**  
Générées par `master-linuxia.sh` (Python 3 embarqué).

| Fichier | Taille canvas |
|---------|---------------|
| `anim_01.svg` | 320×320 |
| `anim_02.svg` | 320×320 |
| `anim_03.svg` | 320×320 |
| `anim_04.svg` | 320×320 |
| `anim_05.svg` | 320×320 |
| `anim_06.svg` | 320×320 |
| `anim_07.svg` | 320×320 |
| `anim_08.svg` | 320×320 |
| `anim_09.svg` | 320×320 |

> Chaque animation contient : fond étoilé, orbite animée, grille HUD, barres de niveaux, label `HUB_ANIM_NN`.

### 4.2 Sections cinématiques (8 fichiers)

Répertoire : `assets/readme/sections/`  
Extension : **`.svg`**  
Taille canvas : **1200×420**

| Fichier | Thème |
|---------|-------|
| `section_01_vision.svg` | Vision — Proof-First Agent Ops |
| `section_02_architecture.svg` | Architecture — Multi-VM Proxmox |
| `section_03_agents.svg` | Agents — TriluxIA / ChromIAlux |
| `section_04_proof.svg` | Proof — Evidence append-only |
| `section_05_infra.svg` | Infra — Timers, healthchecks, snapshots |
| `section_06_security.svg` | Security — Accès contrôlés, audit |
| `section_07_storage.svg` | Storage — ZFS/Btrfs, Vault |
| `section_08_roadmap.svg` | Roadmap — Phases, DoD |

> Chaque section utilise l'image de galerie `../gallery/pNN.jpg` en fond avec overlay cinématique.

### 4.3 Autres assets SVG

Répertoire : `assets/readme/`

| Fichier | Description |
|---------|-------------|
| `hero-linuxia.svg` | Bannière héro principale (1600×520) avec grille, orbites, texte LinuxIA |
| `divider-hyperline.svg` | Séparateur animé (1600×84) — dégradé orange→vert→bleu |
| `banner-linuxia.svg` | Bannière alternative |
| `section-vision.svg` | Section vision (générée par `gen-readme-linuxia.sh`) |
| `section-architecture.svg` | Section architecture |
| `section-agents.svg` | Section agents |
| `section-proof.svg` | Section proof |

### 4.4 Assets cinématiques

Répertoire : `assets/cinematic/`

| Fichier | Description |
|---------|-------------|
| `cine-divider-hyperline.svg` | Séparateur hyperline cinématique |
| `cine-mission-control.svg` | Mission Control |
| `cine-orbit-telemetry.svg` | Orbite / télémétrie |

### 4.5 Galerie photos

Répertoire : `assets/readme/gallery/`  
Extension : **`.jpg`**

| Fichier | Note |
|---------|------|
| `LinuxIA_02.jpg` … `LinuxIA_12.jpg` | Photos originales (11 fichiers) |
| `p01.jpg` … `p08.jpg` | Photos renommées pour les sections (8 fichiers — copiées par `master-linuxia.sh`) |

### 4.6 Médias (vidéo / audio)

| Chemin | Extension | Description |
|--------|-----------|-------------|
| `assets/readme/videos/Trailer_01.mp4` | `.mp4` | Trailer 01 |
| `assets/readme/videos/Trailer_02.mp4` | `.mp4` | Trailer 02 |
| `assets/readme/audio/Theme_01.mp3` | `.mp3` | Thème musical |

> **Source** : Copiés depuis `pour_copilot/videos/` et `pour_copilot/audio/` par `master-linuxia.sh`.

---

## 5. Extensions de fichiers présentes

| Extension | Contexte |
|-----------|---------|
| `.sh` | Scripts Bash (26 dans `scripts/`, 2 en racine, 3 dans `sessions/`) |
| `.service` | Unités systemd service |
| `.timer` | Unités systemd timer |
| `.mount` | Unités systemd mount |
| `.automount` | Unités systemd automount |
| `.svg` | Animations et sections visuelles |
| `.jpg` | Photos galerie |
| `.mp4` | Vidéos showcase |
| `.mp3` | Audio thème |
| `.md` | Documentation Markdown |
| `.json` | Manifestes (ChromIAlux extension, evidence) |
| `.jsonl` | Logs structurés append-only (evidence, sessions) |
| `.yaml` / `.yml` | Workflows CI, tests |
| `.txt` | Preuves/vérifications |
| `.html` | Showcase index, dock ChromIAlux |
| `.js` | Extension Chrome (background, bridge, content) |
| `.png` | Cartes showcase (section_0N.png) |
| `.gitkeep` | Placeholder répertoires vides |

---

## 6. Procédure d'installation sans erreur

### Prérequis

```bash
# Sur VM100 (openSUSE), en tant que gaby :
# 1. Git + Bash 4+
which git bash
bash --version   # >= 4.0

# 2. Python 3 (pour la génération des SVGs)
python3 --version

# 3. zstd (pour les archives configsnap)
which zstd || echo "WARN: zstd absent — fallback .tar.gz"

# 4. rsync (pour la copie de fichiers config dans le snapshot)
which rsync

# 5. systemctl disponible
systemctl --version
```

### Étape 1 — Cloner le dépôt

```bash
# Sur VM100, avec les droits d'écriture sur /opt/linuxia :
sudo -i
git clone git@github.com:Topbrutus/LinuxIA.git /opt/linuxia
chown -R gaby:users /opt/linuxia
exit
```

### Étape 2 — Rendre les scripts exécutables

```bash
cd /opt/linuxia
chmod +x scripts/*.sh
```

> ⚠️ **Erreur fréquente (exit 126)** : si les scripts ne sont pas exécutables, systemd retourne `Permission denied`. Toujours faire `chmod +x` avant d'installer les unités.

### Étape 3 — Préparer les répertoires de données

```bash
# En tant que root :
sudo -i
install -d -m 0775 -o gaby -g users /opt/linuxia/data/shareA/archives/configsnap
install -d -m 0775 -o gaby -g users /opt/linuxia/logs/health
install -d -m 0775 -o gaby -g users /opt/linuxia/data/shareA/reports/health
exit
```

### Étape 4 — Vérifier les mounts physiques

```bash
# Les disques DATA_1TB_A et DATA_1TB_B doivent être montés sur /mnt/linuxia/ :
ls /mnt/linuxia/DATA_1TB_A/LinuxIA_SMB
ls /mnt/linuxia/DATA_1TB_B/LinuxIA_SMB
```

> Si les répertoires source n'existent pas, les unités `.mount` échoueront (`ConditionPathExists=` non satisfaite).

### Étape 5 — Installer les unités systemd

```bash
cd /opt/linuxia
bash scripts/systemd-install.sh
```

Ce script :
1. Vérifie la présence de tous les fichiers sources dans `services/systemd/`
2. Copie avec `sudo install -m 0644` vers `/etc/systemd/system/`
3. Exécute `sudo systemctl daemon-reload`
4. Active et démarre les timers `linuxia-configsnap.timer` et `linuxia-healthcheck.timer`

> Le timer `linuxia-health-report.timer` doit être installé manuellement depuis `services/` :
> ```bash
> sudo install -m 0644 services/linuxia-health-report.service /etc/systemd/system/
> sudo install -m 0644 services/linuxia-health-report.timer /etc/systemd/system/
> sudo systemctl daemon-reload
> sudo systemctl enable --now linuxia-health-report.timer
> ```

### Étape 6 — Activer les mounts shareA/shareB

```bash
sudo systemctl start opt-linuxia-data-shareA.mount
sudo systemctl start opt-linuxia-data-shareB.mount
sudo systemctl enable opt-linuxia-data-shareA.mount
sudo systemctl enable opt-linuxia-data-shareB.mount
```

### Étape 7 — Créer le wrapper configsnap

```bash
# Le service linuxia-configsnap.service appelle /usr/local/bin/linuxia-snapshot :
sudo install -m 0755 scripts/linuxia-config-snapshot.sh /usr/local/bin/linuxia-snapshot
```

---

## 7. Vérification post-installation

```bash
cd /opt/linuxia

# 1. Vérification syntaxe de tous les scripts
for f in scripts/*.sh; do bash -n "$f" && echo "OK: $f"; done

# 2. Vérification plateforme complète (READ-ONLY)
bash scripts/verify-platform.sh
# Sortie attendue : OK=N WARN=M FAIL=0

# 3. Vérification des timers
bash scripts/verify-systemd.sh

# 4. Test du rapport de santé
OUT_DIR=/tmp bash scripts/health-report.sh
# Sortie attendue : "OK: report written -> /tmp/health-*.txt"

# 5. Vérification des mounts
findmnt -T /opt/linuxia/data/shareA
findmnt -T /opt/linuxia/data/shareB

# 6. Liste des timers actifs
systemctl list-timers --all | grep linuxia
```

### Résultats attendus

| Vérification | Résultat attendu |
|--------------|-----------------|
| `bash -n scripts/*.sh` | Aucune erreur (tous OK) |
| `verify-platform.sh` | `FAIL=0` |
| `verify-systemd.sh` | Sortie sans erreur |
| `health-report.sh` | Fichier `health-*.txt` créé |
| `systemctl list-timers` | 3 timers `linuxia-*` actifs |

---

## 8. Variables d'environnement tunables

Ces variables modifient le comportement des scripts sans éditer les fichiers.

| Variable | Script | Défaut | Description |
|----------|--------|--------|-------------|
| `DISK_WARN_THRESHOLD` | `verify-platform.sh` | `80` | Seuil WARN disque (%) |
| `DISK_FAIL_THRESHOLD` | `verify-platform.sh` | `90` | Seuil FAIL disque (%) |
| `HEALTH_LOG_DIR` | `verify-platform.sh`, `health-report.sh` | `/opt/linuxia/logs/health` | Répertoire des rapports locaux |
| `HEALTH_SHARE_DIR` | `verify-platform.sh`, `health-report.sh` | `/opt/linuxia/data/shareA/reports/health` | Copie shareA des rapports |
| `HEALTH_GLOB` | `verify-platform.sh` | `health-*.txt` | Pattern fichiers rapports |
| `HEALTH_MAX_AGE_SECONDS` | `verify-platform.sh` | `172800` (48h) | Âge max avant WARN |
| `OUT_DIR` | `health-report.sh` | `/opt/linuxia/logs/health` | Répertoire de sortie |
| `SHAREA_DIR` | `health-report.sh` | `/opt/linuxia/data/shareA/reports/health` | Copie shareA |
| `ROOT` | `gen-readme-linuxia.sh` | `/opt/linuxia` | Racine du repo |
| `REPO_DIR` | `linuxia-phase6.sh` | `/opt/linuxia` | Racine du repo |

---

*Généré le 2026-02-23 — LinuxIA Proof-First Suite*
