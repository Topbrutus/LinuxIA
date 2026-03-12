"""
router.py — Routeur d'agents minimal.

Endpoint : POST /api/agent/dispatch
- Reçoit un message normalisé
- L'écrit dans la file d'événements
- Point d'extension futur pour OpenAI / Claude / Copilot / agent général

Format attendu en entrée :
{
  "agent":   "copilot" | "openai" | "claude" | "general",
  "action":  str,          # ex: "summarize", "plan", "critique"
  "repo":    str,          # optionnel
  "branch":  str,          # optionnel
  "payload": dict          # données libres
}
"""

from typing import Any, Dict, Tuple

from events import append_event, build_event

# Agents reconnus (liste extensible)
KNOWN_AGENTS = {"copilot", "openai", "claude", "general"}


def dispatch(body: Dict[str, Any]) -> Tuple[Dict[str, Any], int]:
    """
    Normalise et enqueue un message d'agent.

    Retourne (response_dict, http_status_code).
    """
    agent = body.get("agent", "general")
    action = body.get("action", "")
    repo = body.get("repo", "")
    branch = body.get("branch", "")
    payload = body.get("payload", {})

    if not action:
        return {"error": "Le champ 'action' est obligatoire"}, 400

    # Point d'extension : ici on pourrait router vers l'API de l'agent cible.
    # Pour l'instant on enregistre uniquement dans la queue.
    if agent not in KNOWN_AGENTS:
        agent = "general"

    event = build_event(
        source=f"agent:{agent}",
        event_type=action,
        repo=repo,
        branch=branch,
        payload=payload,
        status="queued",
    )
    append_event(event)

    return {
        "ok": True,
        "event_id": event["id"],
        "agent": agent,
        "note": (
            f"Événement mis en queue pour l'agent '{agent}'. "
            "Intégration API externe non encore activée."
        ),
    }, 202
