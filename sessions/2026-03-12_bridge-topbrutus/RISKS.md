# RISKS.md — Bridge topbrutus.com

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Secret webhook absent → toute requête acceptée | Moyen | Moyen | Documenter + avertissement au démarrage |
| Fichier JSONL non flushé / corruption | Faible | Faible | Écriture ligne par ligne avec verrou threading |
| Montée en charge (nombreux events) | Faible | Faible | Limiter `?limit=200` max ; prévoir rotation |
| Données sensibles dans payload GitHub | Moyen | Moyen | Ne stocker que le résumé, pas le payload brut |
