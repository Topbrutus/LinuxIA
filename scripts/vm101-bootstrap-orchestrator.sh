#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/linuxia"
HOST="$(hostname -s || hostname)"
TS="$(date +%Y%m%dT%H%M%S%z)"

echo "== LinuxIA VM101 | Orchestrator bootstrap =="
echo "host=${HOST} ts=${TS}"
echo

# --- garde-fou root/sudo (non-interactif) ---
is_root="no"
if [ "${EUID:-$(id -u)}" -eq 0 ]; then is_root="yes"; fi

SUDO="sudo"
if [ "$is_root" = "yes" ]; then
  SUDO=""
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "ERROR: sudo absent et pas root. Relance en root." >&2
    exit 3
  fi
  if ! sudo -n true 2>/dev/null; then
    echo "ERROR: sudo nécessite un mot de passe (mode non-interactif). Ouvre une session root, ou configure sudo NOPASSWD pour ce compte." >&2
    exit 3
  fi
fi

# --- repo ---
if [ ! -d "${REPO}/.git" ]; then
  echo "ERROR: repo introuvable: ${REPO}/.git" >&2
  exit 2
fi
cd "${REPO}"

# --- dossiers standards ---
mkdir -p "${REPO}/ops/vm101" "${REPO}/var" "${REPO}/logs" "${REPO}/tools" "${REPO}/services/orchestrator"

STATE_PATH="${REPO}/var/state.json"
EVENTS_PATH="${REPO}/logs/events.jsonl"
ENV_PATH="${REPO}/ops/vm101/orchestrator.env"
VENV="${REPO}/.venv"
PORT="8111"
BIND="127.0.0.1"

# --- deps OS (openSUSE-friendly, best-effort) ---
if command -v zypper >/dev/null 2>&1; then
  echo "[1/7] Packages OS (best-effort via zypper) ..."
  pkgs=(git curl jq python3 python3-pip python3-virtualenv python311 python311-pip python311-virtualenv)
  for p in "${pkgs[@]}"; do
    ${SUDO} zypper -n in -y "$p" >/dev/null 2>&1 || true
  done
fi

# --- python / venv ---
echo "[2/7] Python venv ..."
PY="$(command -v python3 || true)"
if [ -z "${PY}" ]; then
  echo "ERROR: python3 introuvable." >&2
  exit 4
fi

if [ ! -d "${VENV}" ]; then
  "${PY}" -m venv "${VENV}"
fi

# shellcheck disable=SC1091
source "${VENV}/bin/activate"
python -m pip install -U pip >/dev/null

# requirements: si un requirements.txt existe, on l'utilise; sinon on installe un set minimal
REQ_CANDIDATES=(
  "${REPO}/services/orchestrator/requirements.txt"
  "${REPO}/requirements.txt"
)
REQ_FILE=""
for f in "${REQ_CANDIDATES[@]}"; do
  if [ -f "$f" ]; then REQ_FILE="$f"; break; fi
done

echo "[3/7] Python deps ..."
if [ -n "${REQ_FILE}" ]; then
  pip install -r "${REQ_FILE}" >/dev/null
else
  pip install fastapi "uvicorn[standard]" pydantic python-dotenv orjson >/dev/null
fi

# --- code API (création seulement si absent) ---
echo "[4/7] API /api/state ..."
mkdir -p "${REPO}/services" "${REPO}/services/orchestrator"
[ -f "${REPO}/services/__init__.py" ] || printf "" > "${REPO}/services/__init__.py"
[ -f "${REPO}/services/orchestrator/__init__.py" ] || printf "" > "${REPO}/services/orchestrator/__init__.py"

API_FILE="${REPO}/services/orchestrator/api.py"
if [ ! -f "${API_FILE}" ]; then
  cat > "${API_FILE}" <<'PY'
from __future__ import annotations

import os, json, time, hashlib
from pathlib import Path
from typing import Any, Dict, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

try:
    import fcntl  # linux only
except Exception:  # pragma: no cover
    fcntl = None  # type: ignore

APP_NAME = "linuxia-orchestrator"
STATE_PATH = Path(os.getenv("LINUXIA_STATE_PATH", "/opt/linuxia/var/state.json"))
EVENTS_PATH = Path(os.getenv("LINUXIA_EVENTS_PATH", "/opt/linuxia/logs/events.jsonl"))
LOCK_PATH = Path(os.getenv("LINUXIA_LOCK_PATH", "/opt/linuxia/var/state.lock"))

app = FastAPI(title=APP_NAME)

class StatePatch(BaseModel):
    patch: Dict[str, Any] = Field(default_factory=dict)
    actor: str = "unknown"
    reason: str = "unspecified"

def _sha256(obj: Any) -> str:
    b = json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(b).hexdigest()

def _deep_merge(dst: Dict[str, Any], src: Dict[str, Any]) -> Dict[str, Any]:
    for k, v in src.items():
        if isinstance(v, dict) and isinstance(dst.get(k), dict):
            dst[k] = _deep_merge(dst[k], v)  # type: ignore[arg-type]
        else:
            dst[k] = v
    return dst

def _ensure_dirs() -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    EVENTS_PATH.parent.mkdir(parents=True, exist_ok=True)
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)

class _FileLock:
    def __init__(self, lock_path: Path):
        self.lock_path = lock_path
        self.fd = None

    def __enter__(self):
        _ensure_dirs()
        self.fd = open(self.lock_path, "a+", encoding="utf-8")
        if fcntl:
            fcntl.flock(self.fd.fileno(), fcntl.LOCK_EX)
        return self

    def __exit__(self, exc_type, exc, tb):
        if self.fd:
            if fcntl:
                fcntl.flock(self.fd.fileno(), fcntl.LOCK_UN)
            self.fd.close()

def _read_state() -> Dict[str, Any]:
    if not STATE_PATH.exists():
        return {}
    try:
        return json.loads(STATE_PATH.read_text(encoding="utf-8"))
    except Exception:
        # état corrompu -> on stoppe (preuve-first)
        raise HTTPException(status_code=500, detail="State file is unreadable/corrupted")

def _write_state(state: Dict[str, Any]) -> None:
    tmp = STATE_PATH.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")
    tmp.replace(STATE_PATH)

def _append_event(event: Dict[str, Any]) -> None:
    line = json.dumps(event, ensure_ascii=False, separators=(",", ":"))
    with EVENTS_PATH.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

@app.get("/healthz")
def healthz():
    return {"ok": True, "service": APP_NAME, "ts": int(time.time())}

@app.get("/api/state")
def get_state():
    _ensure_dirs()
    with _FileLock(LOCK_PATH):
        state = _read_state()
    return {
        "ok": True,
        "state_exists": STATE_PATH.exists(),
        "state_path": str(STATE_PATH),
        "events_path": str(EVENTS_PATH),
        "state": state,
        "state_sha256": _sha256(state),
        "ts": int(time.time()),
    }

@app.post("/api/state")
def patch_state(req: StatePatch):
    _ensure_dirs()
    now = int(time.time())
    with _FileLock(LOCK_PATH):
        before = _read_state()
        before_hash = _sha256(before)

        after = dict(before)
        _deep_merge(after, req.patch)
        after["meta"] = dict(after.get("meta", {}))
        after["meta"].update({"updated_at": now, "updated_by": req.actor, "reason": req.reason})

        after_hash = _sha256(after)
        _write_state(after)

    _append_event({
        "ts": now,
        "type": "STATE_PATCHED",
        "actor": req.actor,
        "reason": req.reason,
        "before_sha256": before_hash,
        "after_sha256": after_hash,
        "patch": req.patch,
    })

    return {"ok": True, "before_sha256": before_hash, "after_sha256": after_hash, "ts": now}
PY
  echo "  -> créé: ${API_FILE}"
else
  echo "  -> déjà présent: ${API_FILE} (inchangé)"
fi

# --- env file (idempotent) ---
echo "[5/7] Env file ..."
if [ ! -f "${ENV_PATH}" ]; then
  cat > "${ENV_PATH}" <<EOF
# VM101 orchestrator env
LINUXIA_STATE_PATH=${STATE_PATH}
LINUXIA_EVENTS_PATH=${EVENTS_PATH}
LINUXIA_LOCK_PATH=${REPO}/var/state.lock
EOF
  echo "  -> créé: ${ENV_PATH}"
else
  echo "  -> déjà présent: ${ENV_PATH} (inchangé)"
fi

# --- systemd unit (création seulement si absent) ---
echo "[6/7] systemd service ..."
UNIT="/etc/systemd/system/linuxia-orchestrator.service"
SVC_USER="linuxia"
if ! id -u "${SVC_USER}" >/dev/null 2>&1; then
  # si pas de user linuxia, on prend l'utilisateur courant
  SVC_USER="${USER:-root}"
fi

if [ ! -f "${UNIT}" ]; then
  ${SUDO} bash -lc "cat > '${UNIT}' <<'UNIT'
[Unit]
Description=LinuxIA Orchestrator API (/api/state)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${SVC_USER}
WorkingDirectory=${REPO}
EnvironmentFile=${ENV_PATH}
ExecStart=${VENV}/bin/uvicorn services.orchestrator.api:app --host ${BIND} --port ${PORT}
Restart=on-failure
RestartSec=1
# journald proof-first
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT"
  echo "  -> créé: ${UNIT}"
else
  echo "  -> déjà présent: ${UNIT} (inchangé)"
fi

${SUDO} systemctl daemon-reload

# enable/start (sans casser si déjà actif)
${SUDO} systemctl enable --now linuxia-orchestrator.service >/dev/null 2>&1 || true
${SUDO} systemctl restart linuxia-orchestrator.service >/dev/null 2>&1 || true

# --- outil CLI local ---
echo "[7/7] tools/linuxia_statectl.sh ..."
CTL="${REPO}/tools/linuxia_statectl.sh"
if [ ! -f "${CTL}" ]; then
  cat > "${CTL}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

BASE="${LINUXIA_BASE:-http://127.0.0.1:8111}"
cmd="${1:-get}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 2; }; }
need curl
need jq

case "$cmd" in
  get)
    curl -fsS "${BASE}/api/state" | jq .
    ;;
  health)
    curl -fsS "${BASE}/healthz" | jq .
    ;;
  patch)
    actor="${2:-vm101}"
    reason="${3:-update}"
    patch_json="${4:-{}}"
    curl -fsS -X POST "${BASE}/api/state" \
      -H 'Content-Type: application/json' \
      -d "{\"actor\":\"${actor}\",\"reason\":\"${reason}\",\"patch\":${patch_json}}" | jq .
    ;;
  *)
    echo "Usage:"
    echo "  $0 health"
    echo "  $0 get"
    echo "  $0 patch <actor> <reason> '<jsonPatch>'"
    exit 1
    ;;
esac
SH
  chmod +x "${CTL}"
  echo "  -> créé: ${CTL}"
else
  echo "  -> déjà présent: ${CTL} (inchangé)"
fi

echo
echo "== PREUVES =="
${SUDO} systemctl --no-pager -l status linuxia-orchestrator.service | sed -n '1,120p' || true
echo
curl -fsS "http://${BIND}:${PORT}/healthz" || true
echo
curl -fsS "http://${BIND}:${PORT}/api/state" | (command -v jq >/dev/null 2>&1 && jq . || cat) || true

echo
echo "✅ OK. Endpoints:"
echo "  - GET  http://${BIND}:${PORT}/healthz"
echo "  - GET  http://${BIND}:${PORT}/api/state"
echo "  - POST http://${BIND}:${PORT}/api/state"
echo
echo "Astuce:"
echo "  ${REPO}/tools/linuxia_statectl.sh health"
echo "  ${REPO}/tools/linuxia_statectl.sh get"
echo "  ${REPO}/tools/linuxia_statectl.sh patch vm101 'init' '{\"vm101\":{\"ready\":true}}'"
