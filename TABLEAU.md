# TABLEAU — LinuxIA (Dashboard)

## État actuel (preuve rapide)
- Branche: `main`
- CI: green (2/2)
- verify-platform: OK=24 WARN=0 FAIL=0
- Releases: v0.1.0 (Phases 6–8)

## Phases livrées (résumé)
| Phase | Sujet | Statut | PR | Commit |
|------:|-------|--------|----|--------|
| 6 | health checks + docs | ✅ MERGED | #6 | 5b923e8 |
| 7 | fix `verify-platform` (_hc_bump_warn set -e safe) | ✅ MERGED | #7 | 4d52f64 |
| 8 | README vitrine + contribution hooks | ✅ MERGED | #8 | c0ea182 |

## Commandes "preuve" (copier-coller)
### Proof état repo + logs
```bash
cd /opt/linuxia || exit 1
git status -sb
git log --oneline -5
bash scripts/verify-platform.sh | tail -n 25
```

### Voir les issues récentes
```bash
cd /opt/linuxia || exit 1
gh issue list --limit 25
```

## Next (prochain chantier)

Phase 9 (au choix):
- mounts/perms (shareA/shareB) + standard systemd
- docs/runbook "ops réel" + troubleshooting CI
- polish README (badges + lien "Start here" + sections courtes)
