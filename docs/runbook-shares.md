# Runbook — Partages LinuxIA (shareA/shareB)

## Vue d'ensemble
Les partages LinuxIA sont des **bind mounts** depuis les NTFS `/mnt/linuxia/DATA_1TB_A` et `DATA_1TB_B`.
- **shareA** : `/opt/linuxia/data/shareA` ← `/mnt/linuxia/DATA_1TB_A/LinuxIA_SMB`
- **shareB** : `/opt/linuxia/data/shareB` ← `/mnt/linuxia/DATA_1TB_B/LinuxIA_SMB`

Gérés par systemd (`.mount` + `.automount`).

## Diagnostic rapide

### shareA down ou inaccessible

**Symptômes** :
- `ls /opt/linuxia/data/shareA` → vide ou erreur
- Services échouent (health-report, configsnap)

**3 commandes de diagnostic** :
```bash
# 1. Vérifier statut systemd
systemctl status opt-linuxia-data-shareA.mount --no-pager -l

# 2. Vérifier source NTFS monté
findmnt /mnt/linuxia/DATA_1TB_A

# 3. Vérifier chemin source existe
ls -la /mnt/linuxia/DATA_1TB_A/LinuxIA_SMB
```

**3 commandes de réparation** :
```bash
# 1. Redémarrer automount
sudo systemctl restart opt-linuxia-data-shareA.automount

# 2. Si échec, forcer remontage manuel
sudo systemctl stop opt-linuxia-data-shareA.mount
sudo systemctl start opt-linuxia-data-shareA.mount

# 3. Vérifier résultat
ls -la /opt/linuxia/data/shareA
```

### Logs du montage
```bash
# Dernières 50 lignes mount shareA
journalctl -u opt-linuxia-data-shareA.mount -n 50 --no-pager

# Dernières 50 lignes automount
journalctl -u opt-linuxia-data-shareA.automount -n 50 --no-pager
```

## Problèmes courants

### 1. NTFS source non monté
**Erreur** : `Requires= failed: mnt-linuxia-DATA_1TB_A.mount`

**Solution** :
```bash
# Vérifier disque détecté
lsblk | grep sdb

# Forcer montage NTFS
sudo systemctl restart mnt-linuxia-DATA_1TB_A.mount

# Puis remonter shareA
sudo systemctl restart opt-linuxia-data-shareA.automount
```

### 2. Répertoire LinuxIA_SMB manquant
**Erreur** : `ConditionPathExists=/mnt/linuxia/DATA_1TB_A/LinuxIA_SMB not met`

**Solution** :
```bash
# Créer manuellement (une fois)
sudo mkdir -p /mnt/linuxia/DATA_1TB_A/LinuxIA_SMB
sudo chown gaby:users /mnt/linuxia/DATA_1TB_A/LinuxIA_SMB
sudo chmod 775 /mnt/linuxia/DATA_1TB_A/LinuxIA_SMB

# Relancer mount
sudo systemctl restart opt-linuxia-data-shareA.mount
```

### 3. Permissions cassées (read-only, ACL perdues)
**Symptôme** : Impossible d'écrire dans shareA

**Solution** :
```bash
# Ré-appliquer ACLs
sudo bash /opt/linuxia/scripts/apply-share-acls.sh

# Vérifier writable
touch /opt/linuxia/data/shareA/reports/test.txt && rm /opt/linuxia/data/shareA/reports/test.txt
```

### 4. Automount timeout
**Symptôme** : shareA se démonte après inactivité

**Comportement normal** : `TimeoutIdleSec=300` (5 min)

**Forcer montage permanent** :
```bash
# Désactiver automount, activer mount direct
sudo systemctl disable opt-linuxia-data-shareA.automount
sudo systemctl enable opt-linuxia-data-shareA.mount
sudo systemctl start opt-linuxia-data-shareA.mount
```

## Vérification post-reboot

Après reboot VM, valider :
```bash
# 1. Automounts actifs
systemctl status opt-linuxia-data-shareA.automount
systemctl status opt-linuxia-data-shareB.automount

# 2. Accès shareA
ls -la /opt/linuxia/data/shareA/reports/

# 3. Writable
touch /opt/linuxia/data/shareA/reports/reboot-test.txt && rm /opt/linuxia/data/shareA/reports/reboot-test.txt

# 4. Verify-platform OK
bash /opt/linuxia/scripts/verify-platform.sh | grep -E "OK=|WARN=|FAIL="
```

## Maintenance

### Désactiver shareA temporairement
```bash
sudo systemctl stop opt-linuxia-data-shareA.automount
sudo systemctl stop opt-linuxia-data-shareA.mount
```

### Réactiver
```bash
sudo systemctl start opt-linuxia-data-shareA.automount
```

### Forcer sync après modifications
```bash
# NTFS flush (si nécessaire)
sudo umount /opt/linuxia/data/shareA
sudo mount -o remount /mnt/linuxia/DATA_1TB_A
sudo systemctl restart opt-linuxia-data-shareA.mount
```

## Références
- Units : `/opt/linuxia/services/systemd/opt-linuxia-data-share*.{mount,automount}`
- Policy : `/opt/linuxia/docs/shares-policy.md`
- Vérif : `bash /opt/linuxia/scripts/verify-platform.sh`
