# ROLLBACK.md — Bridge topbrutus.com

## Revenir en arrière

Tous les nouveaux fichiers sont dans `bridge/` et `tests/test_bridge.py`.
Le code existant n'a pas été modifié.

Pour annuler entièrement :
```bash
git rm -r bridge/
git rm tests/test_bridge.py
git rm -r sessions/2026-03-12_bridge-topbrutus/
git commit -m "revert: suppression bridge topbrutus"
```

Aucun service système ou script existant n'est impacté.
