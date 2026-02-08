#!/usr/bin/env bash
set -euo pipefail

OUT="/opt/linuxia/docs/STATE_VM100.md"

{
  printf "# STATE VM100 (Factory)\n\n"
  printf -- "- Generated: %s\n" "$(date -Is)"
  printf -- "- Hostname: %s\n" "$(hostname)"
  printf -- "- Kernel: %s\n\n" "$(uname -r)"

  printf "## Repo\n\n"
  cd /opt/linuxia
  printf "### Remote\n\n"
  git remote -v || true
  printf "\n### Branch / Status\n\n"
  git status -sb || true
  printf "\n### Last commits\n\n"
  git --no-pager log --oneline -n 8 || true
  printf "\n"

  printf "## Snapshots configs (systemd)\n\n"
  systemctl list-timers --all | sed -n '1,5p' || true
  printf "\n"
  systemctl list-timers --all | grep -E 'linuxia-configsnap' || true
  printf "\n\n"
  systemctl status --no-pager linuxia-configsnap.timer || true
  printf "\n"
  systemctl status --no-pager linuxia-configsnap.service || true
  printf "\n"

  printf "## Disques / Bind mounts\n\n"
  printf "### findmnt (shareA/shareB)\n\n"
  findmnt -T /opt/linuxia/data/shareA || true
  findmnt -T /opt/linuxia/data/shareB || true
  printf "\n### findmnt (sous-jacent /srv)\n\n"
  findmnt -T /srv/linuxia-share/DATA_1TB_A || true
  findmnt -T /srv/linuxia-share/DATA_1TB_B || true
  printf "\n"

  printf "## SELinux + Samba (si applicable)\n\n"
  command -v getenforce >/dev/null 2>&1 && getenforce || true
  command -v getsebool >/dev/null 2>&1 && getsebool samba_share_fusefs samba_export_all_rw || true
  printf "\n"
  command -v testparm >/dev/null 2>&1 && testparm -s 2>/dev/null | egrep -n '^\[DATA_1TB_A\]|^\[DATA_1TB_B\]|path = ' || true
  printf "\n"
} > "$OUT"
