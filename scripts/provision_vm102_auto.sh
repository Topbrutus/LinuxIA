#!/usr/bin/env bash
# [BLOC COPILOT — VM102 | choix "bon par défaut" ✅ | AUTO-DÉCOUVERTE | proof-first 🧾]
# Objectif: créer VM102 (agent-runner / sandbox orchestrateur) SANS toucher VM100/VM101 (lecture OK).
# STOP ⚠️: si une commande propose d'effacer/formatter/écraser, si conflit git, ou mot de passe inattendu.

set -euo pipefail

###############################################################################
# 1) PROXMOX (sur le noeud PVE, root) — provision VM102
###############################################################################
TS="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="/root/vm102_provision_${TS}.log"
exec > >(tee -a "$LOG") 2>&1
echo "LOG=$LOG"

echo "==[PRE-FLIGHT]=="
pveversion -v | head -n 3 || true
qm list | head -n 30

# Choix "bon par défaut"
VMID_BASE=102
VMNAME="vm102-agent"
CORES="4"
RAM_MB="8192"

# Bridge: premier vmbr trouvé, sinon vmbr0
BRIDGE="$(ip -br link show | awk '$1 ~ /^vmbr/ {print $1; exit}')"
BRIDGE="${BRIDGE:-vmbr0}"

# Storage: préfère local-zfs/local-lvm si actifs et support images
STORAGE="$(
  pvesm status 2>/dev/null | awk 'NR>1 && $2=="active"{print $1}' | \
  grep -E 'local-zfs|local-lvm|zfs|nvme|ssd|fast' | head -n1
)"
if [[ -z "${STORAGE}" ]]; then
  STORAGE="$(pvesm status 2>/dev/null | awk 'NR>1 && $2=="active"{print $1; exit}')"
fi

echo "BRIDGE=${BRIDGE}"
echo "STORAGE=${STORAGE:-<AUCUN>}"

if [[ -z "${STORAGE}" ]]; then
  echo "STOP: aucun storage actif détecté via pvesm status."
  exit 1
fi

# TEMPLATE_ID: cherche un template qm (template: 1) dont le nom match opensuse/leap/factory/suse
echo "==[TEMPLATE AUTO-SELECT]=="
TEMPLATE_ID="$(
  for id in $(qm list | awk 'NR>1{print $1}'); do
    cfg="$(qm config "$id" 2>/dev/null || true)"
    echo "$cfg" | grep -q '^template: 1' || continue
    name="$(echo "$cfg" | awk -F': ' '/^name:/{print $2; exit}')"
    echo "${id} ${name}"
  done | grep -Ei 'opensuse|leap|factory|suse' | head -n1 | awk '{print $1}'
)"

if [[ -z "${TEMPLATE_ID}" ]]; then
  echo "Aucun template 'opensuse/leap/factory/suse' trouvé automatiquement."
  echo "Liste des templates disponibles:"
  for id in $(qm list | awk 'NR>1{print $1}'); do
    qm config "$id" 2>/dev/null | grep -q '^template: 1' || continue
    echo -n " - "
    qm config "$id" 2>/dev/null | awk -F': ' '/^name:/{printf("TEMPLATE_ID=%s NAME=%s\n", "'"$id"'", $2); exit}'
  done
  echo "STOP: fixe TEMPLATE_ID manuellement puis relance."
  exit 1
fi

echo "TEMPLATE_ID=${TEMPLATE_ID}"

# VMID libre: 102 sinon next
VMID="${VMID_BASE}"
while qm status "${VMID}" >/dev/null 2>&1; do VMID="$((VMID+1))"; done
echo "VMID choisi: ${VMID}"

echo "==[CLONE]=="
qm clone "${TEMPLATE_ID}" "${VMID}" --name "${VMNAME}" --full true --storage "${STORAGE}"

echo "==[SETTINGS]=="
qm set "${VMID}" --cores "${CORES}" --memory "${RAM_MB}" --balloon 0
qm set "${VMID}" --machine q35 --scsihw virtio-scsi-pci
qm set "${VMID}" --net0 virtio,bridge="${BRIDGE}"
qm set "${VMID}" --agent enabled=1,fstrim_cloned_disks=1
qm set "${VMID}" --rng0 source=/dev/urandom
qm set "${VMID}" --onboot 1 --startup order=50,up=30,down=30

echo "==[START]=="
qm start "${VMID}"
qm status "${VMID}"
qm config "${VMID}" | sed -n '1,160p'

echo "==[IP TRY]=="
# Si qemu-guest-agent est actif dans la VM, on voit l'IP ici. Sinon: console Proxmox -> ip a
sleep 30
qm guest cmd "${VMID}" network-get-interfaces 2>/dev/null | grep -oP '(?<="ip-address":")([0-9.]+)' | grep -v 127.0.0.1 || true

cat <<'TXT'

✅ VM102 CRÉÉE !

NEXT (obtenir IP):
  1. Via qemu-guest-agent (attendre 60s boot):
       qm guest cmd <VMID> network-get-interfaces | grep ip-address
  
  2. OU via console Proxmox:
       qm terminal <VMID>
       # Login → ip a

  3. Noter l'IP, puis exécuter le script bootstrap:
       bash /opt/linuxia/scripts/bootstrap_vm102_inside.sh

TXT

echo "==[LOG SAVED]=="
echo "Log complet: ${LOG}"
