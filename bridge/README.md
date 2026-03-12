# Bridge LinuxIA ↔ topbrutus.com

Pont bidirectionnel minimal entre le dépôt **LinuxIA** et le site **topbrutus.com**, orienté orchestration d'agents.

---

## Architecture

```
GitHub ──► POST /api/github/webhook
                │
                ▼
         [ webhook.py ]  ← vérification HMAC-SHA256
                │
                ▼
         [ events.py ]   ← queue JSONL append-only
                │         (bridge/data/events.jsonl)
                ▼
topbrutus.com ◄── GET /api/bridge/events

Agent externe ──► POST /api/agent/dispatch
                │
                ▼
         [ router.py ]   ← normalisation + enqueue
                │
                ▼
         [ events.py ]   (même file)
```

---

## Endpoints

| Méthode | Chemin                   | Description                                   |
|---------|--------------------------|-----------------------------------------------|
| POST    | `/api/github/webhook`    | Reçoit les webhooks GitHub                    |
| POST    | `/api/agent/dispatch`    | Enqueue un message vers un agent              |
| GET     | `/api/bridge/events`     | Lit les derniers événements (param: `?limit=`) |
| GET     | `/api/bridge/health`     | Health check                                  |

---

## Format d'un événement (JSONL)

```json
{
  "id":        "uuid-v4",
  "source":    "github | agent:copilot | agent:openai | ...",
  "type":      "push | pull_request | summarize | ...",
  "repo":      "Topbrutus/LinuxIA",
  "branch":    "main",
  "timestamp": "2026-03-12T09:40:50+00:00",
  "payload":   { "...": "champs résumés selon le type" },
  "status":    "received | queued"
}
```

---

## Installation et lancement local

```bash
cd bridge
pip install -r requirements.txt
python server.py
```

Variables d'environnement optionnelles :

| Variable               | Défaut                   | Description                          |
|------------------------|--------------------------|--------------------------------------|
| `BRIDGE_PORT`          | `8080`                   | Port d'écoute                        |
| `GITHUB_WEBHOOK_SECRET`| *(vide)*                 | Secret HMAC (désactive si vide)      |
| `BRIDGE_EVENTS_FILE`   | `bridge/data/events.jsonl` | Chemin du fichier queue             |
| `BRIDGE_DEBUG`         | `0`                      | Mode debug Flask (`1` pour activer)  |

---

## Test rapide (curl)

```bash
# Health check
curl http://localhost:8080/api/bridge/health

# Simuler un push GitHub (sans vérification de signature)
curl -X POST http://localhost:8080/api/github/webhook \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{"repository":{"full_name":"Topbrutus/LinuxIA"},"ref":"refs/heads/main","pusher":{"name":"topbrutus"},"commits":[]}'

# Dispatcher un message agent
curl -X POST http://localhost:8080/api/agent/dispatch \
  -H "Content-Type: application/json" \
  -d '{"agent":"copilot","action":"summarize","repo":"Topbrutus/LinuxIA","branch":"main","payload":{"context":"test"}}'

# Lire les événements
curl "http://localhost:8080/api/bridge/events?limit=10"
```

---

## Brancher topbrutus.com

1. **Déployer le bridge** sur un serveur accessible (VM100 ou VPS dédié).
2. **Configurer le webhook GitHub** :
   - Dépôt → *Settings* → *Webhooks* → *Add webhook*
   - URL : `https://topbrutus.com/api/github/webhook` (ou votre proxy)
   - Content type : `application/json`
   - Secret : valeur de `GITHUB_WEBHOOK_SECRET`
   - Événements : *push*, *pull_request*, *workflow_run* (au minimum)
3. **Appeler `/api/bridge/events`** depuis le frontend topbrutus.com pour afficher les derniers événements du dépôt.

---

## Prochaine étape — brancher un agent externe

Le fichier `router.py` contient un point d'extension commenté.
Pour activer un agent réel :

```python
# Dans router.py, section "Point d'extension"
if agent == "openai":
    # appel API OpenAI ici
    ...
elif agent == "claude":
    # appel API Anthropic ici
    ...
```

Chaque intégration devient une **macro versionnée** dans `macros/` (cf. `macros/00_contracts.md`).

---

## Fichiers

```
bridge/
├── server.py          ← serveur Flask (entrypoint)
├── webhook.py         ← handler webhook GitHub
├── router.py          ← routeur d'agents
├── events.py          ← file d'événements JSONL
├── requirements.txt   ← dépendances Python
├── README.md          ← ce fichier
└── data/
    └── events.jsonl   ← queue locale (créée automatiquement)
```
