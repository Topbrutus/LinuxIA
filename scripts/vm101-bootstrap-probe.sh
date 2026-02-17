#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/linuxia"
HOST="$(hostname -s || hostname)"
TS="$(date +%Y%m%dT%H%M%S%z)"

echo "== LinuxIA VM101 | Agent probe bootstrap =="
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

# --- sanity repo ---
[ -d "${REPO}/.git" ] || { echo "ERROR: repo introuvable: ${REPO}/.git" >&2; exit 2; }
cd "${REPO}"

# --- deps (best-effort) ---
if command -v zypper >/dev/null 2>&1; then
  echo "[1/6] Packages OS (best-effort) ..."
  ${SUDO} zypper -n in -y curl jq util-linux >/dev/null 2>&1 || true
fi

mkdir -p "${REPO}/tools" "${REPO}/ops/vm101" "${REPO}/logs" "${REPO}/var" "${REPO}/docs/verifications"

BASE_DEFAULT="http://127.0.0.1:8111"
ENV_PATH="${REPO}/ops/vm101/probe.env"
PROBE="${REPO}/tools/vm101_probe.sh"

# --- env (idempotent) ---
echo "[2/6] Env file ..."
if [ ! -f "${ENV_PATH}" ]; then
  cat > "${ENV_PATH}" <<EOF
# VM101 probe env
LINUXIA_BASE=${BASE_DEFAULT}
LINUXIA_REPO=${REPO}
EOF
  echo "  -> créé: ${ENV_PATH}"
else
  echo "  -> déjà présent: ${ENV_PATH} (inchangé)"
fi

# --- script probe (création seulement si absent) ---
echo "[3/6] Script probe ..."
if [ ! -f "${PROBE}" ]; then
  cat > "${PROBE}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

REPO="${LINUXIA_REPO:-/opt/linuxia}"
BASE="${LINUXIA_BASE:-http://127.0.0.1:8111}"
HOST="$(hostname -s || hostname)"
NOW_ISO="$(date --iso-8601=seconds)"
LOG="${REPO}/logs/vm101_probe.jsonl"
LOCK="${REPO}/var/vm101_probe.lock"

mkdir -p "${REPO}/logs" "${REPO}/var"

# lock non-bloquant (si timer overlap)
exec 9>"${LOCK}"
if command -v flock >/dev/null 2>&1; then
  flock -n 9 || exit 0
fi

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 2; }; }
need curl
need jq
need findmnt
need systemctl
need journalctl

orch_service="linuxia-orchestrator.service"
orch_active="$(systemctl is-active "${orch_service}" 2>/dev/null || true)"

orch_health="fail"
if curl -fsS "${BASE}/healthz" >/dev/null 2>&1; then orch_health="ok"; fi

failed_units="$(systemctl --no-pager --failed 2>/dev/null | tail -n +2 | grep -c . || true)"
err_5m="$(journalctl -p err -S -5min --no-pager 2>/dev/null | wc -l | tr -d ' ')"

load="$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "")"
mem_avail_kb="$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null || echo "0")"

# Paths de mounts attendus (adaptables)
A1="/srv/linuxia-remote/DATA_1TB_A"
B1="/srv/linuxia-remote/DATA_1TB_B"
A2="/mnt/linuxia/DATA_1TB_A"
B2="/mnt/linuxia/DATA_1TB_B"

fstype_of() { findmnt -rn "$1" -o FSTYPE 2>/dev/null || true; }
source_of() { findmnt -rn "$1" -o SOURCE 2>/dev/null || true; }

A1_FS="$(fstype_of "$A1")"; A1_SRC="$(source_of "$A1")"
B1_FS="$(fstype_of "$B1")"; B1_SRC="$(source_of "$B1")"
A2_FS="$(fstype_of "$A2")"; A2_SRC="$(source_of "$A2")"
B2_FS="$(fstype_of "$B2")"; B2_SRC="$(source_of "$B2")"

PATCH="$(jq -cn \
  --arg host "$HOST" \
  --arg iso "$NOW_ISO" \
  --arg orch_active "$orch_active" \
  --arg orch_health "$orch_health" \
  --arg load "$load" \
  --arg mem_avail_kb "$mem_avail_kb" \
  --arg err_5m "$err_5m" \
  --arg failed_units "$failed_units" \
  --arg a1 "$A1" --arg a1_fs "$A1_FS" --arg a1_src "$A1_SRC" \
  --arg b1 "$B1" --arg b1_fs "$B1_FS" --arg b1_src "$B1_SRC" \
  --arg a2 "$A2" --arg a2_fs "$A2_FS" --arg a2_src "$A2_SRC" \
  --arg b2 "$B2" --arg b2_fs "$B2_FS" --arg b2_src "$B2_SRC" \
'{
  vm101: {
    heartbeat: {
      ts: $iso,
      host: $host,
      orch_service: $orch_active,
      orch_health: $orch_health,
      load: $load,
      mem_avail_kb: ($mem_avail_kb|tonumber),
      journal_err_5m: ($err_5m|tonumber),
      failed_units: ($failed_units|tonumber),
      mounts: {
        data_1tb_a_primary: { path: $a1, fstype: $a1_fs, source: $a1_src, mounted: ($a1_fs != "") },
        data_1tb_b_primary: { path: $b1, fstype: $b1_fs, source: $b1_src, mounted: ($b1_fs != "") },
        data_1tb_a_alt:     { path: $a2, fstype: $a2_fs, source: $a2_src, mounted: ($a2_fs != "") },
        data_1tb_b_alt:     { path: $b2, fstype: $b2_fs, source: $b2_src, mounted: ($b2_fs != "") }
      }
    }
  }
}')"

EVENT="$(jq -c --arg ts "$NOW_ISO" --arg type "VM101_PROBE" --arg host "$HOST" --argjson patch "$PATCH" \
'{ts:$ts,type:$type,host:$host,patch:$patch}')"
echo "$EVENT" >> "$LOG"

# Post vers /api/state (priorité au statectl si présent)
STATECTL="${REPO}/tools/linuxia_statectl.sh"
if [ -x "$STATECTL" ]; then
  "$STATECTL" patch "vm101" "probe heartbeat" "$PATCH" >/dev/null 2>&1 || true
else
  BODY="$(jq -cn --arg actor "vm101" --arg reason "probe heartbeat" --argjson patch "$PATCH" \
    '{actor:$actor,reason:$reason,patch:$patch}')"
  curl -fsS -X POST "${BASE}/api/state" -H 'Content-Type: application/json' -d "$BODY" >/dev/null 2>&1 || true
fi
SH
  chmod +x "${PROBE}"
  echo "  -> créé: ${PROBE}"
else
  echo "  -> déjà présent: ${PROBE} (inchangé)"
fi

# --- service + timer systemd (création seulement si absent) ---
echo "[4/6] systemd unit + timer ..."
UNIT_SVC="/etc/systemd/system/linuxia-vm101-probe.service"
UNIT_TMR="/etc/systemd/system/linuxia-vm101-probe.timer"

if [ ! -f "${UNIT_SVC}" ]; then
  ${SUDO} bash -lc "cat > '${UNIT_SVC}' <<'UNIT'
[Unit]
Description=LinuxIA VM101 Probe (heartbeat + evidence JSONL)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
WorkingDirectory=${REPO}
EnvironmentFile=${ENV_PATH}
ExecStart=${PROBE}
StandardOutput=journal
StandardError=journal
UNIT"
  echo "  -> créé: ${UNIT_SVC}"
else
  echo "  -> déjà présent: ${UNIT_SVC} (inchangé)"
fi

if [ ! -f "${UNIT_TMR}" ]; then
  ${SUDO} bash -lc "cat > '${UNIT_TMR}' <<'UNIT'
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
UNIT"
  echo "  -> créé: ${UNIT_TMR}"
else
  echo "  -> déjà présent: ${UNIT_TMR} (inchangé)"
fi

${SUDO} systemctl daemon-reload
${SUDO} systemctl enable --now linuxia-vm101-probe.timer >/dev/null 2>&1 || true
${SUDO} systemctl start linuxia-vm101-probe.timer >/dev/null 2>&1 || true

# --- collecteur de preuves (simple) ---
echo "[5/6] Collecteur de preuves (script) ..."
COLLECT="${REPO}/tools/vm101_collect_proofs.sh"
if [ ! -f "${COLLECT}" ]; then
  cat > "${COLLECT}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
REPO="${LINUXIA_REPO:-/opt/linuxia}"
HOST="$(hostname -s || hostname)"
TS="$(date +%Y%m%dT%H%M%S%z)"
OUT="${REPO}/docs/verifications/${HOST}_proofpack_${TS}.txt"

{
  echo "== PROOFPACK VM101 =="
  echo "host=${HOST}"
  echo "ts=${TS}"
  echo
  echo "=== services ==="
  systemctl --no-pager -l status linuxia-orchestrator.service | sed -n '1,120p' || true
  echo
  systemctl --no-pager -l status linuxia-vm101-probe.timer | sed -n '1,120p' || true
  echo
  echo "=== timers (filtered) ==="
  systemctl list-timers --no-pager | egrep -i 'linuxia|probe' || true
  echo
  echo "=== mounts (filtered) ==="
  findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS | egrep -i 'cifs|autofs|linuxia|smb' || true
  echo
  echo "=== last probe journal ==="
  journalctl -u linuxia-vm101-probe.service -n 80 --no-pager || true
  echo
  echo "=== last orchestrator journal ==="
  journalctl -u linuxia-orchestrator.service -n 120 --no-pager || true
  echo
  echo "=== probe jsonl tail ==="
  tail -n 20 "${REPO}/logs/vm101_probe.jsonl" 2>/dev/null || true
} | tee "${OUT}"

echo
echo "✅ preuve écrite: ${OUT}"
SH
  chmod +x "${COLLECT}"
  echo "  -> créé: ${COLLECT}"
else
  echo "  -> déjà présent: ${COLLECT} (inchangé)"
fi

# --- run immédiat + preuves ---
echo "[6/6] Run immédiat + preuves ..."
"${PROBE}" || true
"${COLLECT}" || true

echo
echo "✅ OK. Le timer envoie un heartbeat + écrit logs/vm101_probe.jsonl toutes les ~30s."
echo "➡️ Pour vérifier l'état côté API:"
echo "   ${REPO}/tools/linuxia_statectl.sh get"
