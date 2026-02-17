# Politique de permissions LinuxIA (shareA/shareB)

## Objectif
Garantir des permissions **prédictibles et sûres** sur les partages LinuxIA, évitant :
- Fichiers `.txt`/`.log` exécutables par accident
- Permissions incohérentes après création
- Conflits entre utilisateurs/services

## Règles

### Groupe propriétaire
- **Groupe** : `users` (fallback) ou `linuxia` (si créé)
- User `gaby` membre du groupe

### Umask système
```bash
# /etc/profile.d/linuxia-umask.sh
umask 0002  # Nouveaux fichiers: 664 (rw-rw-r--), dirs: 775 (rwxrwxr-x)
```

### ACL par défaut
Appliquées via `scripts/apply-share-acls.sh` sur :
- `/opt/linuxia/data/shareA/reports/`
- `/opt/linuxia/data/shareA/archives/`

```bash
setfacl -d -m g:users:rwX /opt/linuxia/data/shareA/reports/
setfacl -d -m o::r-X /opt/linuxia/data/shareA/reports/
```

**Effet** :
- Nouveaux fichiers : `rw-rw-r--` (664)
- Nouveaux dossiers : `rwxrwxr-x` (775)
- Groupe a toujours accès lecture/écriture
- Autres : lecture seule

### Options de montage
**shareA et shareB** (bind mounts systemd) :
```ini
Options=bind,X-mount.mkdir
```

**Note** : `noexec` **non utilisé** pour éviter de casser les scripts légitimes dans shareA. La sécurité repose sur les ACL et le contexte SELinux.

## Exceptions

### .git/ (repo LinuxIA)
**Pas d'ACL sur `.git/`** pour éviter les conflits avec Git.
- `.git/objects/` doit rester writable par gaby
- Permissions gérées par Git nativement

### Scripts exécutables
Scripts `.sh` peuvent rester exécutables **si nécessaire** (ex: outils de maintenance dans shareA).
Fichiers de données (`.txt`, `.log`, `.json`) ne doivent **jamais** être +x.

## Vérification

### Commande manuelle
```bash
# Vérifier ACL
getfacl /opt/linuxia/data/shareA/reports/

# Vérifier permissions après création
touch /opt/linuxia/data/shareA/reports/test.txt
ls -l /opt/linuxia/data/shareA/reports/test.txt
# Attendu: -rw-rw-r-- gaby users
```

### Intégré dans verify-platform.sh
Vérifie automatiquement :
- shareA monté
- Writable (touch test)
- Owner/group corrects
- Options mount

## Application

### Installation initiale
```bash
sudo bash scripts/apply-share-acls.sh
```

### Après modification shareA
Ré-exécuter si les ACL semblent perdues :
```bash
sudo bash scripts/apply-share-acls.sh
```

## Références
- `services/systemd/opt-linuxia-data-shareA.mount`
- `scripts/apply-share-acls.sh`
- `scripts/verify-platform.sh` (section share checks)
