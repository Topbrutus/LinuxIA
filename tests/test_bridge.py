"""
tests/test_bridge.py — Tests unitaires du bridge LinuxIA ↔ topbrutus.com

Lancement :
  pip install -r bridge/requirements.txt pytest
  pytest tests/test_bridge.py -v
"""

import hashlib
import hmac
import json
import os
import sys
import tempfile
import uuid
from pathlib import Path

import pytest

# Ajouter bridge/ au path Python pour les imports
sys.path.insert(0, str(Path(__file__).parent.parent / "bridge"))

import events as ev
import router as rt
import webhook as wh


# ── Fixtures ─────────────────────────────────────────────────────────────────


@pytest.fixture(autouse=True)
def tmp_events_file(tmp_path, monkeypatch):
    """Redirige les écrits vers un fichier temporaire pour chaque test."""
    tmp_file = tmp_path / "events.jsonl"
    monkeypatch.setattr(ev, "EVENTS_FILE", tmp_file)
    yield tmp_file


# ── events.py ────────────────────────────────────────────────────────────────


class TestBuildEvent:
    def test_required_fields(self):
        e = ev.build_event(source="test", event_type="push")
        assert "id" in e
        assert "timestamp" in e
        assert e["source"] == "test"
        assert e["type"] == "push"
        assert e["status"] == "received"

    def test_uuid_format(self):
        e = ev.build_event(source="x", event_type="y")
        parsed = uuid.UUID(e["id"])  # ne lève pas si UUID valide
        assert str(parsed) == e["id"]

    def test_defaults(self):
        e = ev.build_event(source="s", event_type="t")
        assert e["repo"] == ""
        assert e["branch"] == ""
        assert e["payload"] == {}


class TestAppendAndRead:
    def test_roundtrip(self):
        e = ev.build_event(source="github", event_type="push", repo="org/repo")
        ev.append_event(e)
        results = ev.read_events()
        assert len(results) == 1
        assert results[0]["id"] == e["id"]

    def test_multiple_events_order(self):
        for i in range(5):
            ev.append_event(ev.build_event(source="s", event_type=str(i)))
        results = ev.read_events(limit=5)
        # Les événements sont retournés en ordre chronologique inverse
        assert results[0]["type"] == "4"
        assert results[-1]["type"] == "0"

    def test_limit(self):
        for _ in range(10):
            ev.append_event(ev.build_event(source="s", event_type="e"))
        assert len(ev.read_events(limit=3)) == 3

    def test_empty_file_returns_empty_list(self):
        assert ev.read_events() == []


# ── webhook.py ───────────────────────────────────────────────────────────────


class TestWebhookSignature:
    def test_no_secret_accepts_any(self, monkeypatch):
        monkeypatch.setattr(wh, "GITHUB_WEBHOOK_SECRET", "")
        body = b'{"repository":{"full_name":"org/repo"},"ref":"refs/heads/main","commits":[]}'
        result, status = wh.handle_webhook(body, "", "push")
        assert status == 200
        assert result["ok"] is True

    def test_valid_signature(self, monkeypatch):
        secret = "mysecret"
        monkeypatch.setattr(wh, "GITHUB_WEBHOOK_SECRET", secret)
        body = b'{"repository":{"full_name":"org/repo"},"ref":"refs/heads/main","commits":[]}'
        sig = "sha256=" + hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()
        result, status = wh.handle_webhook(body, sig, "push")
        assert status == 200

    def test_invalid_signature(self, monkeypatch):
        monkeypatch.setattr(wh, "GITHUB_WEBHOOK_SECRET", "mysecret")
        body = b'{"repository":{"full_name":"org/repo"}}'
        result, status = wh.handle_webhook(body, "sha256=badhash", "push")
        assert status == 401

    def test_invalid_json(self, monkeypatch):
        monkeypatch.setattr(wh, "GITHUB_WEBHOOK_SECRET", "")
        result, status = wh.handle_webhook(b"not-json", "", "push")
        assert status == 400


class TestWebhookExtractSummary:
    def _push_body(self):
        return json.dumps({
            "repository": {"full_name": "org/repo"},
            "ref": "refs/heads/feature",
            "pusher": {"name": "alice"},
            "commits": [{"id": "abc123456"}, {"id": "def789"}],
            "head_commit": {"id": "abc123456"},
        }).encode()

    def test_push_event_written(self, monkeypatch):
        monkeypatch.setattr(wh, "GITHUB_WEBHOOK_SECRET", "")
        result, status = wh.handle_webhook(self._push_body(), "", "push")
        assert status == 200
        evts = ev.read_events()
        assert len(evts) == 1
        assert evts[0]["type"] == "push"
        assert evts[0]["repo"] == "org/repo"
        assert evts[0]["branch"] == "feature"
        assert evts[0]["payload"]["commits"] == 2


# ── router.py ────────────────────────────────────────────────────────────────


class TestAgentDispatch:
    def test_basic_dispatch(self):
        result, status = rt.dispatch({
            "agent": "copilot",
            "action": "summarize",
            "repo": "org/repo",
        })
        assert status == 202
        assert result["ok"] is True
        assert result["agent"] == "copilot"

    def test_unknown_agent_falls_back_to_general(self):
        result, status = rt.dispatch({"agent": "unknown_bot", "action": "plan"})
        assert status == 202
        assert result["agent"] == "general"

    def test_missing_action_returns_400(self):
        result, status = rt.dispatch({"agent": "openai"})
        assert status == 400

    def test_event_written_to_queue(self):
        rt.dispatch({"agent": "claude", "action": "critique", "branch": "main"})
        evts = ev.read_events()
        assert len(evts) == 1
        assert evts[0]["source"] == "agent:claude"
        assert evts[0]["status"] == "queued"
