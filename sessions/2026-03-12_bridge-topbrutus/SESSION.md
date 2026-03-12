# SESSION.md — Bridge LinuxIA ↔ topbrutus.com
Date: 2026-03-12
Session ID: 2026-03-12_bridge-topbrutus

## But
Implémenter un pont bidirectionnel minimal entre le dépôt LinuxIA et topbrutus.com,
orienté orchestration d'agents (webhook GitHub, file d'événements, routeur agents).

## Périmètre
- Nouveau dossier `bridge/` (n'impacte pas le code existant)
- Pas de modifications aux scripts, services ou configurations existantes
- Backend Python minimal (Flask)

## Hypothèses
- Le dépôt n'a pas de backend existant (api/ vide)
- Python 3.10+ disponible sur la machine cible
- Le secret webhook sera configuré via variable d'environnement

## Décisions
- Choix Flask (minimal, lisible, testable)
- Stockage JSONL append-only (pas de base de données)
- Vérification signature HMAC désactivable (mode dev si secret absent)
- Router extensible pour OpenAI / Claude / Copilot

## Livrable
- bridge/server.py, bridge/webhook.py, bridge/router.py, bridge/events.py
- bridge/requirements.txt, bridge/README.md
- tests/test_bridge.py
