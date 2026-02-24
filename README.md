# LinuxIA — Proof-First Agent Ops 🧪

<!-- VITRINE_BEGIN -->

## ⚡ Vitrine (avancement rapide)

LinuxIA est un projet open-source orienté Ops / automatisation / preuve-first (scripts + systemd + runbook).
Objectif: une base robuste, reproductible, auditable.

### Ce que tu peux faire maintenant (facile)
- Lire le runbook: [docs/runbook.md](docs/runbook.md)
- Vérifier la plateforme: `bash scripts/verify-platform.sh`
- Prendre une issue [help wanted](https://github.com/Topbrutus/LinuxIA/labels/help%20wanted) / [good first issue](https://github.com/Topbrutus/LinuxIA/labels/good%20first%20issue)

### Principes
- **Proof-first**: logs et commandes reproductibles
- **Incremental only**: on n'enlève pas, on améliore proprement
- **CI + docs**: chaque changement laisse une trace claire
<!-- VITRINE_END -->

[![CI](https://github.com/Topbrutus/LinuxIA/actions/workflows/linuxia-ci.yml/badge.svg)](https://github.com/Topbrutus/LinuxIA/actions/workflows/linuxia-ci.yml) [![Release](https://img.shields.io/github/v/release/Topbrutus/LinuxIA?sort=semver)](https://github.com/Topbrutus/LinuxIA/releases)

> EN: Deterministic multi-VM orchestration with mandatory evidence generation.  
> FR: Orchestration multi-VM déterministe avec génération de preuves obligatoire.

Built on Proxmox + openSUSE + systemd + GitHub CI.

---

## Abstract / Résumé

**EN:** LinuxIA is an experimental infrastructure orchestration framework designed around a strict principle:

> **No change without proof.**

Every infrastructure mutation must produce verifiable, timestamped evidence. LinuxIA combines reproducible automation, multi-VM isolation, and CI enforcement to build a proof-driven operational model.

**FR:** LinuxIA est un framework expérimental d'orchestration d'infrastructure basé sur un principe strict :

> **Aucun changement sans preuve.**

Chaque action sur l'infrastructure doit produire des preuves vérifiables et horodatées. LinuxIA combine automatisation reproductible, isolation multi-VM et validation CI pour construire un modèle opérationnel "proof-driven".

---

## Core Principles / Principes clés 🎯

### 1. Proof-First Operations / Opérations "Proof-First"

Every action produces / Chaque action produit :
- Timestamped execution logs / Logs d'exécution horodatés
- Deterministic output / Sorties déterministes
- CI validation trace / Traces de validation CI
- Health verification artifacts / Artéfacts de vérification de santé

No silent changes / Aucun changement silencieux.

### 2. Deterministic Automation / Automatisation déterministe

- Bash scripts with `set -euo pipefail`
- ShellCheck validation
- Explicit exit codes / Codes de sortie explicites
- Structured output expectations / Attentes de sortie structurées

### 3. Isolation by Design / Isolation par conception 🔒

Multi-VM topology reduces systemic coupling / La topologie multi-VM réduit le couplage systémique.

| VM | Role (EN) | Rôle (FR) |
|----|-----------|-----------|
| VM100 (vm100-factory) | Main repo, storage, Samba, health reports | Repo principal, stockage, Samba, rapports de santé |
| VM101 (vm101-layer2) | CIFS client validation, independent evidence | Validation client CIFS, preuves indépendantes |
| VM102 (vm102-tool) | Sandbox, tests, API orchestrator experiments | Bac à sable, tests, expériences API orchestrateur |

### 4. CI-Backed Integrity / Intégrité appuyée par CI ✅

GitHub PR workflow enforces controlled integration / Le workflow PR GitHub impose une intégration contrôlée :
- Validation before merge / Validation avant merge
- Branch protection / Protection de branches
- Review traceability / Traçabilité des reviews

`main` is stable / `main` est stable.

---

## System Architecture / Architecture du système 🏗️

```
User → Script → systemd timer → Verification → Artifact → CI check → Merge
```

| Path | Role (EN) | Rôle (FR) |
|------|-----------|-----------|
| `/scripts/` | Deterministic operational commands | Commandes opérationnelles déterministes |
| `/services/` | systemd units & timers | Unités & timers systemd |
| `/docs/` | Operational proof & status | Preuves & statut opérationnel |
| `.github/workflows/` | CI validation | Validation CI |

All state transitions must be observable / Tous les changements d'état doivent être observables.

→ Detailed diagram: [`docs/architecture.md`](docs/architecture.md)

---

## Quick Start / Démarrage rapide 🚀

```bash
git clone git@github.com:Topbrutus/LinuxIA.git /opt/linuxia
cd /opt/linuxia
bash scripts/verify-platform.sh
```

Expected result / Résultat attendu :
```
OK >= 20
WARN >= 0
FAIL = 0
```

→ Full onboarding guide: [`docs/start-here.md`](docs/start-here.md)

---

## Current Status / Statut actuel 📌

- ✅ Phase 6 merged / Phase 6 mergée
- ✅ Health reports operational / Rapports de santé opérationnels
- ✅ systemd timers validated / Timers systemd validés
- ✅ CI active
- ✅ Security policy defined / Politique de sécurité définie

Proof references / Références de preuves :
- [`docs/status.md`](docs/status.md)
- [`docs/runbook.md`](docs/runbook.md)
- [`docs/checklists/`](docs/checklists/)

---

## Governance Model / Modèle de gouvernance 🤝

EN: LinuxIA is publicly visible and open to contributions. However:
- Architectural direction remains under core maintainership
- Infrastructure & security changes are strictly reviewed
- All changes must pass CI and proof validation

FR: LinuxIA est public et ouvert aux contributions. Toutefois :
- La direction d'architecture reste sous maintenance "core"
- Les changements infra & sécurité sont revus strictement
- Tout doit passer CI et validation par preuves

This is controlled open governance / Gouvernance ouverte mais contrôlée.

---

## Security Model / Modèle de sécurité 🛡️

Responsible disclosure via [`SECURITY.md`](SECURITY.md) / Divulgation responsable via `SECURITY.md`.

Please do not open public issues for critical vulnerabilities /
Merci de ne pas ouvrir d'issues publiques pour les vulnérabilités critiques.

---

## Contribution Guidelines / Guide de contribution ✍️

Contributions are welcome if they / Les contributions sont bienvenues si elles :
- Preserve determinism & reproducibility / Préservent déterminisme & reproductibilité
- Do not weaken CI enforcement / Ne réduisent pas les protections CI
- Keep proof generation intact / Maintiennent la génération de preuves

See / Voir : [`CONTRIBUTING.md`](CONTRIBUTING.md)

---

## Research Scope / Portée de recherche 🔬

EN: LinuxIA is not yet production-ready. It is a research framework exploring:
- Agent-assisted infrastructure management
- Proof-driven DevOps
- Multi-VM validation patterns
- Deterministic operational pipelines

FR: LinuxIA n'est pas encore "production-ready". C'est un framework de recherche explorant :
- Gestion infra assistée par agents
- DevOps piloté par preuves
- Patterns de validation multi-VM
- Pipelines opérationnels déterministes

---

## License / Licence 📄

To be defined / À définir.

<!-- LINUXIA_CINEMATIC_CARDS_BEGIN -->

## 🎞️ Vitrine — Cinematic Cards (GitHub-safe, 0 JS)

<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_01.svg" width="100%" alt="Vision &amp; Platform"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_02.svg" width="100%" alt="Architecture"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_03.svg" width="100%" alt="Agents TriluxIA"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_04.svg" width="100%" alt="Immutable Proof"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_05.svg" width="100%" alt="Infra &amp; Timers"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_06.svg" width="100%" alt="Security"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_07.svg" width="100%" alt="Storage &amp; Shares"/>
</p>
<p align="center">
  <img src="assets/readme/cinematic/cards/section_gallery_08.svg" width="100%" alt="Roadmap"/>
</p>

<!-- LINUXIA_CINEMATIC_CARDS_END -->

