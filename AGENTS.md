# LinuxIA - Instructions pour agents (Codex)

## Contexte
- Repo LinuxIA (branche main)
- Chemin réel sur VM100: /opt/linuxia
- OS: openSUSE (pas de sudo en vrac; uniquement "sudo -i" quand nécessaire)
- IMPORTANT: aucun "echo" dans les scripts (ça a déjà causé des erreurs)

## Terminaux / machines
- Proxmox: ssh gaby@root@192.168.1.128
- VM100: ssh gaby@vm100 (Factory) -> /opt/linuxia
- VM101: ssh gaby@vm101
- VM102: ssh gaby@vm102
- VM103: ssh gaby@vm103 (ou 192.168.1.138)

## Disques / partages (VM100)
- /opt/linuxia/data/shareA et /opt/linuxia/data/shareB doivent être montés (bind mounts)
- Les archives configs vont dans: /opt/linuxia/data/shareA/archives/configsnap

## Règles de contribution
- Ne touche pas à data/, logs/, workspace/ (hors Git)
- Scripts shell: robustes, sans echo, et compatibles bash
- Toujours préciser "dans quel terminal" pour les commandes proposées
