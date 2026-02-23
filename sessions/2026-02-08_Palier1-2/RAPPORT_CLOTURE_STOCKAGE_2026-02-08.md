# Clôture — Checkpoint A (Storage + Samba + Windows)

Date: 2026-02-08  
VM: VM100 (vm100-factory, openSUSE)  
IP: 192.168.1.135

## Résumé
- Disques DATA_1TB_A et DATA_1TB_B montés (NTFS via FUSE) et exposés via Samba.
- Tests Windows (accès + écriture) validés sur les deux partages.

## Evidence
- PowerShell transcript: C:\Users\GABY\Desktop\linuxia_smb_test_2026-02-08.txt
- YAML résultat: sessions/2026-02-08_Palier1-2/test_windows_smb_2026-02-08.yaml

## Résultat (YAML)
```yaml
test_result:
  date: "2026-02-08"
  client_os: "Windows 10"
  share_a_access: "✅ OK"
  share_a_write: "✅ OK"
  share_b_access: "✅ OK"
  share_b_write: "✅ OK"
  proof: "PowerShell transcript: C:\\Users\\GABY\\Desktop\\linuxia_smb_test_2026-02-08.txt"
  issues:
    - "NET HELPMSG 2250 lors du delete initial: normal (aucune connexion existante)"
checkpoint: "A — Storage + Samba + Windows Access"
status: "CLOSED ✅"
date: "2026-02-08"
rollback_available: true
tag_git: "checkpoint-a-storage-validated"
next_action: "02-audit-disks.sh"

