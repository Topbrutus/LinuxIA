# VM102 Setup — Auto-Provision Guide

## Objectif
Créer VM102 (`vm102-agent`) comme **agent-runner / CI sandbox** pour LinuxIA, sans toucher VM100/VM101.

## Rôle VM102
- **Bac à sable** pour tests/lint/vérifications
- **Développement API orchestrateur** (`/api/state`, comms agents)
- **Runner CI-like** (scripts de vérif, smoke tests, ShellCheck)
- **Stateless** (pas de données critiques, reproductible)

## Pré-requis
- Proxmox accessible (SSH root@192.168.1.128 ou console web)
- Template openSUSE Leap disponible (ou autre distro compatible)
- VM100 et VM101 ne doivent PAS être modifiées

---

## PHASE 1: Proxmox — Création VM102 (AUTO)

**Terminal:** SSH Proxmox ou Proxmox Web Shell

### Étape 1: Copier le script
```bash
# Depuis VM100 (ou clone le repo sur Proxmox)
scp /opt/linuxia/scripts/provision_vm102_auto.sh root@192.168.1.128:/tmp/

# OU depuis Proxmox (si git disponible)
git clone https://github.com/Topbrutus/LinuxIA.git /tmp/linuxia
```

### Étape 2: Exécuter la provision (1 commande)
```bash
# Sur Proxmox
bash /tmp/provision_vm102_auto.sh
```

**Ce que fait le script:**
- ✅ Détecte automatiquement: storage, bridge, template openSUSE
- ✅ Clone template → VM 102 (ou 103 si 102 existe)
- ✅ Configure: 4 cores, 8GB RAM, q35, virtio, qemu-guest-agent
- ✅ Démarre la VM
- ✅ Tente d'obtenir l'IP (via qemu-guest-agent)
- ✅ Log complet: `/root/vm102_provision_<timestamp>.log`

**Output attendu:**
```
VMID choisi: 102
TEMPLATE_ID=9000
STORAGE=local-lvm
BRIDGE=vmbr0
...
✅ VM102 CRÉÉE !
```

### Étape 3: Obtenir l'IP
```bash
# Sur Proxmox, attendre 60s (boot complet)
sleep 60
qm guest cmd 102 network-get-interfaces | grep -oP '(?<="ip-address":")([0-9.]+)' | grep -v 127.0.0.1

# OU via console
qm terminal 102
# Login root/user → ip a
```

**Noter l'IP:** `__________________`

---

## PHASE 2: VM102 — Bootstrap Initial

**Terminal:** SSH VM102 (`ssh root@<VM102_IP>` ou console Proxmox)

### Option A: Script automatique (recommandé)
```bash
# Dans VM102
curl -fsSL https://raw.githubusercontent.com/Topbrutus/LinuxIA/main/scripts/bootstrap_vm102_inside.sh | bash

# OU si déjà cloné sur Proxmox
scp /tmp/linuxia/scripts/bootstrap_vm102_inside.sh root@<VM102_IP>:/tmp/
ssh root@<VM102_IP> "bash /tmp/bootstrap_vm102_inside.sh"
```

**Le script va:**
1. Configurer hostname `vm102-agent`
2. Installer packages (git, python3, shellcheck, ripgrep, jq, etc.)
3. Créer user `gaby` (si inexistant)
4. Générer clé SSH GitHub dédiée `id_ed25519_github_vm102`
5. **Afficher la clé publique à ajouter dans GitHub** (pause interactive)
6. Tester connexion GitHub
7. Cloner repo LinuxIA → `/opt/linuxia`
8. Créer + exécuter `scripts/verify_vm102_ready.sh` → évidence

### Option B: Manuel (étape par étape)
Voir le fichier `scripts/bootstrap_vm102_inside.sh` pour détails.

---

## PHASE 3: Vérification Preuve-First

**Terminal:** VM102 (user `gaby`)

```bash
ssh gaby@<VM102_IP>
cd /opt/linuxia
./scripts/verify_vm102_ready.sh
```

**Output attendu:**
```
=== VM102 READY CHECK ===
timestamp_utc=20260217T051500Z
[identity]
Static hostname: vm102-agent
...
[github ssh]
Hi Topbrutus! You've successfully authenticated...
✅ Evidence saved: docs/verifications/verify_vm102_ready_20260217T051500Z.txt
```

### Commit évidence
```bash
cd /opt/linuxia
git checkout -b vm102-bootstrap
git add docs/verifications/verify_vm102_ready_*.txt
git commit -m "vm102: add bootstrap verification evidence

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push -u origin vm102-bootstrap
```

---

## PHASE 4: Documentation — Checkpoint

**Ajouter dans `docs/PRODUCTION.md`:**

```markdown
## Checkpoint D — VM102 bootstrap
- Date: <TIMESTAMP>
- VM: vm102-agent (<IP>)
- Role: Agent-Runner / CI & Orchestrator Dev
- Evidence (repo): docs/verifications/verify_vm102_ready_<timestamp>.txt
- OS: openSUSE Leap 16.0
- Git: Cloned /opt/linuxia (branch main, SSH key vm102-agent)
- Tools: git, python3, shellcheck, ripgrep, jq, make, gcc, qemu-guest-agent
- Status: ✅ Ready for CI/dev workflows
```

---

## Optionnel: CIFS Read-Only (Test Uniquement)

**Si besoin d'accéder aux shares VM100:**

```bash
# Dans VM102
sudo zypper install -y cifs-utils
sudo mkdir -p /mnt/vm100_shareA

# Mount manuel (read-only, no fstab)
sudo mount -t cifs -o ro,guest //192.168.1.135/DATA_1TB_A /mnt/vm100_shareA

# Vérifier
ls /mnt/vm100_shareA/archives/configsnap

# Unmount après test
sudo umount /mnt/vm100_shareA
```

**Note:** Pas d'auto-mount dans `/etc/fstab` (VM102 stateless).

---

## Troubleshooting

### VM102 n'obtient pas d'IP
```bash
# Dans console VM102
sudo systemctl restart NetworkManager
sudo systemctl status NetworkManager
ip a
```

### qemu-guest-agent inactif
```bash
# Dans VM102
sudo systemctl enable --now qemu-guest-agent
sudo systemctl status qemu-guest-agent
```

### GitHub SSH échoue
```bash
# Dans VM102 (user gaby)
ssh -vvv -T git@github.com
# Vérifier que la clé publique est bien dans GitHub Settings
cat ~/.ssh/id_ed25519_github_vm102.pub
```

### Template openSUSE introuvable
```bash
# Sur Proxmox, lister manuellement
qm list | grep -i template
# Fixer TEMPLATE_ID dans le script provision_vm102_auto.sh
```

---

## Checklist Finale

- [ ] VM102 créée dans Proxmox (4 cores, 8GB RAM, q35, virtio)
- [ ] IP obtenue: `________________`
- [ ] Hostname: `vm102-agent`
- [ ] Packages installés (git, python3, shellcheck, ripgrep, jq, etc.)
- [ ] Clé SSH GitHub `vm102-agent` ajoutée dans GitHub Settings
- [ ] Repo cloné: `/opt/linuxia`, branch `main`, remote GitHub SSH OK
- [ ] Script `verify_vm102_ready.sh` exécuté → évidence générée
- [ ] Évidence commitée dans branche `vm102-bootstrap`
- [ ] Checkpoint D ajouté dans `docs/PRODUCTION.md`

**VM102 est prête pour CI/dev !** 🚀
