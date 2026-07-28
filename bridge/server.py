"""
server.py — Serveur HTTP bridge LinuxIA ↔ topbrutus.com

Endpoints exposés :
  POST /api/github/webhook    — réception des webhooks GitHub
  POST /api/agent/dispatch    — dispatch de messages vers un agent
  GET  /api/bridge/events     — lecture des derniers événements

Lancement :
  pip install -r requirements.txt
  python server.py

Variables d'environnement :
  BRIDGE_PORT              (défaut : 8080)
  GITHUB_WEBHOOK_SECRET    (laisser vide pour désactiver la vérification)
  BRIDGE_EVENTS_FILE       (chemin du fichier JSONL, défaut : data/events.jsonl)
"""

import json
import os
import sys

from flask import Flask, Response, jsonify, request

from events import read_events
from router import dispatch
from webhook import handle_webhook

app = Flask(__name__)

# ── GitHub Webhook ───────────────────────────────────────────────────────────


@app.route("/api/github/webhook", methods=["POST"])
def github_webhook() -> Response:
    """Reçoit et journalise les événements GitHub."""
    body: bytes = request.get_data()
    signature: str = request.headers.get("X-Hub-Signature-256", "")
    event_type: str = request.headers.get("X-GitHub-Event", "unknown")

    result, status = handle_webhook(body, signature, event_type)
    return jsonify(result), status


# ── Agent Dispatch ───────────────────────────────────────────────────────────


@app.route("/api/agent/dispatch", methods=["POST"])
def agent_dispatch() -> Response:
    """Enqueue un message normalisé vers un agent."""
    body = request.get_json(silent=True)
    if body is None:
        return jsonify({"error": "Corps JSON invalide ou absent"}), 400

    result, status = dispatch(body)
    return jsonify(result), status


# ── Bridge Events ────────────────────────────────────────────────────────────


@app.route("/api/bridge/events", methods=["GET"])
def bridge_events() -> Response:
    """Retourne les derniers événements de la queue."""
    try:
        limit = min(int(request.args.get("limit", 50)), 200)
    except ValueError:
        limit = 50

    events = read_events(limit=limit)
    return jsonify({"count": len(events), "events": events}), 200


# ── Health ───────────────────────────────────────────────────────────────────


@app.route("/api/bridge/health", methods=["GET"])
def health() -> Response:
    return jsonify({"status": "ok", "service": "linuxia-bridge"}), 200


# ── Entrypoint ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    port = int(os.environ.get("BRIDGE_PORT", 8080))
    debug = os.environ.get("BRIDGE_DEBUG", "0") == "1"
    print(f"[bridge] Démarrage sur le port {port} (debug={debug})", file=sys.stderr)
    app.run(host="0.0.0.0", port=port, debug=debug)
