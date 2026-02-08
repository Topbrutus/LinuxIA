# LinuxIA - Instructions pour agents (Codex)

## Contexte
- Repo LinuxIA (branche main)
- Chemin réel sur VM100: /opt/linuxia
- OS: openSUSE (pas de sudo en vrac; uniquement "sudo -i" quand nécessaire)
- IMPORTANT: aucun "echo" dans les scripts

## SSH (IPs réelles, pas de raccourcis)
- Proxmox (PVE): ssh root@192.168.1.128
- VM100 (Factory): ssh gaby@192.168.1.135
- VM101 (Layer2): ssh gaby@192.168.1.136
- VM102 (Tool): ssh gaby@192.168.1.137
- VM103: ssh gaby@192.168.1.138

## Disques / partages (VM100)
- /opt/linuxia/data/shareA et /opt/linuxia/data/shareB doivent être montés (bind mounts)
- Archives configs: /opt/linuxia/data/shareA/archives/configsnap

## Règles de contribution
- Ne touche pas à data/, logs/, workspace/ (hors Git)
- Scripts shell: robustes, compatibles bash, sans echo
- Toujours préciser "dans quel terminal" pour les commandes proposées
