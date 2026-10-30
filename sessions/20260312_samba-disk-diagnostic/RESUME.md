# Résumé — Diagnostic Panne Samba

Date: 2026-03-12
Session: 20260312_samba-disk-diagnostic

## 📋 Ce qui a été fait

J'ai créé un ensemble complet d'outils de diagnostic pour vous aider à identifier et résoudre votre problème de disque Samba.

### Fichiers créés

1. **Script de diagnostic complet** (`scripts/04-diagnostic-samba-disk-issue.sh`)
   - Analyse complète des disques et partitions
   - Vérification de la santé NTFS
   - Analyse des logs système
   - Comparaison avec l'état précédent (2026-02-08)
   - Mode lecture seule (aucune modification)

2. **Guide de diagnostic détaillé** (`sessions/20260312_samba-disk-diagnostic/GUIDE_DIAGNOSTIC.md`)
   - Explications des symptômes possibles
   - Scénarios courants et solutions
   - Checklist de sécurité avant réparation
   - Options de récupération

3. **Référence rapide** (`sessions/20260312_samba-disk-diagnostic/QUICK_REF.md`)
   - Commandes essentielles
   - Étapes prioritaires

4. **Documentation de session**
   - `SESSION.md`: Objectifs et hypothèses
   - `TODO.md`: Liste des tâches
   - `RISKS.md`: Risques identifiés et mitigations
   - `ROLLBACK.md`: Plan de retour arrière
   - `STATUS.md`: État de la session

## 🎯 Prochaines étapes

### Étape 1: Exécuter le diagnostic (SUR VM100)

```bash
cd /opt/linuxia
sudo bash scripts/04-diagnostic-samba-disk-issue.sh
```

Ce script va générer un rapport complet dans:
- `docs/verifications/diagnostic_samba_disk_<timestamp>.txt`

### Étape 2: Me fournir les informations

Pour que je puisse vous aider davantage, j'ai besoin de:

1. **Le résultat du script de diagnostic** (fichier généré ci-dessus)

2. **Description précise du problème**:
   - Quel est le symptôme exact? (ne monte pas? erreur? Samba ne démarre pas?)
   - Quelle opération avez-vous effectuée? (agrandir partition sdb6? sdc3?)
   - Quel outil avez-vous utilisé? (gparted? parted? fdisk?)
   - Taille avant/après (si vous vous en souvenez)?

3. **Messages d'erreur** (si vous en voyez):
   - Copier/coller les messages d'erreur exacts
   - Dans quel contexte apparaissent-ils?

### Étape 3: Analyse et plan de récupération

Une fois que j'aurai ces informations, je pourrai:
- Identifier la cause exacte du problème
- Vous fournir les commandes précises pour réparer
- Vous guider étape par étape avec vérifications

## 🔍 Diagnostic possible sans accès à VM100

Si vous ne pouvez pas exécuter le script, vous pouvez me fournir manuellement:

```bash
# 1. État des disques
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS /dev/sdb /dev/sdc

# 2. Tables de partition
sudo fdisk -l /dev/sdb
sudo fdisk -l /dev/sdc
sudo parted /dev/sdb print
sudo parted /dev/sdc print

# 3. Logs d'erreurs
sudo dmesg -T | grep -iE '(sd[bc]|ntfs|error)' | tail -50
sudo journalctl -n 50 -p err

# 4. État Samba
systemctl status smb nmb
```

## ⚠️ IMPORTANT: Avant toute réparation

**NE FAITES AUCUNE MODIFICATION** avant que nous ayons:
1. ✅ Identifié le problème exact
2. ✅ Créé des backups appropriés
3. ✅ Un plan de récupération clair

### Checklist de sécurité

- [ ] Arrêter Samba: `sudo systemctl stop smb nmb`
- [ ] Démonter les partitions affectées
- [ ] Backup de la table de partition:
  ```bash
  sudo sfdisk -d /dev/sdb > /tmp/sdb_partition_backup.txt
  sudo sfdisk -d /dev/sdc > /tmp/sdc_partition_backup.txt
  ```

## 📚 Ressources disponibles

Tous les fichiers sont dans le repo Git, branche `claude/debug-samba-disk-issues`:

- `scripts/04-diagnostic-samba-disk-issue.sh` - Script de diagnostic
- `sessions/20260312_samba-disk-diagnostic/GUIDE_DIAGNOSTIC.md` - Guide complet
- `sessions/20260312_samba-disk-diagnostic/QUICK_REF.md` - Référence rapide
- `sessions/20260312_samba-disk-diagnostic/RISKS.md` - Analyse des risques
- `sessions/20260312_samba-disk-diagnostic/ROLLBACK.md` - Plan de rollback

## 🤝 Comment me fournir les infos

Vous pouvez soit:

1. **Via Git** (automatique):
   - Le script de diagnostic commit et push automatiquement les résultats
   - Ils apparaîtront dans le repo

2. **Manuellement**:
   - Copier/coller le contenu du fichier de diagnostic ici
   - Ou me décrire les symptômes et erreurs que vous voyez

## 💡 Scénarios probables

Basé sur votre description ("agrandir partition + déplacer bloc"), voici les scénarios les plus probables:

### Scénario A: Partition agrandie, filesystem pas étendu
- **Symptôme**: Espace disque inchangé malgré partition plus grande
- **Solution**: Étendre le filesystem NTFS avec `ntfsresize`
- **Risque**: Faible

### Scénario B: Partition réduite sous la taille du filesystem
- **Symptôme**: Partition ne monte pas, erreur "filesystem larger than device"
- **Solution**: Restaurer taille originale de partition
- **Risque**: Moyen (si données à la fin de la partition)

### Scénario C: Bloc déplacé incorrectement
- **Symptôme**: Erreurs I/O, corruption de filesystem
- **Solution**: Vérifier/réparer filesystem avec ntfsfix ou chkdsk
- **Risque**: Moyen à Élevé (possible perte de données)

### Scénario D: Table de partition corrompue
- **Symptôme**: Partition non reconnue, erreurs "invalid partition table"
- **Solution**: Restaurer table de partition ou recréer
- **Risque**: Élevé

## ❓ Questions?

N'hésitez pas à:
- Exécuter le script de diagnostic
- Me décrire ce que vous voyez
- Me poser des questions sur les étapes

Je suis là pour vous aider à résoudre ce problème de manière sûre et méthodique.

---

**TASK**: Diagnostic panne disque Samba suite resize partition/déplacement bloc

**CONTEXT**:
- VM100 (vm100-factory, openSUSE Leap 16.0)
- 2 disques 1TB: DATA_1TB_A (sdb6), DATA_1TB_B (sdc3)
- Système fonctionnel le 2026-02-08 (checkpoint A validé)
- Opération de partition probablement incorrecte

**CONSTRAINTS**:
- Mode diagnostic lecture seule (pas de modification sans validation)
- Backup obligatoire avant toute réparation
- Anti-fausse preuve (VM100 only)
- Pas d'accès root depuis GitHub Actions

**DONE_CRITERIA**:
- Script de diagnostic exécuté sur VM100
- Rapport d'analyse généré
- Cause exacte identifiée
- Plan de récupération fourni avec commandes précises
- Preuves: logs, outputs, diffs

**RESULT**:
✅ Outils de diagnostic créés et documentés
⏳ En attente: exécution du diagnostic sur VM100 par l'utilisateur

**EVIDENCE**:
- scripts/04-diagnostic-samba-disk-issue.sh (script diagnostic complet)
- sessions/20260312_samba-disk-diagnostic/* (documentation complète)
- Commit: 413b453

**RISKS**:
- R1: Corruption de données (mitigation: lecture seule)
- R2: Perte de données (mitigation: backup avant réparation)
- R3: Filesystem endommagé (mitigation: ntfsfix lecture seule d'abord)
- R4: Table partition corrompue (mitigation: backup table avant modif)
- R5: Mauvais diagnostic (mitigation: script complet + info manuelle)

**NEXT**:
1. Utilisateur exécute: `sudo bash scripts/04-diagnostic-samba-disk-issue.sh`
2. Utilisateur fournit résultat + description symptômes
3. Analyse des résultats
4. Fourniture plan de récupération détaillé
5. Guidage étape par étape pour réparation
