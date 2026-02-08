#!/usr/bin/env bash
set -euo pipefail
umask 0077
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

command -v python3 >/dev/null 2>&1
command -v sha256sum >/dev/null 2>&1

SESSION_DIR="${1:?Usage: 02-audit-disks.sh <session_dir> [external_base_dir]}"
EXTERNAL_BASE="${2:-}"

SESSION_DIR="$(cd "$SESSION_DIR" && pwd -P)"
STAMP="$(date +%Y%m%d_%H%M%S)"
EVDIR="$SESSION_DIR/evidence/02-disks_${STAMP}"
mkdir -p "$EVDIR"

JSONL="$EVDIR/evidence.jsonl"
SUMMARY="$EVDIR/summary.json"
POINTER="$EVDIR/external_pointer.json"

EXTERNAL_USED=""
RAW_DIR="$EVDIR/raw"

if [ -n "$EXTERNAL_BASE" ] && [ -d "$EXTERNAL_BASE" ]; then
  EXTERNAL_USED="$EXTERNAL_BASE/02-disks_${STAMP}"
  RAW_DIR="$EXTERNAL_USED/raw"
  mkdir -p "$RAW_DIR"
  chmod 700 "$EXTERNAL_USED" "$RAW_DIR" 2>/dev/null || true
else
  mkdir -p "$RAW_DIR"
  chmod 700 "$RAW_DIR" 2>/dev/null || true
fi

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

capture() {
  local tag="$1"
  shift
  local out="$RAW_DIR/$tag"
  "$@" >"$out" 2>&1
  chmod 600 "$out" 2>/dev/null || true
  record "$tag" "$*" "$out" 0
}

capture_nf() {
  local tag="$1"
  shift
  local out="$RAW_DIR/$tag"
  set +e
  "$@" >"$out" 2>&1
  local rc="$?"
  set -e
  chmod 600 "$out" 2>/dev/null || true
  record "$tag" "$*" "$out" "$rc"
}

capture "lsblk.json" lsblk -J -o NAME,SIZE,FSTYPE,UUID,LABEL,MOUNTPOINTS
capture "blkid.txt" blkid
capture "findmnt.json" findmnt -J
capture "findmnt.txt" findmnt
capture "df_pt.txt" df -PT
capture "getenforce.txt" getenforce
capture "getsebool.txt" getsebool samba_share_fusefs samba_export_all_rw

python3 - <<'PY' >"$RAW_DIR/paths_check.json"
import os, json
paths = [
  "/mnt/linuxia/DATA_1TB_A",
  "/mnt/linuxia/DATA_1TB_B",
  "/srv/linuxia-share/DATA_1TB_A",
  "/srv/linuxia-share/DATA_1TB_B",
  "/srv/linuxia-share/DATA_1TB_A/LinuxIA_SMB",
  "/srv/linuxia-share/DATA_1TB_B/LinuxIA_SMB",
  "/opt/linuxia/data/shareA",
  "/opt/linuxia/data/shareB",
]
res = {}
for p in paths:
  res[p] = {
    "exists": os.path.exists(p),
    "is_dir": os.path.isdir(p),
    "is_mount": os.path.ismount(p),
  }
print(json.dumps(res, ensure_ascii=False, indent=2))
PY
record "paths_check.json" "python3(paths_check)" "$RAW_DIR/paths_check.json" 0

(
  set +e
  findmnt -T /mnt/linuxia/DATA_1TB_A -o TARGET,SOURCE,FSTYPE,OPTIONS
  findmnt -T /mnt/linuxia/DATA_1TB_B -o TARGET,SOURCE,FSTYPE,OPTIONS
  findmnt -T /srv/linuxia-share/DATA_1TB_A -o TARGET,SOURCE,FSTYPE,OPTIONS
  findmnt -T /srv/linuxia-share/DATA_1TB_B -o TARGET,SOURCE,FSTYPE,OPTIONS
  findmnt -T /opt/linuxia/data/shareA -o TARGET,SOURCE,FSTYPE,OPTIONS
  findmnt -T /opt/linuxia/data/shareB -o TARGET,SOURCE,FSTYPE,OPTIONS
) >"$RAW_DIR/mount_checks.txt" 2>&1
chmod 600 "$RAW_DIR/mount_checks.txt" 2>/dev/null || true
record "mount_checks.txt" "findmnt -T <targets> -o TARGET,SOURCE,FSTYPE,OPTIONS" "$RAW_DIR/mount_checks.txt" 0

capture_nf "fstab_linuxia_grep.txt" grep -nE 'LinuxIA:|/mnt/linuxia/DATA_1TB_|/srv/linuxia-share/DATA_1TB_|/opt/linuxia/data/share[AB]' /etc/fstab
capture_nf "selinux_lsZ_mountpoints.txt" ls -Zd /mnt/linuxia/DATA_1TB_A /mnt/linuxia/DATA_1TB_B /srv/linuxia-share/DATA_1TB_A /srv/linuxia-share/DATA_1TB_B /opt/linuxia/data/shareA /opt/linuxia/data/shareB

python3 - <<'PY' >"$RAW_DIR/statfs.json"
import os, json
targets = [
  "/mnt/linuxia/DATA_1TB_A",
  "/mnt/linuxia/DATA_1TB_B",
  "/srv/linuxia-share/DATA_1TB_A",
  "/srv/linuxia-share/DATA_1TB_B",
  "/opt/linuxia/data/shareA",
  "/opt/linuxia/data/shareB",
]
out = []
for p in targets:
  try:
    st = os.statvfs(p)
    out.append({
      "path": p,
      "ok": True,
      "f_bsize": st.f_bsize,
      "f_frsize": st.f_frsize,
      "f_blocks": st.f_blocks,
      "f_bfree": st.f_bfree,
      "f_bavail": st.f_bavail,
    })
  except Exception as e:
    out.append({"path": p, "ok": False, "error": str(e)})
print(json.dumps(out, ensure_ascii=False, indent=2))
PY
record "statfs.json" "python3(statvfs)" "$RAW_DIR/statfs.json" 0

EVDIR="$EVDIR" EXTERNAL_USED="$EXTERNAL_USED" RAW_DIR="$RAW_DIR" python3 - <<'PY' >"$POINTER"
import os, json
ext = os.environ.get("EXTERNAL_USED") or None
print(json.dumps({
  "session_evidence_dir": os.environ.get("EVDIR"),
  "external_used": ext,
  "raw_dir": os.environ.get("RAW_DIR"),
}, ensure_ascii=False, indent=2))
PY
record "external_pointer.json" "python3(pointer)" "$POINTER" 0

EVDIR="$EVDIR" EXTERNAL_USED="$EXTERNAL_USED" RAW_DIR="$RAW_DIR" python3 - <<'PY' >"$SUMMARY"
import os, json, datetime
ext = os.environ.get("EXTERNAL_USED") or None
summary = {
  "timestamp": datetime.datetime.now().isoformat(),
  "session_evidence_dir": os.environ.get("EVDIR"),
  "external_used": ext,
  "raw_dir": os.environ.get("RAW_DIR"),
  "notes": [
    "Validation SELinux fiable via findmnt (OPTIONS) sur FUSE/ntfs-3g; ls -Z peut afficher ?.",
  ],
}
print(json.dumps(summary, ensure_ascii=False, indent=2))
PY
record "summary.json" "python3(summary)" "$SUMMARY" 0

ln -sfn "02-disks_${STAMP}" "$SESSION_DIR/evidence/02-disks_latest"
