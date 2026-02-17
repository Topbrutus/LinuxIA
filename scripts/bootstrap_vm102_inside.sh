#!/usr/bin/env bash
# [VM102 BOOTSTRAP — à exécuter DANS la VM102]
# Si tu peux SSH:
#   ssh <USER>@<VM102_IP>
# Sinon via console Proxmox.

set -euo pipefail

NEW_HOST="vm102-agent"
USERNAME="gaby"

# Repo par défaut (corrige si ton origin est différent)
REPO_SSH_DEFAULT="git@github.com:Topbrutus/LinuxIA.git"
REPO_SSH="${REPO_SSH:-${REPO_SSH_DEFAULT}}"

echo "==[HOSTNAME]=="
sudo hostnamectl set-hostname "${NEW_HOST}" || true
hostnamectl || true
cat /etc/os-release || true

echo "==[SERVICES]=="
sudo systemctl enable --now sshd || true
sudo systemctl enable --now qemu-guest-agent || true
sudo systemctl status sshd --no-pager -n 20 || true
sudo systemctl status qemu-guest-agent --no-pager -n 20 || true

echo "==[PACKAGES]=="
sudo zypper ref
sudo zypper in -y git openssh curl jq python3 python3-pip python3-virtualenv \
  make gcc gcc-c++ ripgrep tmux ShellCheck ca-certificates qemu-guest-agent

echo "==[USER]=="
id "${USERNAME}" 2>/dev/null || sudo useradd -m -s /bin/bash "${USERNAME}"
sudo usermod -aG wheel "${USERNAME}" || true
sudo mkdir -p /home/${USERNAME}/.ssh
sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
sudo chmod 700 /home/${USERNAME}/.ssh

echo "==[GITHUB SSH KEY DEDIEE]=="
sudo -iu ${USERNAME} bash -lc '
  set -euo pipefail
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  if [[ ! -f ~/.ssh/id_ed25519_github_vm102 ]]; then
    ssh-keygen -t ed25519 -a 64 -f ~/.ssh/id_ed25519_github_vm102 -C "github-vm102-'"${USERNAME}"'" -N ""
  fi
  cat > ~/.ssh/config <<'"'"'EOF'"'"'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_vm102
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
EOF
  chmod 600 ~/.ssh/config
  echo "=========================================="
  echo "📋 COPIE CETTE CLÉ PUB DANS GitHub → Settings → SSH and GPG keys"
  echo "https://github.com/settings/keys"
  echo "Title: vm102-agent (LinuxIA dev)"
  echo "=========================================="
  cat ~/.ssh/id_ed25519_github_vm102.pub
  echo "=========================================="
'

read -p "Appuie sur ENTRÉE après avoir ajouté la clé dans GitHub..."

echo "==[TEST GITHUB SSH]=="
sudo -iu ${USERNAME} bash -lc 'ssh -T git@github.com 2>&1' || true

echo "==[CLONE REPO]=="
sudo mkdir -p /opt/linuxia
sudo chown -R ${USERNAME}:${USERNAME} /opt/linuxia
sudo -iu ${USERNAME} bash -lc '
  set -euo pipefail
  if [[ ! -d /opt/linuxia/.git ]]; then
    cd /opt
    git clone "'"${REPO_SSH}"'" linuxia
  fi
  cd /opt/linuxia
  git status
  git remote -v
  git branch --show-current || true
'

echo "==[PROOF-FIRST: script de vérif + evidence]=="
sudo -iu ${USERNAME} bash -lc '
  set -euo pipefail
  cd /opt/linuxia
  mkdir -p scripts docs/verifications
  cat > scripts/verify_vm102_ready.sh <<'"'"'EOFSCRIPT'"'"'
#!/usr/bin/env bash
set -euo pipefail
ts="$(date -u +%Y%m%dT%H%M%SZ)"
out="docs/verifications/verify_vm102_ready_${ts}.txt"
mkdir -p docs/verifications
{
  echo "=== VM102 READY CHECK ==="
  echo "timestamp_utc=${ts}"
  echo
  echo "[identity]"; hostnamectl || true
  echo
  echo "[os]"; cat /etc/os-release || true; uname -a || true
  echo
  echo "[network]"; ip a || true; ip r || true; resolvectl status 2>/dev/null || cat /etc/resolv.conf || true
  echo
  echo "[disk/mem]"; df -hT || true; free -h || true
  echo
  echo "[systemd]"; systemctl --no-pager --failed || true
  echo
  echo "[git]"; git rev-parse --show-toplevel || true; git status || true; git remote -v || true
  echo
  echo "[github ssh]"; ssh -T git@github.com 2>&1 || true
  echo
  echo "=== END ==="
} | tee "${out}"
echo "✅ Evidence saved: ${out}"
EOFSCRIPT
  chmod +x scripts/verify_vm102_ready.sh
  ./scripts/verify_vm102_ready.sh
'

echo ""
echo "✅ BOOTSTRAP VM102 TERMINÉ !"
echo ""
echo "Prochaines étapes:"
echo "  1. Vérifier l'évidence: cat /opt/linuxia/docs/verifications/verify_vm102_ready_*.txt"
echo "  2. Commit + push (optionnel): cd /opt/linuxia && git add -A && git commit -m 'vm102: bootstrap evidence' && git push"
echo "  3. Utiliser VM102 comme agent-runner / CI sandbox"
