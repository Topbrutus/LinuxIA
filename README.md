# LinuxIA

Projet LinuxIA (VM100 Factory).

## Structure du dépôt
- docs/      : documentation
- configs/   : configurations (samba, ssh, systemd, etc.)
- scripts/   : scripts utilitaires
- bin/       : petits outils/CLI maison
- agents/    : agents, prompts, orchestrations
- services/  : services (systemd / containers / superviseurs)
- data/      : données locales / partages montés (ignoré par Git)
- logs/      : logs (ignoré par Git)
- workspace/ : zone temporaire (ignoré par Git)

## Partages (montages)
- /opt/linuxia/data/shareA  -> /srv/linuxia-share/DATA_1TB_A/LinuxIA_SMB
- /opt/linuxia/data/shareB  -> /srv/linuxia-share/DATA_1TB_B/LinuxIA_SMB
