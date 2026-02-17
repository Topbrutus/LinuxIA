#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/linuxia"
TS="$(date +%Y%m%dT%H%M%S%z)"
HOST="$(hostname -s || hostname)"
OUT_DIR="${REPO}/docs/verifications"
OUT="${OUT_DIR}/${HOST}_preflight_${TS}.txt"

echo "== LinuxIA VM101 PRE-FLIGHT ==" | tee /dev/stderr
echo "Host: ${HOST}" | tee /dev/stderr
echo "Time: ${TS}" | tee /dev/stderr
echo

# 0) Garde-fou sudo (non-interactif)
SUDO_OK="no"
if command -v sudo >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then SUDO_OK="yes"; fi
fi

# 1) Repo attendu
if [ ! -d "${REPO}/.git" ]; then
  echo "ERROR: repo introuvable: ${REPO}/.git" | tee /dev/stderr
  echo "➡️ Assure-toi que /opt/linuxia est bien cloné sur VM101." | tee /dev/stderr
  exit 2
fi

mkdir -p "${OUT_DIR}"

{
  echo "=== HEADER ==="
  echo "host=${HOST}"
  echo "ts=${TS}"
  echo "repo=${REPO}"
  echo "sudo_non_interactive=${SUDO_OK}"
  echo

  echo "=== OS / KERNEL ==="
  uname -a || true
  [ -f /etc/os-release ] && cat /etc/os-release || true
  echo

  echo "=== NETWORK (brief) ==="
  ip -br a || true
  ip route || true
  echo

  echo "=== GIT (state + sync) ==="
  cd "${REPO}"
  git rev-parse --is-inside-work-tree
  git remote -v || true
  git branch --show-current || true
  git status -sb || true
  echo "--- fetch ---"
  git fetch origin || true
  echo "--- pull (ff-only) ---"
  git pull --ff-only || true
  echo "--- status after pull ---"
  git status -sb || true
  echo

  echo "=== CIFS / AUTOFS / MOUNTS (VM101) ==="
  command -v mount.cifs >/dev/null 2>&1 && mount.cifs -V || true
  (rpm -q cifs-utils 2>/dev/null || true)
  echo
  echo "--- findmnt (filtered) ---"
  findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS | egrep -i 'cifs|autofs|linuxia|smb' || true
  echo
  echo "--- expected paths (if present) ---"
  for p in /srv/linuxia-remote/DATA_1TB_A /srv/linuxia-remote/DATA_1TB_B /mnt/linuxia/DATA_1TB_A /mnt/linuxia/DATA_1TB_B; do
    if [ -e "$p" ]; then
      echo "# $p"
      ls -la "$p" 2>/dev/null | head -n 30 || true
      echo
    fi
  done
  echo

  echo "=== SYSTEMD (brief) ==="
  systemctl --no-pager --failed || true
  echo
} | tee "${OUT}"

echo
echo "✅ Preflight terminé. Preuve écrite dans:"
echo "   ${OUT}"
