# Quick Reference — Diagnostic Samba Disk

## 🚨 URGENT: À faire MAINTENANT

```bash
cd /opt/linuxia
sudo bash scripts/04-diagnostic-samba-disk-issue.sh
```

📄 Le résultat sera dans: `docs/verifications/diagnostic_samba_disk_<timestamp>.txt`

## 🔍 Si vous voulez voir rapidement l'état actuel

```bash
# État des disques
lsblk /dev/sdb /dev/sdc

# Partitions montées?
findmnt | grep -E '(sdb|sdc)'

# Samba fonctionne?
systemctl status smb nmb

# Erreurs récentes?
sudo dmesg -T | grep -i 'sd[bc]' | tail -20
```

## ⚠️ AVANT TOUTE RÉPARATION

1. **STOP** Samba: `sudo systemctl stop smb nmb`
2. **BACKUP** tables de partition:
   ```bash
   sudo sfdisk -d /dev/sdb > /tmp/sdb_backup.txt
   sudo sfdisk -d /dev/sdc > /tmp/sdc_backup.txt
   ```
3. **DÉMONTER** partitions:
   ```bash
   sudo umount /srv/linuxia-share/DATA_1TB_A
   sudo umount /srv/linuxia-share/DATA_1TB_B
   sudo umount /opt/linuxia/data/shareA
   sudo umount /opt/linuxia/data/shareB
   ```

## 📊 Info que j'ai besoin

1. Sortie du script de diagnostic (ci-dessus)
2. Quelle opération avez-vous faite? (quelle partition? quel outil?)
3. Quel est le symptôme exact? (erreur? ne monte pas? Samba ne démarre pas?)

## 🔗 Voir aussi

- Guide complet: `sessions/20260312_samba-disk-diagnostic/GUIDE_DIAGNOSTIC.md`
- Risques: `sessions/20260312_samba-disk-diagnostic/RISKS.md`
- Rollback: `sessions/20260312_samba-disk-diagnostic/ROLLBACK.md`
