# Docs LinuxIA

Ce dossier contient la documentation du projet.

Génération d'un état de la VM100:
- scripts/linuxia-healthcheck.sh (génère docs/STATE_HEALTHCHECK.md)
- scripts/linuxia-repair.sh (auto-réparation ciblée des partages Samba)
- services/systemd/linuxia-repair.service (unité systemd oneshot déclenché par linuxia-repair.path)

Auto-réparation (VM100):
- lancement manuel: sudo -i && systemctl start linuxia-repair.service
- logs: journalctl -u linuxia-repair.service -n 200 --no-pager
