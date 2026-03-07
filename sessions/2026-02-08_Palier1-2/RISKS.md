# RISKS — Session 2026-02-08 Palier 1-2 (Audit + LLM Local)

Périmètre : VM100 (Factory), Proxmox, stockage NTFS, Samba, Docker, LLM local.  
Règle d'arrêt : toute anomalie marquée ⛔ ou deux anomalies 🚩 consécutives → STOP + retour au dernier checkpoint stable.

---

## Risques identifiés et mitigations

| # | Icône | Risque | Impact | Mitigation |
|---|-------|--------|--------|-----------|
| R-S1 | ⛔ | **Accès SSH KO** — impossible d'automatiser | Bloquant total | Valider SSH dès le départ ; rollback total si KO |
| R-S2 | 🚩 | **Horloge ou timezone incohérents** — logs non vérifiables | Preuves contestables | Synchroniser avec NTP avant toute session ; vérifier `timedatectl` |
| R-S3 | 🚩 | **Espace disque saturé** — installation/evidence impossible | Blocage installation | Vérifier `df -h` avant toute installation ; seuil minimal 5 Go libre |
| R-S4 | 🚩 | **Ports/DNS/firewall mal configuré** — bloque installation ou usage LLM | Blocage réseau | Documenter chaque règle firewall ; tester DNS avant installation |
| R-S5 | 🌀 | **Erreur de montage disques externes** — risque corruption | Corruption données | Documenter points de montage exacts ; interdire double attache simultanée |
| R-S6 | 🚨 | **Échec installation Docker ou LLM** — blocage palier | Blocage déploiement | Scripts versionnés + `rollback.txt` ; image Docker sauvegardée localement |
| R-S7 | ⚡ | **Logs non persistants** — perte de preuve, non-conformité | Perte de traçabilité | Stocker dans `logs/session.jsonl` sur filesystem local ou externe monté |
| R-S8 | 🔒 | **Mots de passe root ou SSH actifs** — risque sécurité | Exposition accès root | Désactivation progressive ; validation par log SSH ; clé publique obligatoire |

---

## Règle d'arrêt (STOP_RULE)

Toute anomalie majeure (⛔) ou deux anomalies critiques (🚩) consécutives arrêtent la session immédiatement.  
Retour au dernier checkpoint stable documenté dans `ROLLBACK.md`.
