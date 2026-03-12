# Guide de Diagnostic — Problème Disque Samba

Date: 2026-03-12
Session: 20260312_samba-disk-diagnostic

## Contexte

Vous avez signalé une panne de disque dur avec Samba, possiblement causée par un agrandissement de partition et un déplacement de bloc. Le système fonctionnait correctement le 2026-02-08 (checkpoint A validé).

## Symptômes attendus possibles

Selon le type de problème, vous pourriez rencontrer:

1. **Partition non montable**
   - Erreur: `mount: wrong fs type, bad option, bad superblock`
   - Cause: Table de partition ou superblock NTFS corrompu

2. **Samba ne démarre pas ou partages inaccessibles**
   - Erreur: `Unable to find share path`
   - Cause: Montages échoués, chemins incorrects

3. **Erreurs I/O dans dmesg**
   - Erreur: `Buffer I/O error on device sdb6`
   - Cause: Secteurs endommagés, problème matériel

4. **Partition plus petite que le filesystem**
   - Erreur: `Filesystem size larger than device size`
   - Cause: Partition réduite alors que NTFS utilise plus d'espace

5. **Overlapping partitions**
   - Erreur: `Partition overlaps with partition`
   - Cause: Table de partition mal éditée

## Étapes de diagnostic

### Étape 1: Exécuter le script de diagnostic complet

Sur VM100, en tant que root:

```bash
cd /opt/linuxia
sudo bash scripts/04-diagnostic-samba-disk-issue.sh
```

Ce script va:
- ✅ Lister tous les disques et partitions
- ✅ Vérifier les tables de partition (GPT/MBR)
- ✅ Vérifier l'intégrité NTFS (mode lecture seule)
- ✅ Vérifier les montages actuels
- ✅ Vérifier l'état de Samba
- ✅ Analyser les logs système (dmesg, journalctl)
- ✅ Comparer avec le snapshot du 2026-02-08
- ✅ Vérifier la santé SMART des disques

**Important**: Ce script est en **mode lecture seule**, il ne modifie rien.

### Étape 2: Analyser les résultats

Le script génère deux fichiers:
- `docs/verifications/diagnostic_samba_disk_<timestamp>.txt`
- `sessions/20260312_samba-disk-diagnostic/evidence/diagnostic_<timestamp>.txt`

Cherchez dans le rapport:

#### Section "NTFS Filesystem Health"
- Si `ntfsfix` rapporte des erreurs → filesystem corrompu
- Si "inconsistent" ou "needs repair" → réparation nécessaire

#### Section "Partition Tables"
- Regardez si les tailles de partition ont changé
- Vérifiez s'il y a des overlaps (chevauchements)
- Comparez avec le snapshot du 2026-02-08

#### Section "Recent kernel messages (dmesg)"
- Erreurs I/O → problème matériel ou corruption
- "NTFS-fs error" → problème filesystem
- "partition table" → problème table de partition

#### Section "Summary"
- Liste des issues et warnings
- Status final

### Étape 3: Collecte d'information manuelle

Si le script ne peut pas s'exécuter ou ne donne pas assez d'info:

```bash
# 1. État actuel des disques
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS /dev/sdb /dev/sdc

# 2. Table de partition détaillée
sudo fdisk -l /dev/sdb
sudo fdisk -l /dev/sdc
sudo parted /dev/sdb print
sudo parted /dev/sdc print

# 3. Vérification NTFS (lecture seule)
sudo ntfsfix --no-action /dev/sdb6
sudo ntfsfix --no-action /dev/sdc3

# 4. Logs récents
sudo dmesg -T | grep -i 'sd[bc]' | tail -50
sudo journalctl -n 100 -p err

# 5. État Samba
systemctl status smb nmb
testparm -s /etc/samba/smb.conf
```

## Scénarios et solutions

### Scénario 1: Partition agrandie mais filesystem pas étendu

**Symptôme**: Partition plus grande mais espace utilisable inchangé

**Diagnostic**:
```bash
sudo parted /dev/sdb unit s print  # Voir taille partition en secteurs
sudo ntfsinfo /dev/sdb6 | grep 'Volume Size'  # Comparer avec taille NTFS
```

**Solution**:
```bash
# ATTENTION: Backup d'abord!
sudo ntfsresize -i /dev/sdb6  # Info mode (lecture seule)
# Si OK:
sudo ntfsresize /dev/sdb6  # Étendre filesystem
```

### Scénario 2: Partition réduite en dessous de la taille du filesystem

**Symptôme**: Erreur "filesystem larger than device"

**Diagnostic**:
```bash
sudo ntfsresize -i /dev/sdb6  # Voir minimum size possible
```

**Solution**:
```bash
# Option 1: Restaurer taille partition originale
sudo parted /dev/sdb
# resizepart 6 <taille-originale-en-GB>
# quit

# Option 2: Réduire le filesystem PUIS la partition (DANGEREUX!)
# NE PAS faire sans backup complet!
```

### Scénario 3: Table de partition corrompue

**Symptôme**: Partitions non détectées ou erreurs "invalid partition table"

**Diagnostic**:
```bash
sudo sgdisk --verify /dev/sdb
sudo gdisk -l /dev/sdb
```

**Solution**:
```bash
# Si GPT backup existe:
sudo sgdisk --load-backup=/path/to/backup.bin /dev/sdb

# Sinon, utiliser testdisk (interactif):
sudo testdisk /dev/sdb
```

### Scénario 4: Filesystem NTFS corrompu

**Symptôme**: ntfsfix rapporte des erreurs, montage échoue

**Solution**:
```bash
# Étape 1: Vérification seule
sudo ntfsfix --no-action /dev/sdb6

# Étape 2: Si réparable, réparer
sudo ntfsfix /dev/sdb6

# Étape 3: Si ntfsfix échoue, chkdsk depuis Windows
# Monter le disque sur Windows et exécuter:
# chkdsk X: /F /R
```

## Checklist avant toute modification

Avant de faire QUOI QUE CE SOIT qui modifie les disques:

- [ ] Arrêter Samba: `sudo systemctl stop smb nmb`
- [ ] Démonter toutes les partitions concernées
- [ ] Backup de la table de partition:
  ```bash
  sudo sfdisk -d /dev/sdb > /tmp/sdb_partition_backup.txt
  sudo sfdisk -d /dev/sdc > /tmp/sdc_partition_backup.txt
  ```
- [ ] Backup du MBR/GPT:
  ```bash
  sudo dd if=/dev/sdb of=/tmp/sdb_mbr.bin bs=512 count=1
  sudo sgdisk --backup=/tmp/sdb_gpt.bin /dev/sdb
  ```
- [ ] Si possible, image complète du disque:
  ```bash
  sudo dd if=/dev/sdb of=/path/to/backup/sdb.img bs=4M status=progress
  # ATTENTION: Nécessite espace libre >= taille du disque!
  ```

## Ce dont j'ai besoin de vous

Pour vous aider davantage, merci de:

1. **Exécuter le script de diagnostic**:
   ```bash
   sudo bash /opt/linuxia/scripts/04-diagnostic-samba-disk-issue.sh
   ```

2. **Me fournir le fichier de résultat**:
   - Soit copier/coller le contenu
   - Soit push vers le repo git (le script le fait automatiquement)

3. **Décrire les symptômes précis**:
   - Qu'est-ce qui ne fonctionne pas exactement?
   - Quels messages d'erreur voyez-vous?
   - Quelle opération avez-vous effectuée avant le problème?
   - Avez-vous utilisé quel outil? (parted, gparted, fdisk, etc.)

4. **Historique des commandes** (si vous vous en souvenez):
   - Quelle partition avez-vous modifiée? (sdb6? sdc3?)
   - Quelle était la taille avant/après?

## Options de récupération

Si les données sont critiques et le problème grave:

### Option A: Récupération de données
- Utiliser `testdisk` pour scanner et récupérer partitions
- Utiliser `photorec` pour récupération de fichiers
- Copier données importantes avant réparation

### Option B: Restauration depuis backup
- Si vous avez un backup des données
- Recréer table de partition from scratch
- Reformater et restaurer

### Option C: Réparation guidée
- Une fois le diagnostic complet reçu
- Je vous fournirai les commandes exactes étape par étape
- Avec vérifications entre chaque étape

## Ressources

- Script diagnostic: `scripts/04-diagnostic-samba-disk-issue.sh`
- Session docs: `sessions/20260312_samba-disk-diagnostic/`
- Risks: `sessions/20260312_samba-disk-diagnostic/RISKS.md`
- Rollback: `sessions/20260312_samba-disk-diagnostic/ROLLBACK.md`

## Contact / Questions

N'hésitez pas à me fournir plus de détails sur:
- Les symptômes exacts
- Ce que vous avez tenté de faire
- Les messages d'erreur que vous voyez
- Le résultat du script de diagnostic

Je pourrai alors vous fournir des instructions précises et sécuritaires pour résoudre le problème.
