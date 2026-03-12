"""
events.py — File d'événements locale (JSONL, append-only).

Chaque événement est une ligne JSON avec les champs obligatoires :
  id, source, type, repo, branch, timestamp, payload, status
"""

import json
import os
import threading
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

# Chemin par défaut du fichier JSONL (peut être surchargé via env)
_DEFAULT_EVENTS_FILE = Path(__file__).parent / "data" / "events.jsonl"
EVENTS_FILE = Path(os.environ.get("BRIDGE_EVENTS_FILE", str(_DEFAULT_EVENTS_FILE)))

# Verrou global pour les écritures concurrentes
_write_lock = threading.Lock()


def _ensure_data_dir() -> None:
    EVENTS_FILE.parent.mkdir(parents=True, exist_ok=True)


def build_event(
    source: str,
    event_type: str,
    repo: str = "",
    branch: str = "",
    payload: Optional[Dict[str, Any]] = None,
    status: str = "received",
) -> Dict[str, Any]:
    """Construit un événement normalisé."""
    return {
        "id": str(uuid.uuid4()),
        "source": source,
        "type": event_type,
        "repo": repo,
        "branch": branch,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "payload": payload or {},
        "status": status,
    }


def append_event(event: Dict[str, Any]) -> None:
    """Écrit un événement en fin du fichier JSONL (thread-safe)."""
    _ensure_data_dir()
    line = json.dumps(event, ensure_ascii=False) + "\n"
    with _write_lock:
        with EVENTS_FILE.open("a", encoding="utf-8") as fh:
            fh.write(line)


def read_events(limit: int = 50) -> List[Dict[str, Any]]:
    """Retourne les `limit` derniers événements (ordre chronologique inverse)."""
    _ensure_data_dir()
    if not EVENTS_FILE.exists():
        return []
    lines: List[str] = []
    with EVENTS_FILE.open("r", encoding="utf-8") as fh:
        lines = fh.readlines()
    parsed: List[Dict[str, Any]] = []
    for line in lines:
        line = line.strip()
        if line:
            try:
                parsed.append(json.loads(line))
            except json.JSONDecodeError:
                pass  # ligne corrompue, on passe
    return list(reversed(parsed[-limit:]))
