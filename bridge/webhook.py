"""
webhook.py — Gestionnaire du webhook GitHub.

Endpoint : POST /api/github/webhook
- Vérifie la signature HMAC-SHA256 (header X-Hub-Signature-256)
- Extrait les champs repo, branch, type d'événement
- Enregistre l'événement dans la file JSONL
"""

import hashlib
import hmac
import json
import os
from typing import Any, Dict, Optional, Tuple

from events import append_event, build_event

# Secret configuré dans GitHub → Settings → Webhooks
# Laisser vide pour désactiver la vérification (dev only)
GITHUB_WEBHOOK_SECRET: Optional[str] = os.environ.get("GITHUB_WEBHOOK_SECRET", "")


def _verify_signature(body: bytes, signature_header: str) -> bool:
    """Vérifie la signature SHA-256 envoyée par GitHub."""
    if not GITHUB_WEBHOOK_SECRET:
        return True  # vérification désactivée (mode dev)
    if not signature_header.startswith("sha256="):
        return False
    expected = hmac.new(
        GITHUB_WEBHOOK_SECRET.encode("utf-8"), body, hashlib.sha256
    ).hexdigest()
    received = signature_header[len("sha256="):]
    return hmac.compare_digest(expected, received)


def _extract_summary(event_type: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """Extrait les champs essentiels du payload GitHub selon le type d'événement."""
    repo = data.get("repository", {}).get("full_name", "")
    branch = ""

    if event_type == "push":
        branch = data.get("ref", "").removeprefix("refs/heads/")
        return {
            "repo": repo,
            "branch": branch,
            "pusher": data.get("pusher", {}).get("name", ""),
            "commits": len(data.get("commits", [])),
            "head_commit": (data.get("head_commit") or {}).get("id", "")[:8],
        }

    if event_type in ("pull_request", "pull_request_review"):
        pr = data.get("pull_request", {})
        branch = pr.get("head", {}).get("ref", "")
        return {
            "repo": repo,
            "branch": branch,
            "action": data.get("action", ""),
            "pr_number": pr.get("number"),
            "title": pr.get("title", ""),
        }

    if event_type == "workflow_run":
        run = data.get("workflow_run", {})
        branch = run.get("head_branch", "")
        return {
            "repo": repo,
            "branch": branch,
            "workflow": run.get("name", ""),
            "conclusion": run.get("conclusion", ""),
            "status": run.get("status", ""),
        }

    # Événement générique
    return {"repo": repo, "branch": branch, "action": data.get("action", "")}


def handle_webhook(
    body: bytes,
    signature_header: str,
    event_type: str,
) -> Tuple[Dict[str, Any], int]:
    """
    Traite un webhook GitHub.

    Retourne (response_dict, http_status_code).
    """
    if not _verify_signature(body, signature_header):
        return {"error": "signature invalide"}, 401

    try:
        data: Dict[str, Any] = json.loads(body)
    except json.JSONDecodeError:
        return {"error": "payload JSON invalide"}, 400

    summary = _extract_summary(event_type, data)
    repo = summary.pop("repo", "")
    branch = summary.pop("branch", "")

    event = build_event(
        source="github",
        event_type=event_type,
        repo=repo,
        branch=branch,
        payload=summary,
        status="received",
    )
    append_event(event)

    return {"ok": True, "event_id": event["id"]}, 200
