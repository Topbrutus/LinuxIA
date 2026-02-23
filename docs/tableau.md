# Tableau de bord LinuxIA (Ops)

Ce tableau sert de **panneau de contrôle rapide** : quoi vérifier, comment, et ce qui est attendu.

| Zone | Commande | Attendu |
|---|---|---|
| État repo | `git status -sb` | `main` + clean |
| Vérif plateforme | `bash scripts/verify-platform.sh` | `OK=.. WARN=0 FAIL=0` |
| Health report (run) | `sudo systemctl start linuxia-health-report.service` | service OK |
| Health report (status) | `sudo systemctl status linuxia-health-report.service --no-pager -l` | active / exited (0) |
| Dernier report local | `ls -lt /opt/linuxia/logs/health \| head -n 3` | fichier récent |
| Dernier report shareA | `ls -lt /opt/linuxia/data/shareA/reports/health \| head -n 3` | fichier récent (match) |
| CI (dernier) | `gh run list --limit 5` | runs verts |
| Release | `gh release list --limit 5` | v0.1.0 visible |
| Issues "Start here" | `gh issue list --label "good first issue" --limit 10` | liste cohérente |

## Routine "preuve" (1 minute)
```bash
cd /opt/linuxia || exit 1
bash scripts/verify-platform.sh | grep -E "=== Summary ===|OK=|WARN=|FAIL=" -n || true
ls -lt /opt/linuxia/logs/health | head -n 2 || true
ls -lt /opt/linuxia/data/shareA/reports/health | head -n 2 || true
```
