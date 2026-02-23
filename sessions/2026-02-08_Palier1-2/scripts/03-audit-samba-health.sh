#!/usr/bin/env bash
set -euo pipefail
umask 0077
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

command -v python3 >/dev/null 2>&1
command -v sha256sum >/dev/null 2>&1

SESSION_DIR="${1:?Usage: 03-audit-samba-health.sh <session_dir> <external_base_dir>}"
EXTERNAL_BASE="${2:?Usage: 03-audit-samba-health.sh <session_dir> <external_base_dir>}"

SESSION_DIR="$(cd "$SESSION_DIR" && pwd -P)"
STAMP="$(date +%Y%m%d_%H%M%S)"
AUDIT="03-samba_${STAMP}"

EVDIR="$SESSION_DIR/evidence/$AUDIT"
mkdir -p "$EVDIR"

JSONL="$EVDIR/evidence.jsonl"
SUMMARY="$EVDIR/summary.json"
POINTER="$EVDIR/external_pointer.json"

EXTDIR="$EXTERNAL_BASE/$AUDIT"
RAW_DIR="$EXTDIR/raw"
mkdir -p "$RAW_DIR"
chmod 700 "$EXTDIR" "$RAW_DIR" 2>/dev/null || true

: > "$JSONL"
chmod 600 "$JSONL" 2>/dev/null || true

record() {
  local tag="$1"
  local cmd="$2"
  local out="$3"
  local rc="${4:-0}"
  local bytes sha
  bytes="$(stat -c %s "$out" 2>/dev/null || stat -f%z "$out")"
  sha="$(sha256sum "$out" | awk '{print $1}')"
  python3 - "$JSONL" "$tag" "$cmd" "$out" "$bytes" "$sha" "$rc" <<'PY'
import json,sys,datetime
jsonl_path,tag,cmd,out,bytes_s,sha,rc_s=sys.argv[1:]
entry={
  "timestamp": datetime.datetime.now().isoformat(),
  "tag": tag,
  "cmd": cmd,
  "out": out,
  "bytes": int(bytes_s),
  "sha256": sha,
  "rc": int(rc_s),
}
with open(jsonl_path,"a",encoding="utf-8") as f:
  f.write(json.dumps(entry, ensure_ascii=False) + "\n")
PY
}

capture_nf() {
  local tag="$1"; shift
  local out="$RAW_DIR/$tag"
  set +e
  "$@" >"$out" 2>&1
  local rc="$?"
  set -e
  chmod 600 "$out" 2>/dev/null || true
  record "$tag" "$*" "$out" "$rc"
}

# --- Baseline SELinux + mounts (référence doc: findmnt OPTIONS fiable sur FUSE) ---
capture_nf "getenforce.txt" getenforce
capture_nf "getsebool.txt" getsebool samba_share_fusefs samba_export_all_rw

capture_nf "findmnt_A.txt" findmnt -T /mnt/linuxia/DATA_1TB_A -o TARGET,SOURCE,FSTYPE,OPTIONS
capture_nf "findmnt_B.txt" findmnt -T /mnt/linuxia/DATA_1TB_B -o TARGET,SOURCE,FSTYPE,OPTIONS
capture_nf "findmnt_bind_A.txt" findmnt -T /srv/linuxia-share/DATA_1TB_A -o TARGET,SOURCE,FSTYPE,OPTIONS
capture_nf "findmnt_bind_B.txt" findmnt -T /srv/linuxia-share/DATA_1TB_B -o TARGET,SOURCE,FSTYPE,OPTIONS
capture_nf "df_mounts.txt" df -PT /mnt/linuxia/DATA_1TB_A /mnt/linuxia/DATA_1TB_B /srv/linuxia-share/DATA_1TB_A /srv/linuxia-share/DATA_1TB_B

# --- Services Samba (openSUSE: smb/nmb ; autres: smbd/nmbd) ---
for u in smb nmb smbd nmbd; do
  capture_nf "systemctl_is_active_${u}.txt" systemctl is-active "$u"
  capture_nf "systemctl_is_enabled_${u}.txt" systemctl is-enabled "$u"
  capture_nf "systemctl_status_${u}.txt" systemctl status "$u" --no-pager -l
done

# --- Samba config ---
capture_nf "testparm_s.txt" testparm -s

# --- smbclient (doc: utiliser /root/.smb-gaby) ---
CREDS="/root/.smb-gaby"
if [ -r "$CREDS" ]; then
  capture_nf "smbclient_list_localhost.txt" smbclient -L localhost -A "$CREDS"
  capture_nf "smbclient_ls_A.txt" smbclient //localhost/DATA_1TB_A -A "$CREDS" -c 'ls'
  capture_nf "smbclient_ls_B.txt" smbclient //localhost/DATA_1TB_B -A "$CREDS" -c 'ls'

  # Smoke test write/read/delete (doc: put /etc/hosts + del)
  capture_nf "smbclient_smoke_A.txt" smbclient //localhost/DATA_1TB_A -A "$CREDS" -c 'put /etc/hosts __smokeA.txt; ls __smokeA.txt; del __smokeA.txt'
  capture_nf "smbclient_smoke_B.txt" smbclient //localhost/DATA_1TB_B -A "$CREDS" -c 'put /etc/hosts __smokeB.txt; ls __smokeB.txt; del __smokeB.txt'
else
  python3 - <<'PY' >"$RAW_DIR/creds_missing.txt"
import json
print("Missing /root/.smb-gaby (required for non-interactive smbclient).")
PY
  chmod 600 "$RAW_DIR/creds_missing.txt" 2>/dev/null || true
  record "creds_missing.txt" "check /root/.smb-gaby" "$RAW_DIR/creds_missing.txt" 2
fi

# --- Optional AVC scan (si dispo) ---
if command -v ausearch >/dev/null 2>&1; then
  capture_nf "ausearch_avc_recent.txt" ausearch -m AVC -ts recent
fi

# --- Pointer + summary ---
EVDIR="$EVDIR" EXTDIR="$EXTDIR" RAW_DIR="$RAW_DIR" python3 - <<'PY' >"$POINTER"
import os, json
print(json.dumps({
  "session_evidence_dir": os.environ["EVDIR"],
  "external_used": os.environ["EXTDIR"],
  "raw_dir": os.environ["RAW_DIR"],
}, ensure_ascii=False, indent=2))
PY
record "external_pointer.json" "python3(pointer)" "$POINTER" 0

python3 - "$RAW_DIR" "$JSONL" <<'PY' >"$SUMMARY"
import json, sys, os
raw_dir = sys.argv[1]
jsonl = sys.argv[2]

def read_first(path):
  try:
    with open(path,'r',encoding='utf-8',errors='replace') as f:
      return f.read().strip()
  except Exception as e:
    return None

def tag_rc(tag):
  try:
    with open(jsonl,'r',encoding='utf-8') as f:
      for line in f:
        o=json.loads(line)
        if o.get("tag")==tag:
          last=o
    return last.get("rc") if 'last' in locals() else None
  except Exception:
    return None

getenforce = read_first(os.path.join(raw_dir,"getenforce.txt"))
getsebool = read_first(os.path.join(raw_dir,"getsebool.txt"))

active_smb = read_first(os.path.join(raw_dir,"systemctl_is_active_smb.txt"))
active_smbd = read_first(os.path.join(raw_dir,"systemctl_is_active_smbd.txt"))
active_nmb = read_first(os.path.join(raw_dir,"systemctl_is_active_nmb.txt"))
active_nmbd = read_first(os.path.join(raw_dir,"systemctl_is_active_nmbd.txt"))

summary = {
  "timestamp": __import__("datetime").datetime.now().isoformat(),
  "selinux": {
    "getenforce": getenforce,
    "samba_share_fusefs": ("samba_share_fusefs --> on" in (getsebool or "")),
    "samba_export_all_rw": ("samba_export_all_rw --> off" in (getsebool or "")),
  },
  "services": {
    "smb_or_smbd_active": (active_smb=="active") or (active_smbd=="active"),
    "nmb_or_nmbd_active": (active_nmb=="active") or (active_nmbd=="active"),
    "active_raw": {"smb": active_smb, "smbd": active_smbd, "nmb": active_nmb, "nmbd": active_nmbd},
  },
  "samba": {
    "testparm_ok": (tag_rc("testparm_s.txt")==0),
    "smbclient_list_ok": (tag_rc("smbclient_list_localhost.txt")==0) if tag_rc("creds_missing.txt") is None else False,
    "smoke_A_ok": (tag_rc("smbclient_smoke_A.txt")==0),
    "smoke_B_ok": (tag_rc("smbclient_smoke_B.txt")==0),
    "creds_present": (tag_rc("creds_missing.txt") is None),
  },
  "notes": [
    "Sur FUSE/ntfs-3g, la vérification SELinux la plus fiable passe par findmnt (OPTIONS) + absence d'AVC.",
  ],
}
print(json.dumps(summary, ensure_ascii=False, indent=2))
PY
record "summary.json" "python3(summary)" "$SUMMARY" 0

ln -sfn "$AUDIT" "$SESSION_DIR/evidence/03-samba_latest"
