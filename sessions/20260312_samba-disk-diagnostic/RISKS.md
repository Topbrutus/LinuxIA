# Risques — Diagnostic Samba Disk

## Risques identifiés

### R1 — Corruption de données
- **Probabilité**: Moyenne à Élevée
- **Impact**: Critique
- **Description**: Si partition redimensionnée incorrectement, données peuvent être corrompues
- **Mitigation**: Mode lecture seule, aucune modification sans backup

### R2 — Perte de données
- **Probabilité**: Moyenne
- **Impact**: Critique
- **Description**: Opération de partition mal exécutée peut causer perte de données
- **Mitigation**: Créer image/backup avant toute tentative de récupération

### R3 — Système de fichiers endommagé
- **Probabilité**: Moyenne
- **Impact**: Élevé
- **Description**: NTFS filesystem peut être dans un état incohérent
- **Mitigation**: Utiliser ntfsfix en lecture seule d'abord

### R4 — Table de partition corrompue
- **Probabilité**: Faible à Moyenne
- **Impact**: Critique
- **Description**: GPT/MBR peut être endommagé
- **Mitigation**: Sauvegarder table de partition avant modification

### R5 — Mauvais diagnostic
- **Probabilité**: Faible
- **Impact**: Moyen
- **Description**: Sans accès direct à VM100, diagnostic limité
- **Mitigation**: Fournir script à exécuter sur VM100 pour collecte d'info complète
