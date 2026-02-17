#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/linuxia"
HOST="$(hostname -s || hostname)"
TS="$(date +%Y%m%dT%H%M%S%z)"
BRANCH_DEFAULT="vm101-orchestrator-stack"

echo "== LinuxIA VM101 | Repo hardening + replay + templates systemd + git commit =="
echo "host=${HOST} ts=${TS}"
echo

# --- garde-fou repo ---
[ -d "${REPO}/.git" ] || { echo "ERROR: repo introuvable: ${REPO}/.git" >&2; exit 2; }
cd "${REPO}"

mkdir -p \
  "${REPO}/services/systemd" \
  "${REPO}/tools" \
  "${REPO}/docs/vm101" \
  "${REPO}/docs/verifications" \
  "${REPO}/var" \
  "${REPO}/logs"

# ---------------------------
# 1) .gitignore (idempotent)
# ---------------------------
echo "[1/7] .gitignore ..."
GITIGNORE="${REPO}/.gitignore"
touch "${GITIGNORE}"

add_ignore() {
  local line="$1"
  grep -qxF "${line}" "${GITIGNORE}" || echo "${line}" >> "${GITIGNORE}"
}

add_ignore "# --- LinuxIA runtime (VM local) ---"
add_ignore ".venv/"
add_ignore "var/*.lock"
add_ignore "var/state.json"
add_ignore "var/state.json.tmp"
add_ignore "var/state_replayed.json"
add_ignore "logs/*.jsonl"
add_ignore "logs/*.log"
add_ignore "__pycache__/"
add_ignore "*.pyc"

# On garde les preuves (docs/verifications) versionnables
add_ignore "!docs/verifications/"
add_ignore "!docs/verifications/*.txt"

# --------------------------------------------
# 2) Templates systemd dans le repo (canon)
# --------------------------------------------
echo "[2/7] templates systemd (repo/services/systemd) ..."

cat > "${REPO}/services/systemd/linuxia-orchestrator.service" <<'UNIT'
[Unit]
Description=LinuxIA Orchestrator API (/api/state)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=linuxia
WorkingDirectory=/opt/linuxia
EnvironmentFile=/opt/linuxia/ops/vm101/orchestrator.env
ExecStart=/opt/linuxia/.venv/bin/uvicorn services.orchestrator.api:app --host 127.0.0.1 --port 8111
Restart=on-failure
RestartSec=1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

cat > "${REPO}/services/systemd/linuxia-vm101-probe.service" <<'UNIT'
[Unit]
Description=LinuxIA VM101 Probe (heartbeat + evidence JSONL)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
WorkingDirectory=/opt/linuxia
EnvironmentFile=/opt/linuxia/ops/vm101/probe.env
ExecStart=/opt/linuxia/tools/vm101_probe.sh
StandardOutput=journal
StandardError=journal
UNIT

cat > "${REPO}/services/systemd/linuxia-vm101-probe.timer" <<'UNIT'
[Unit]
Description=Run LinuxIA VM101 Probe every 30s

[Timer]
OnBootSec=20
OnUnitActiveSec=30
AccuracySec=5
Persistent=true
Unit=linuxia-vm101-probe.service

[Install]
WantedBy=timers.target
UNIT

# --------------------------------------------
# 3) Install script systemd (safe + idempotent)
# --------------------------------------------
echo "[3/7] tools/install_systemd_units_vm101.sh ..."
INSTALL="${REPO}/tools/install_systemd_units_vm101.sh"
cat > "${INSTALL}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/linuxia"
SRC="${REPO}/services/systemd"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 2; }; }
need systemctl

# sudo garde-fou non-interactif
SUDO="sudo"
if [ "${EUID:-$(id -u)}" -eq 0 ]; then SUDO=""; else
  command -v sudo >/dev/null 2>&1 || { echo "ERROR: sudo absent (pas root)." >&2; exit 3; }
  sudo -n true 2>/dev/null || { echo "ERROR: sudo demande un mot de passe (non-interactif)." >&2; exit 3; }
fi

# user linuxia: si absent, on patch User= vers l'utilisateur courant
TARGET_USER="linuxia"
if ! id -u "${TARGET_USER}" >/dev/null 2>&1; then
  TARGET_USER="${USER:-root}"
fi

tmpdir="$(mktemp -d)"
cleanup(){ rm -rf "$tmpdir"; }
trap cleanup EXIT

cp -a "${SRC}/linuxia-orchestrator.service" "${tmpdir}/linuxia-orchestrator.service"
sed -i "s/^User=linuxia$/User=${TARGET_USER}/" "${tmpdir}/linuxia-orchestrator.service"

${SUDO} install -m 0644 "${tmpdir}/linuxia-orchestrator.service" /etc/systemd/system/linuxia-orchestrator.service
${SUDO} install -m 0644 "${SRC}/linuxia-vm101-probe.service" /etc/systemd/system/linuxia-vm101-probe.service
${SUDO} install -m 0644 "${SRC}/linuxia-vm101-probe.timer"   /etc/systemd/system/linuxia-vm101-probe.timer

${SUDO} systemctl daemon-reload
${SUDO} systemctl enable --now linuxia-orchestrator.service || true
${SUDO} systemctl enable --now linuxia-vm101-probe.timer    || true
${SUDO} systemctl restart linuxia-orchestrator.service || true

echo "✅ systemd units installed/enabled."
systemctl --no-pager -l status linuxia-orchestrator.service | sed -n '1,80p' || true
systemctl --no-pager -l status linuxia-vm101-probe.timer    | sed -n '1,80p' || true
SH
chmod +x "${INSTALL}"

# --------------------------------------------
# 4) Replay tool (STATE_PATCHED -> state_replayed.json)
# --------------------------------------------
echo "[4/7] tools/state_replay.py ..."
REPLAY="${REPO}/tools/state_replay.py"
cat > "${REPLAY}" <<'PY'
from __future__ import annotations

import argparse, json, hashlib, sys
from pathlib import Path
from typing import Any, Dict

def sha256(obj: Any) -> str:
    b = json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(b).hexdigest()

def deep_merge(dst: Dict[str, Any], src: Dict[str, Any]) -> Dict[str, Any]:
    for k, v in src.items():
        if isinstance(v, dict) and isinstance(dst.get(k), dict):
            dst[k] = deep_merge(dst[k], v)  # type: ignore[arg-type]
        else:
            dst[k] = v
    return dst

def main() -> int:
    ap = argparse.ArgumentParser(description="Replay LinuxIA state from events.jsonl (STATE_PATCHED).")
    ap.add_argument("--events", default="/opt/linuxia/logs/events.jsonl")
    ap.add_argument("--out", default="/opt/linuxia/var/state_replayed.json")
    ap.add_argument("--verify-against", default="/opt/linuxia/var/state.json")
    ap.add_argument("--max-lines", type=int, default=0, help="0 = no limit")
    args = ap.parse_args()

    events = Path(args.events)
    out = Path(args.out)
    verify = Path(args.verify_against)

    state: Dict[str, Any] = {}
    if not events.exists():
        print(f"ERROR: events file not found: {events}", file=sys.stderr)
        return 2

    n = 0
    applied = 0
    with events.open("r", encoding="utf-8") as f:
        for line in f:
            if args.max_lines and n >= args.max_lines:
                break
            n += 1
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except Exception:
                print(f"ERROR: invalid JSON at line {n}", file=sys.stderr)
                return 3

            if ev.get("type") != "STATE_PATCHED":
                continue
            patch = ev.get("patch")
            if not isinstance(patch, dict):
                continue

            deep_merge(state, patch)
            applied += 1

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")

    print("== REPLAY RESULT ==")
    print(f"events={events}")
    print(f"lines_read={n}")
    print(f"patches_applied={applied}")
    print(f"out={out}")
    print(f"out_sha256={sha256(state)}")

    if verify.exists():
        try:
            current = json.loads(verify.read_text(encoding="utf-8"))
        except Exception:
            print(f"WARNING: verify file unreadable: {verify}", file=sys.stderr)
            return 0
        print(f"verify={verify}")
        print(f"verify_sha256={sha256(current)}")
        print(f"match={(sha256(current) == sha256(state))}")
    else:
        print(f"verify_missing={verify}")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
PY

# --------------------------------------------
# 5) Doc VM101 (opération + continuité)
# --------------------------------------------
echo "[5/7] docs/vm101/orchestrator_vm101.md ..."
DOC="${REPO}/docs/vm101/orchestrator_vm101.md"
cat > "${DOC}" <<'MD'
# VM101 — Orchestrateur LinuxIA (API `/api/state`) + Probe

## Services systemd
- `linuxia-orchestrator.service` : API locale FastAPI (bind `127.0.0.1:8111`)
- `linuxia-vm101-probe.timer` : heartbeat toutes ~30s (oneshot `linuxia-vm101-probe.service`)

## Endpoints
- `GET  /healthz`
- `GET  /api/state`
- `POST /api/state` (patch merge-safe)

## Fichiers runtime (non versionnés)
- État: `/opt/linuxia/var/state.json`
- Lock: `/opt/linuxia/var/state.lock`
- Events: `/opt/linuxia/logs/events.jsonl`
- Probe log local: `/opt/linuxia/logs/vm101_probe.jsonl`

## Outils
- `tools/linuxia_statectl.sh get|health|patch`
- `tools/vm101_probe.sh` (exécute 1 heartbeat)
- `tools/vm101_collect_proofs.sh` (pack preuves)
- `tools/state_replay.py` (reconstruit l'état depuis events.jsonl)
- `tools/install_systemd_units_vm101.sh` (réinstalle les units depuis le repo)

## Vérifications rapides
\`\`\`bash
systemctl status linuxia-orchestrator.service --no-pager -l
curl -fsS http://127.0.0.1:8111/healthz
/opt/linuxia/tools/linuxia_statectl.sh get
/opt/linuxia/tools/vm101_collect_proofs.sh
python3 /opt/linuxia/tools/state_replay.py
\`\`\`

## Dépannage (preuve-first)
- Si pull non fast-forward → STOP, pas de force-push
- Si service down → `journalctl -u linuxia-orchestrator.service -n 200 --no-pager`
- Si probe ne tick pas → `systemctl list-timers | grep -i probe` + `journalctl -u linuxia-vm101-probe.service -n 120 --no-pager`
MD

# --------------------------------------------
# 6) Preuves + replay + pack
# --------------------------------------------
echo "[6/7] preuves (replay + proofpack) ..."

# best-effort jq/curl
command -v jq >/dev/null 2>&1 || true
command -v curl >/dev/null 2>&1 || true

# replay (ne casse pas si events absent)
python3 "${REPLAY}" || true

# proofpack existant si déjà créé dans bloc précédent
if [ -x "${REPO}/tools/vm101_collect_proofs.sh" ]; then
  "${REPO}/tools/vm101_collect_proofs.sh" || true
else
  OUT="${REPO}/docs/verifications/${HOST}_proofpack_${TS}.txt"
  {
    echo "== PROOFPACK VM101 (fallback) =="; echo "host=${HOST} ts=${TS}"; echo
    systemctl --no-pager -l status linuxia-orchestrator.service | sed -n '1,120p' || true
    echo
    systemctl --no-pager -l status linuxia-vm101-probe.timer | sed -n '1,120p' || true
    echo
    tail -n 20 "${REPO}/logs/vm101_probe.jsonl" 2>/dev/null || true
  } | tee "${OUT}"
fi

# --------------------------------------------
# 7) Git: branche safe + commit (push optionnel)
# --------------------------------------------
echo "[7/7] Git branch + commit ..."
git remote -v || true
git status -sb

CUR_BRANCH="$(git branch --show-current || echo '')"
if [ -z "${CUR_BRANCH}" ]; then
  echo "WARNING: branche inconnue. (detached HEAD?)" >&2
else
  if [ "${CUR_BRANCH}" = "main" ] || [ "${CUR_BRANCH}" = "master" ]; then
    BR="${BRANCH_DEFAULT}"
    echo "Branche protégée détectée (${CUR_BRANCH}) -> création feature branch: ${BR}"
    git checkout -b "${BR}"
  fi
fi

git add \
  .gitignore \
  services/systemd/ \
  tools/install_systemd_units_vm101.sh \
  tools/state_replay.py \
  docs/vm101/orchestrator_vm101.md || true

# On commit seulement si nécessaire
if ! git diff --cached --quiet; then
  git commit -m "vm101: add systemd templates, state replay tool, and docs (proof-first)" || true
else
  echo "Rien à commit (cached)."
fi

echo
echo "✅ Terminé."
echo "➡️ Option push (si tu veux) :"
echo "   git push -u origin HEAD"
