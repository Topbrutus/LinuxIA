# Docs LinuxIA

Ce dossier contient la documentation du projet.

Génération d'un état de la VM100:
- scripts/linuxia-preflight.sh
- scripts/linuxia-state-report.sh
- scripts/linuxia-configsnap-index.sh
- scripts/linuxia-healthcheck.sh (génère docs/STATE_HEALTHCHECK.md)
- scripts/linuxia-repair.sh (auto-réparation minimale en cas d'échec healthcheck)

Les fichiers générés (STATE_VM100.md, CONFIGSNAP_LATEST.txt, etc.) sont ignorés par git.

Auto-réparation (VM100):
- lancement manuel: sudo -i && systemctl start linuxia-repair.service
- logs: journalctl -u linuxia-repair.service -n 200 --no-pager
