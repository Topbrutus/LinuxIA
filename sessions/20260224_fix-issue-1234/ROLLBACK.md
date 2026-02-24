# ROLLBACK — fix-issue-1234

## Retour arrière
Supprimer le dossier de session créé :
```
rm -rf sessions/20260224_fix-issue-1234/
git add -A && git commit -m "revert: remove session 20260224_fix-issue-1234"
```

Aucun autre fichier n'a été modifié ; le rollback est sans risque.
