# VM101 Probe Agent Setup

## Vue d'ensemble
Le probe agent collecte des métriques système toutes les 30s et les envoie à l'API orchestrateur.

## Prérequis
- **Orchestrateur** déjà installé (`linuxia-orchestrator.service` actif)
- Accès sudo NOPASSWD ou session root

## Installation

```bash
ssh gaby@192.168.1.136  # ou root@192.168.1.136
cd /opt/linuxia
git pull
bash scripts/vm101-bootstrap-probe.sh
```

## Ce que fait le script

1. **Packages** : curl, jq, util-linux
2. **Env file** : `ops/vm101/probe.env`
3. **Script probe** : `tools/vm101_probe.sh`
4. **Systemd timer** : `linuxia-vm101-probe.timer` (30s interval)
5. **Collecteur** : `tools/vm101_collect_proofs.sh`
6. **Run immédiat** : génère première preuve

## Métriques collectées

- **Orchestrateur** : status service, health endpoint
- **Système** : load average, mémoire disponible
- **Logs** : erreurs journal (5 min), failed units
- **Mounts** : status CIFS/autofs (DATA_1TB_A/B)

## Sorties

### Event log (JSONL)
`/opt/linuxia/logs/vm101_probe.jsonl`

Format :
```json
{
  "ts": "2026-02-17T00:15:30-05:00",
  "type": "VM101_PROBE",
  "host": "vm101-layer2",
  "patch": {
    "vm101": {
      "heartbeat": {
        "ts": "...",
        "orch_service": "active",
        "orch_health": "ok",
        "load": "0.12 0.15 0.18",
        "mem_avail_kb": 2048000,
        "journal_err_5m": 0,
        "failed_units": 0,
        "mounts": {...}
      }
    }
  }
}
```

### State API
Le probe POST vers `/api/state` → l'état global est maj.

Récupérer :
```bash
/opt/linuxia/tools/linuxia_statectl.sh get
```

## Vérification

```bash
# Timer actif ?
systemctl status linuxia-vm101-probe.timer

# Dernière exécution ?
systemctl status linuxia-vm101-probe.service

# Logs probe
journalctl -u linuxia-vm101-probe.service -n 50 --no-pager

# Event log
tail -f /opt/linuxia/logs/vm101_probe.jsonl
```

## Collecte de preuves

Génère un proofpack complet :

```bash
/opt/linuxia/tools/vm101_collect_proofs.sh
```

Crée : `docs/verifications/{hostname}_proofpack_{timestamp}.txt`

Contient :
- Status services (orchestrator, probe timer)
- Timers systemd (linuxia)
- Mounts (CIFS/autofs filtered)
- Derniers logs probe + orchestrator
- Tail du JSONL

## Troubleshooting

### Timer ne se lance pas
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now linuxia-vm101-probe.timer
sudo systemctl start linuxia-vm101-probe.timer
journalctl -u linuxia-vm101-probe.timer -n 20 --no-pager
```

### Probe fail (deps manquantes)
```bash
# Vérifier dépendances
command -v curl jq findmnt systemctl journalctl

# Installer manuellement
sudo zypper in -y curl jq util-linux
```

### API injoignable
```bash
# Vérifier orchestrator
systemctl status linuxia-orchestrator.service
curl http://127.0.0.1:8111/healthz
```

## Next steps

Après installation :
1. Vérifier timer actif : `systemctl list-timers | grep probe`
2. Générer proofpack : `tools/vm101_collect_proofs.sh`
3. Commiter proofpack dans repo (depuis VM100/VM101)
