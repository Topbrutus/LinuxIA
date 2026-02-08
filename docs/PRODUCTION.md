# LinuxIA — Journal de production (temps réel)

## Point stable (dernier état confirmé)
- Date:
- Proxmox:
- VM100:
- VM101:
- VM102:
- Stockage (disques / mounts):
- Partages (SMB/NFS/Virtio-FS):
- Orchestration (services/timers/logs):

## Objectif en cours (1 seul)
- Objectif:
- Risque principal:
- Critère “c’est réussi si”:

## Étapes (checklist courte)
- [ ] Étape 1:
- [ ] Étape 2:
- [ ] Étape 3:

## Commandes exécutées (copier/coller)
- Machine:
- Bloc:

## Vérifications (preuves)
- Commande:
- Résultat attendu:

## Décisions (non négociables / conventions)
- Règle:
- Raison:


## Checkpoint B — Storage audited
- Date: 2026-02-08T17:35:05-05:00
- Evidence (repo): docs/verifications/verify_disks_20260208T223316Z.txt
- Evidence (external): /run/media/gaby/LINUXUDF/linuxia_audit_trail/vm100/verifications/verify_disks_20260208T223316Z.txt
- DATA_1TB_A: /dev/sdb6 -> /opt/linuxia/data/shareA + /srv/linuxia-share/DATA_1TB_A + /mnt/linuxia/DATA_1TB_A
- DATA_1TB_B: /dev/sdc3 -> /opt/linuxia/data/shareB + /srv/linuxia-share/DATA_1TB_B + /mnt/linuxia/DATA_1TB_B
- External media: /dev/sdd1 -> /run/media/gaby/LINUXUDF

## Checkpoint C — Samba audited
- Date: 2026-02-08T17:36:36-05:00
- Evidence (repo): docs/verifications/verify_samba_20260208T223635Z.txt
- Evidence (external): /run/media/gaby/LINUXUDF/linuxia_audit_trail/vm100/verifications/verify_samba_20260208T223635Z.txt

## SMB access proof (Windows + VM101)
- Date: 2026-02-08T17:44:03-05:00
- Evidence (repo): docs/verifications/verify_smb_access_20260208T224403Z.txt
- Evidence (external): /run/media/gaby/LINUXUDF/linuxia_audit_trail/vm100/verifications/verify_smb_access_20260208T224403Z.txt

## SMB access proof (FULL: Windows A+B + VM101 A+B)
- Date: 2026-02-08T17:45:18-05:00
- Evidence (repo): docs/verifications/verify_smb_access_full_20260208T224518Z.txt
- Evidence (external): /run/media/gaby/LINUXUDF/linuxia_audit_trail/vm100/verifications/verify_smb_access_full_20260208T224518Z.txt

## Checkpoint D — VM101-layer2 CIFS mount audited
- Date: 2026-02-08T18:30:44-05:00
- Evidence (repo): docs/verifications/verify_vm101_layer2_cifs_20260208T233044Z.txt
- Evidence (external): /run/media/gaby/LINUXUDF/linuxia_audit_trail/vm100/verifications/verify_vm101_layer2_cifs_20260208T233044Z.txt
