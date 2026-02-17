# LinuxIA — Agent Ops "preuve-first" (openSUSE / systemd / GitHub)

But : automatiser des tâches Ops de manière **auditée**, **reproductible**, et **safe-by-default** (*read-only par défaut*).

## Ce qui marche déjà (preuve)
- ✅ `scripts/verify-platform.sh` : checks infra + timers + mounts + health reports (summary OK/WARN/FAIL)
- ✅ Rapports "health" via systemd + copie best-effort sur shareA (chmod-safe)
- ✅ CI verte sur PRs + merges squash

## Démarrage rapide
```bash
cd /opt/linuxia
bash scripts/verify-platform.sh
```

## Où sont les rapports

* Local : `/opt/linuxia/logs/health/`
* Copie (si shareA monté) : `/opt/linuxia/data/shareA/reports/health/`

## Comment aider (sans qu'on ait à le demander)

On cherche des contributeurs pour :

* Docs / runbook : standardiser procédures + troubleshooting
* CI/tests : renforcer "proof-first" (logs, exit codes, smoke checks)
* Hardening : permissions, chmod-safe sur partages, patterns `set -e` robustes
* Packaging : scripts/systemd units, conventions, structure repo

➡️ Prends une issue "good first issue" ou propose une amélioration via PR.

---

# LinuxIA

LinuxIA est un projet expérimental centré sur l’exploration, la compréhension
et la mise en pratique de systèmes techniques sous Linux.

L’objectif n’est pas de livrer un produit fini, mais de construire,
tester et documenter des idées autour de :
- l’infrastructure Linux
- l’automatisation maîtrisée
- les scripts système
- l’observation et la vérification des états

Le projet évolue par itérations courtes :
- on observe
- on expérimente
- on vérifie
- on corrige

LinuxIA privilégie :
- la clarté plutôt que la complexité
- les preuves plutôt que les suppositions
- le contrôle humain plutôt que l’automatisation aveugle

Les outils utilisés incluent principalement :
- Linux (openSUSE)
- systemd
- shell scripting
- Git / GitHub

Ce dépôt sert à la fois de terrain d’essai et de journal technique.
Certaines parties peuvent être brutes, incomplètes ou évoluer rapidement.

LinuxIA est avant tout un espace d’apprentissage, d’expérimentation
et de compréhension approfondie des systèmes.

Curieux bienvenus.

## Tableau de bord (Ops)

👉 Voir: **[docs/tableau.md](docs/tableau.md)** (checks rapides, health reports, CI, release, issues)
