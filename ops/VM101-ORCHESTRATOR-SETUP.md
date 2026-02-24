# VM101 Orchestrator Setup

## Prérequis
- VM101 Layer2 (192.168.1.136)
- Repo LinuxIA cloné sous `/opt/linuxia`
- Accès sudo NOPASSWD ou session root

## Installation (une seule commande)

### Option 1 : Avec sudo NOPASSWD configuré
```bash
ssh gaby@192.168.1.136
cd /opt/linuxia
bash scripts/vm101-bootstrap-orchestrator.sh
```

### Option 2 : En tant que root
```bash
ssh root@192.168.1.136
cd /opt/linuxia
bash scripts/vm101-bootstrap-orchestrator.sh
```

## Ce que fait le script

1. **Packages OS** : git, curl, jq, python3, pip, virtualenv
2. **Python venv** : `/opt/linuxia/.venv`
3. **Dépendances** : FastAPI, uvicorn, pydantic, orjson
4. **API code** : `services/orchestrator/api.py`
5. **Env file** : `ops/vm101/orchestrator.env`
6. **Systemd service** : `linuxia-orchestrator.service` (port 8111)
7. **CLI tool** : `tools/linuxia_statectl.sh`

## Vérification post-installation

Le script affiche une section **PREUVES** en fin d'exécution.

## Endpoints disponibles

- **Health** : `http://127.0.0.1:8111/healthz`
- **State GET** : `http://127.0.0.1:8111/api/state`
- **State PATCH** : `http://127.0.0.1:8111/api/state` (POST)

## Utilisation CLI

```bash
# Health check
/opt/linuxia/tools/linuxia_statectl.sh health

# Get state
/opt/linuxia/tools/linuxia_statectl.sh get

# Patch state
/opt/linuxia/tools/linuxia_statectl.sh patch vm101 'init' '{"vm101":{"ready":true}}'
```
