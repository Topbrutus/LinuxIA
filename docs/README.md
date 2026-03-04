# Docs LinuxIA

Ce dossier contient la documentation du projet.

Génération d'un état de la VM100:
- scripts/linuxia-healthcheck.sh
- scripts/linuxia-repair.sh
- services/systemd/linuxia-repair.service

Auto-réparation (VM100):
- lancement manuel: sudo -i && systemctl start linuxia-repair.service
- logs: journalctl -u linuxia-repair.service -n 200 --no-pager
