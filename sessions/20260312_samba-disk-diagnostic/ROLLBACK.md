# Rollback Plan — Diagnostic Samba Disk

## Point de départ stable
- Checkpoint A (2026-02-08): Storage + Samba validé
- Tag git: checkpoint-a-storage-validated
- Evidence: sessions/2026-02-08_Palier1-2/

## Procédure de rollback (si nécessaire)

### Étape 1: Arrêter Samba
```bash
sudo systemctl stop smb nmb
```

### Étape 2: Démonter les partitions affectées
```bash
sudo umount /srv/linuxia-share/DATA_1TB_A
sudo umount /srv/linuxia-share/DATA_1TB_B
sudo umount /opt/linuxia/data/shareA
sudo umount /opt/linuxia/data/shareB
sudo umount /mnt/linuxia/DATA_1TB_A
sudo umount /mnt/linuxia/DATA_1TB_B
```

### Étape 3: Vérifier intégrité
```bash
sudo ntfsfix --no-action /dev/sdb6  # lecture seule
sudo ntfsfix --no-action /dev/sdc3  # lecture seule
```

### Étape 4: Backup de la table de partition
```bash
sudo sfdisk -d /dev/sdb > /tmp/sdb_partition_table_backup.txt
sudo sfdisk -d /dev/sdc > /tmp/sdc_partition_table_backup.txt
sudo sgdisk --backup=/tmp/sdb_gpt_backup.bin /dev/sdb
sudo sgdisk --backup=/tmp/sdc_gpt_backup.bin /dev/sdc
```

### Étape 5: Ne PAS remonter avant diagnostic complet

## Notes
- Ce n'est PAS un vrai rollback mais une procédure de protection
- Le vrai rollback serait restaurer depuis backup de données (si existe)
- Point stable = disques démontés + Samba arrêté
