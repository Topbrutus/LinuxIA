# Contributing to LinuxIA

👋 Merci de ton intérêt ! LinuxIA est un projet de recherche en sécurité système qui accueille les contributions avec joie.

## 🚀 Démarrage rapide (15 min)

1. **Fork** le repo → clone ta copie
2. **Lis** `README.md` + `docs/runbook.md`
3. **Choisis** une [good first issue](https://github.com/Topbrutus/LinuxIA/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
4. **Teste** tes changements (scripts: `bash -n`, docs: aperçu Markdown)
5. **PR** avec titre clair + référence à l'issue (`Fixes #X`)

## 📋 Types de contributions

- **Documentation** (runbook, troubleshooting, architecture)
- **CI/Tests** (smoke tests, ShellCheck, GitHub Actions)
- **Scripts** (améliorations robustesse, conformité bash)
- **Tooling** (`make doctor`, helpers de déploiement)

## ✅ Critères d'acceptation

- **Scripts shell** : compatibles bash, sans `echo` superflu, avec gestion d'erreurs
- **Docs** : courts, concrets, avec commandes reproductibles
- **Commits** : messages clairs, atomiques (1 idée = 1 commit)
- **Tests** : manuelss (on automatise progressivement via CI)

## 🔐 Règles importantes

- **Pas de secrets** dans le code (use `.env` ou vault)
- **Pas de `sudo` en vrac** (seulement `sudo -i` quand documenté)
- **Pas de modifications** de `data/`, `logs/`, `workspace/` (hors Git)

## 🤝 Code de conduite

Respect, bienveillance, collaboration. On est là pour apprendre et construire ensemble.

## 💬 Questions ?

- Commente directement dans l'issue
- Ou ouvre une [discussion](https://github.com/Topbrutus/LinuxIA/discussions)

**Bon code !** 🚀
