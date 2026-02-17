#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/linuxia"
HOST="$(hostname -s || hostname)"
TS="$(date +%Y%m%dT%H%M%S%z)"
BIND="127.0.0.1"
PORT_API="8111"
PORT_PROXY="8110"

echo "== LinuxIA VM101 | Observability + Reverse Proxy =="
echo "host=${HOST} ts=${TS}"
echo

# --- garde-fou root/sudo (non-interactif) ---
is_root="no"
if [ "${EUID:-$(id -u)}" -eq 0 ]; then is_root="yes"; fi

SUDO="sudo"
if [ "$is_root" = "yes" ]; then
  SUDO=""
else
  command -v sudo >/dev/null 2>&1 || { echo "ERROR: sudo absent (pas root)." >&2; exit 3; }
  sudo -n true 2>/dev/null || { echo "ERROR: sudo demande un mot de passe (non-interactif). Passe en root ou NOPASSWD." >&2; exit 3; }
fi

# --- repo ---
[ -d "${REPO}/.git" ] || { echo "ERROR: repo introuvable: ${REPO}/.git" >&2; exit 2; }
cd "${REPO}"
mkdir -p "${REPO}/services/orchestrator" "${REPO}/tools" "${REPO}/docs/verifications"

VENV="${REPO}/.venv"
if [ ! -d "${VENV}" ]; then
  echo "ERROR: venv introuvable: ${VENV}. (Exécute d'abord le bloc bootstrap orchestrateur.)" >&2
  exit 4
fi

# --- Python deps: prometheus_client ---
echo "[1/6] Python deps (prometheus_client) ..."
# shellcheck disable=SC1091
source "${VENV}/bin/activate"
python -m pip install -q -U pip
python -m pip install -q prometheus_client

# --- API wrapper: ajoute /metrics sans toucher api.py ---
echo "[2/6] Création api_metrics.py (idempotent) ..."
METRICS_MOD="${REPO}/services/orchestrator/api_metrics.py"
if [ ! -f "${METRICS_MOD}" ]; then
  cat > "${METRICS_MOD}" <<'PY'
from __future__ import annotations

# Wrap l'app existante et expose /metrics (Prometheus)
from services.orchestrator.api import app  # noqa: F401

from prometheus_client import make_asgi_app, Gauge
import time

# Métriques simples
linuxia_build_ts = Gauge("linuxia_build_timestamp", "Unix timestamp when the app started")
linuxia_build_ts.set(int(time.time()))

# Monte /metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)
PY
  echo "  -> créé: ${METRICS_MOD}"
else
  echo "  -> déjà présent: ${METRICS_MOD} (inchangé)"
fi

# --- systemd drop-in: bascule ExecStart vers api_metrics:app ---
echo "[3/6] systemd drop-in (linuxia-orchestrator.service) ..."
DROP_DIR="/etc/systemd/system/linuxia-orchestrator.service.d"
DROP_FILE="${DROP_DIR}/10-metrics.conf"
${SUDO} mkdir -p "${DROP_DIR}"

if [ ! -f "${DROP_FILE}" ]; then
  ${SUDO} bash -lc "cat > '${DROP_FILE}' <<UNIT
[Service]
# Override ExecStart proprement
ExecStart=
ExecStart=${REPO}/.venv/bin/uvicorn services.orchestrator.api_metrics:app --host ${BIND} --port ${PORT_API}
UNIT"
  echo "  -> créé: ${DROP_FILE}"
else
  echo "  -> déjà présent: ${DROP_FILE} (inchangé)"
fi

${SUDO} systemctl daemon-reload
${SUDO} systemctl restart linuxia-orchestrator.service || true

# --- Nginx reverse proxy local (127.0.0.1:8110) ---
echo "[4/6] Nginx reverse proxy (localhost only) ..."
if command -v zypper >/dev/null 2>&1; then
  ${SUDO} zypper -n in -y nginx >/dev/null 2>&1 || true
fi

NGX_CONF_DIR="/etc/nginx/conf.d"
NGX_CONF="${NGX_CONF_DIR}/linuxia_orchestrator.conf"
${SUDO} mkdir -p "${NGX_CONF_DIR}"

if [ ! -f "${NGX_CONF}" ]; then
  ${SUDO} bash -lc "cat > '${NGX_CONF}' <<'NGINX'
# LinuxIA Orchestrator reverse proxy (local only)
# NOTE: écoute sur 127.0.0.1:8110. Pour LAN, change "listen 127.0.0.1:8110" -> "listen 0.0.0.0:8110" (à faire consciemment).
upstream linuxia_orchestrator_upstream {
  server 127.0.0.1:8111;
  keepalive 16;
}

server {
  listen 127.0.0.1:8110;
  server_name localhost;

  # hygiene
  client_max_body_size 1m;
  proxy_read_timeout 10s;
  proxy_connect_timeout 2s;
  proxy_send_timeout 10s;

  add_header X-Content-Type-Options nosniff always;
  add_header X-Frame-Options DENY always;
  add_header Referrer-Policy no-referrer always;

  location / {
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    proxy_pass http://linuxia_orchestrator_upstream;
  }
}
NGINX"
  echo "  -> créé: ${NGX_CONF}"
else
  echo "  -> déjà présent: ${NGX_CONF} (inchangé)"
fi

# enable/start nginx (best-effort)
${SUDO} systemctl enable --now nginx >/dev/null 2>&1 || true
${SUDO} systemctl restart nginx >/dev/null 2>&1 || true

# --- outils de check + preuve pack ---
echo "[5/6] Outil quickcheck observabilité ..."
QC="${REPO}/tools/vm101_quickcheck_obs.sh"
if [ ! -f "${QC}" ]; then
  cat > "${QC}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
REPO="/opt/linuxia"
HOST="$(hostname -s || hostname)"
TS="$(date +%Y%m%dT%H%M%S%z)"
OUT="${REPO}/docs/verifications/${HOST}_obs_${TS}.txt"

{
  echo "== VM101 OBS QUICKCHECK =="
  echo "host=${HOST}"
  echo "ts=${TS}"
  echo

  echo "=== systemd status (orchestrator) ==="
  systemctl --no-pager -l status linuxia-orchestrator.service | sed -n '1,120p' || true
  echo

  echo "=== curl API direct (8111) ==="
  curl -fsS http://127.0.0.1:8111/healthz || true
  echo
  echo "--- /metrics (head) ---"
  curl -fsS http://127.0.0.1:8111/metrics | head -n 25 || true
  echo

  echo "=== nginx status ==="
  systemctl --no-pager -l status nginx | sed -n '1,80p' || true
  echo

  echo "=== curl via nginx proxy (8110) ==="
  curl -fsS http://127.0.0.1:8110/healthz || true
  echo
  echo "--- /metrics via proxy (head) ---"
  curl -fsS http://127.0.0.1:8110/metrics | head -n 25 || true
  echo

  echo "=== nginx conf ==="
  sed -n '1,140p' /etc/nginx/conf.d/linuxia_orchestrator.conf 2>/dev/null || true
  echo

  echo "=== journald tail orchestrator ==="
  journalctl -u linuxia-orchestrator.service -n 120 --no-pager || true
  echo
} | tee "${OUT}"

echo
echo "✅ preuve écrite: ${OUT}"
SH
  chmod +x "${QC}"
  echo "  -> créé: ${QC}"
else
  echo "  -> déjà présent: ${QC} (inchangé)"
fi

# --- exécuter quickcheck ---
echo "[6/6] Preuves immédiates ..."
"${QC}" || true

echo
echo "✅ OK. Endpoints:"
echo "  Direct: http://${BIND}:${PORT_API}/healthz  |  http://${BIND}:${PORT_API}/metrics"
echo "  Proxy : http://${BIND}:${PORT_PROXY}/healthz |  http://${BIND}:${PORT_PROXY}/metrics"
echo
echo "NOTE sécurité: nginx écoute LOCALHOST. Pour exposer au LAN, modifie le 'listen' dans ${NGX_CONF} volontairement."
