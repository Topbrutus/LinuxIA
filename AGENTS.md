# LinuxIA - règles projet

Priorités: stabilité, reproductibilité, traçabilité.

Règles non négociables:
- Aucun `echo` dans les scripts.
- Pas de `sudo` sauf `sudo -i` quand nécessaire.
- openSUSE (zypper, systemd).
- Toujours `git status -sb` avant/après.
- Changements minimaux, commits petits.
- Ne pas toucher `data/`, `logs/`, `workspace/`/`scratch/` sans demande explicite.
