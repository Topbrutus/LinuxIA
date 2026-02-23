#!/usr/bin/env bash
# Title: append_verify_disks_result.sh
# Description: Ajoute un bloc YAML "verify_disks_result" (calculé depuis l’état réel) à la preuve la plus récente verify_remote_mounts_*.txt, et écrit le drapeau de fin dans la preuve.
# Date: 2026-02-09
# Version: 0.99
# Usage: /opt/linuxia/scripts/append_verify_disks_result.sh [--evidence /path/file.txt] [--snapshot /opt/linuxia/docs/PRODUCTION.snapshot.md] [--target-machine vm100-factory]
# Bash version: 5.1+
# Notes: Ne “triche” pas: lit des fichiers existants + exécute lsblk/findmnt/df/find. Ajoute aussi ### SCRIPT_COMPLETED_FLAG=OK ### si absent.

set -euo pipefail;
IFS=$'\n\t';

declare -r BaseDir="/opt/linuxia";
declare -r VerifDir="${BaseDir}/docs/verifications";
declare -r DefaultSnapshot="${BaseDir}/docs/PRODUCTION.snapshot.md";

declare ScriptName TimeStampUtc TimeStampLocal
ScriptName="$(basename "${BASH_SOURCE[0]}")"
TimeStampUtc="$(date -u +%Y%m%dT%H%M%SZ)"
TimeStampLocal="$(date -Is)"
declare -r ScriptName TimeStampUtc TimeStampLocal

declare -r LockDir="/run/lock/${ScriptName}.lock.d";
declare -r LockDirFallback="/tmp/${ScriptName}.lock.d";

declare EvidencePath="";
declare SnapshotPath="${DefaultSnapshot}";
declare TargetMachine="vm100-factory";

declare RunUser="";
declare MediaRoot="";

declare SnapshotExists="❌";
declare DisquesReadable="❌";
declare MontagesReadable="❌";

declare LsblkOk="❌";
declare FindmntOk="❌";
declare SnapshotMatchesReality="❌";
declare MismatchNote="";

declare AuditTrailExists="❌";
declare AuditTrailLocation="not found";
declare AuditTrailReco="Plan for next session";

declare MntLinuxiaFreeGb="N/A";
declare SrvLinuxiaShareFreeGb="N/A";
declare DiskStatus="N/A";

declare Issues="";
declare NextAction="";

declare -i ReturnCode=0;

function cleanup() {
  if [[ -d "${LockDir}" ]];
  then
    rmdir "${LockDir}" 2>/dev/null || true;
  fi;

  if [[ -d "${LockDirFallback}" ]];
  then
    rmdir "${LockDirFallback}" 2>/dev/null || true;
  fi;
}

function acquire_lock() {
  if mkdir "${LockDir}" 2>/dev/null;
  then
    trap cleanup EXIT INT TERM;
    return 0;
  fi;

  if mkdir "${LockDirFallback}" 2>/dev/null;
  then
    trap cleanup EXIT INT TERM;
    return 0;
  fi;

  printf '%s\n' "ERROR: Lock exists (${LockDir} or ${LockDirFallback}).";
  exit 1;
}

function have_cmd() {
  declare Cmd="${1}";
  if command -v "${Cmd}" >/dev/null 2>&1;
  then
    return 0;
  fi;
  return 1;
}

function add_issue() {
  declare Msg="${1}";
  if [[ -z "${Issues}" ]];
  then
    Issues="${Msg}";
  else
    Issues="${Issues}; ${Msg}";
  fi;
  ReturnCode=1;
}

function parse_args() {
  declare Arg="";
  while [[ $# -gt 0 ]];
  do
    Arg="${1}";
    case "${Arg}" in
      --evidence)
        EvidencePath="${2:-}";
        shift 2;
        ;;
      --snapshot)
        SnapshotPath="${2:-}";
        shift 2;
        ;;
      --target-machine)
        TargetMachine="${2:-}";
        shift 2;
        ;;
      -h|--help)
        printf '%s\n' "Usage: ${ScriptName} [--evidence /path/file.txt] [--snapshot /path/PRODUCTION.snapshot.md] [--target-machine vm100-factory]";
        exit 0;
        ;;
      *)
        printf '%s\n' "ERROR: Unknown arg: ${Arg}";
        exit 1;
        ;;
    esac;
  done;
}

function resolve_evidence_path() {
  if [[ -n "${EvidencePath}" ]];
  then
    return 0;
  fi;

  EvidencePath="$(ls -1t "${VerifDir}"/verify_remote_mounts_*.txt 2>/dev/null | head -n 1 || true)";
  if [[ -z "${EvidencePath}" ]];
  then
    printf '%s\n' "ERROR: No evidence file found in ${VerifDir} (verify_remote_mounts_*.txt).";
    exit 1;
  fi;
}

function snapshot_checks() {
  declare DisquesBlock="";
  declare MontagesBlock="";

  if [[ -f "${SnapshotPath}" ]];
  then
    SnapshotExists="✅";

    DisquesBlock="$(awk 'BEGIN{p=0} /^## Disques \\/ Partitions/{p=1} p{print} /^## Montages/{exit}' "${SnapshotPath}" 2>/dev/null || true)";
    MontagesBlock="$(awk 'BEGIN{p=0} /^## Montages/{p=1} p{print} /^## Samba/{exit}' "${SnapshotPath}" 2>/dev/null || true)";

    if [[ -n "${DisquesBlock}" && "${DisquesBlock}" != "## Disques / Partitions"*$'\n' ]];
    then
      DisquesReadable="✅";
    else
      add_issue "snapshot_disques_section_unreadable";
    fi;

    if [[ -n "${MontagesBlock}" && "${MontagesBlock}" != "## Montages"*$'\n' ]];
    then
      MontagesReadable="✅";
    else
      add_issue "snapshot_montages_section_unreadable";
    fi;
  else
    add_issue "snapshot_missing";
  fi;
}

function reality_checks() {
  if lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,MODEL,SERIAL >/dev/null 2>&1;
  then
    LsblkOk="✅";
  else
    add_issue "lsblk_failed";
  fi;

  if findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS >/dev/null 2>&1;
  then
    FindmntOk="✅";
  else
    add_issue "findmnt_failed";
  fi;
}

function compare_snapshot_vs_reality() {
  declare SnapMountsTmp="";
  declare RealMountsTmp="";
  declare MissingTmp="";
  declare ExtraTmp="";
  declare MissingCount="0";
  declare ExtraCount="0";

  if [[ "${SnapshotExists}" != "✅" ]];
  then
    SnapshotMatchesReality="❌";
    return 0;
  fi;

  SnapMountsTmp="$(mktemp -p /tmp "snap_mounts_${TimeStampUtc}_XXXXXX.txt")";
  RealMountsTmp="$(mktemp -p /tmp "real_mounts_${TimeStampUtc}_XXXXXX.txt")";
  MissingTmp="$(mktemp -p /tmp "missing_mounts_${TimeStampUtc}_XXXXXX.txt")";
  ExtraTmp="$(mktemp -p /tmp "extra_mounts_${TimeStampUtc}_XXXXXX.txt")";

  awk 'BEGIN{p=0} /^## Montages/{p=1; next} /^## Samba/{exit} p{print}' "${SnapshotPath}" 2>/dev/null | \
    awk '$1 ~ /^\// {print $1}' | sort -u > "${SnapMountsTmp}" || true;

  findmnt -rno TARGET 2>/dev/null | sort -u > "${RealMountsTmp}" || true;

  comm -23 "${SnapMountsTmp}" "${RealMountsTmp}" > "${MissingTmp}" || true;
  comm -13 "${SnapMountsTmp}" "${RealMountsTmp}" > "${ExtraTmp}" || true;

  MissingCount="$(wc -l < "${MissingTmp}" 2>/dev/null || echo 0)";
  ExtraCount="$(wc -l < "${ExtraTmp}" 2>/dev/null || echo 0)";

  if [[ "${MissingCount}" -eq 0 && "${ExtraCount}" -eq 0 ]];
  then
    SnapshotMatchesReality="✅";
    MismatchNote="no mismatches";
  else
    SnapshotMatchesReality="⚠️ mismatches";
    MismatchNote="missing_from_reality=${MissingCount}, extra_in_reality=${ExtraCount}";
    add_issue "snapshot_reality_mismatch(${MismatchNote})";
  fi;

  rm -f -- "${SnapMountsTmp}" "${RealMountsTmp}" "${MissingTmp}" "${ExtraTmp}" 2>/dev/null || true;
}

function audit_trail_check() {
  declare FoundPath="";

  RunUser="${SUDO_USER:-${USER}}";
  MediaRoot="/run/media/${RunUser}";

  if [[ -d "${MediaRoot}" ]];
  then
    FoundPath="$(find "${MediaRoot}" -type d -path "*/linuxia_audit_trail/vm100" 2>/dev/null | head -n 1 || true)";
  fi;

  if [[ -n "${FoundPath}" ]];
  then
    AuditTrailExists="✅";
    AuditTrailLocation="${FoundPath}";
    AuditTrailReco="Use existing";
  else
    AuditTrailReco="Create / Use existing / Plan for next session";
    add_issue "audit_trail_not_found";
  fi;
}

function df_free_gb() {
  declare MountPoint="${1}";
  declare AvailKb="";

  if df -P --output=avail "${MountPoint}" >/dev/null 2>&1;
  then
    AvailKb="$(df -P --output=avail "${MountPoint}" 2>/dev/null | awk 'NR==2{print $1}' || true)";
    if [[ -n "${AvailKb}" ]];
    then
      awk -v k="${AvailKb}" 'BEGIN{printf "%.1f", (k/1024/1024)}';
      return 0;
    fi;
  fi;

  printf '%s' "N/A";
}

function df_used_pct() {
  declare MountPoint="${1}";
  declare Pct="";

  if df -P --output=pcent "${MountPoint}" >/dev/null 2>&1;
  then
    Pct="$(df -P --output=pcent "${MountPoint}" 2>/dev/null | awk 'NR==2{gsub(/%/,""); print $1}' || true)";
    if [[ -n "${Pct}" ]];
    then
      printf '%s' "${Pct}";
      return 0;
    fi;
  fi;

  printf '%s' "";
}

function disk_space_check() {
  declare MntPct="";
  declare SrvPct="";
  declare -i WorstPct=0;

  MntLinuxiaFreeGb="$(df_free_gb "/mnt/linuxia")";
  SrvLinuxiaShareFreeGb="$(df_free_gb "/srv/linuxia-share")";

  MntPct="$(df_used_pct "/mnt/linuxia")";
  SrvPct="$(df_used_pct "/srv/linuxia-share")";

  WorstPct=0;
  if [[ -n "${MntPct}" && "${MntPct}" =~ ^[0-9]+$ ]];
  then
    if [[ "${MntPct}" -gt "${WorstPct}" ]];
    then
      WorstPct="${MntPct}";
    fi;
  fi;

  if [[ -n "${SrvPct}" && "${SrvPct}" =~ ^[0-9]+$ ]];
  then
    if [[ "${SrvPct}" -gt "${WorstPct}" ]];
    then
      WorstPct="${SrvPct}";
    fi;
  fi;

  if [[ "${WorstPct}" -ge 90 ]];
  then
    DiskStatus="❌ critical";
    add_issue "disk_usage_critical(${WorstPct}%)";
  elif [[ "${WorstPct}" -ge 80 ]];
  then
    DiskStatus="⚠️ warning (>80%)";
    add_issue "disk_usage_warning(${WorstPct}%)";
  else
    DiskStatus="✅ sufficient";
  fi;
}

function choose_next_action() {
  if [[ "${SnapshotExists}" != "✅" ]];
  then
    NextAction="Generate docs/PRODUCTION.snapshot.md then rerun verification";
    return 0;
  fi;

  if [[ "${AuditTrailExists}" != "✅" ]];
  then
    NextAction="Mount external media and create linuxia_audit_trail/vm100 for audit trail";
    return 0;
  fi;

  if [[ "${DiskStatus}" == "⚠️ warning (>80%)" || "${DiskStatus}" == "❌ critical" ]];
  then
    NextAction="Free disk space on the reported mount(s) then re-run checkpoint";
    return 0;
  fi;

  NextAction="Proceed to next checkpoint (e.g., Samba health audit) with evidence saved";
}

function append_to_evidence() {
  declare DoneFlag="### SCRIPT_COMPLETED_FLAG=OK ###";
  declare DateShort="";

  DateShort="$(date +%Y-%m-%d)";

  {
    printf '\n%s\n' "=== VERIFY_DISKS_RESULT (auto) ===";
    printf '%s\n' "Timestamp: ${TimeStampLocal}";
    printf '%s\n' "Host: $(hostname -s 2>/dev/null || hostname)";

    printf '\n%s\n' "--- REALITY: lsblk ---";
    lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,MODEL,SERIAL 2>/dev/null || true;

    printf '\n%s\n' "--- REALITY: findmnt ---";
    findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null || true;

    printf '\n%s\n' "--- EXTERNAL MEDIA ---";
    ls -la "/run/media/${RunUser}" 2>/dev/null || true;

    printf '\n%s\n' "--- AUDIT TRAIL LOOKUP ---";
    if [[ -d "/run/media/${RunUser}" ]];
    then
      find "/run/media/${RunUser}" -type d -path "*/linuxia_audit_trail/vm100" 2>/dev/null | head -n 10 || true;
    fi;

    printf '\n%s\n' "--- DISK SPACE ---";
    df -hT /mnt/linuxia 2>/dev/null || true;
    df -hT /srv/linuxia-share 2>/dev/null || true;

    printf '\n%s\n' "verify_disks_result:";
    printf '%s\n' "  date: \"${DateShort}\"";
    printf '%s\n' "  machine: \"${TargetMachine}\"";
    printf '%s\n' "";
    printf '%s\n' "  snapshot_status:";
    printf '%s\n' "    file_exists: \"${SnapshotExists}\"";
    printf '%s\n' "    disques_section_readable: \"${DisquesReadable}\"";
    printf '%s\n' "    montages_section_readable: \"${MontagesReadable}\"";
    printf '%s\n' "";
    printf '%s\n' "  reality_check:";
    printf '%s\n' "    lsblk_ok: \"${LsblkOk}\"";
    printf '%s\n' "    findmnt_ok: \"${FindmntOk}\"";
    if [[ -n "${MismatchNote}" ]];
    then
      printf '%s\n' "    snapshot_matches_reality: \"${SnapshotMatchesReality} (${MismatchNote})\"";
    else
      printf '%s\n' "    snapshot_matches_reality: \"${SnapshotMatchesReality}\"";
    fi;
    printf '%s\n' "";
    printf '%s\n' "  audit_trail:";
    printf '%s\n' "    path_exists: \"${AuditTrailExists}\"";
    printf '%s\n' "    location_found: \"${AuditTrailLocation}\"";
    printf '%s\n' "    recommendation: \"${AuditTrailReco}\"";
    printf '%s\n' "";
    printf '%s\n' "  disk_space:";
    printf '%s\n' "    mnt_linuxia_free: \"${MntLinuxiaFreeGb} GB\"";
    printf '%s\n' "    srv_linuxia_share_free: \"${SrvLinuxiaShareFreeGb} GB\"";
    printf '%s\n' "    status: \"${DiskStatus}\"";
    printf '%s\n' "";
    if [[ -z "${Issues}" ]];
    then
      printf '%s\n' "  issues: \"none\"";
    else
      printf '%s\n' "  issues: \"${Issues}\"";
    fi;
    printf '%s\n' "  next_action: \"${NextAction}\"";
    printf '\n%s\n' "=== END VERIFY_DISKS_RESULT (auto) ===";

    if ! grep -Fq "${DoneFlag}" "${EvidencePath}" 2>/dev/null;
    then
      printf '%s\n' "${DoneFlag}";
    fi;
  } >> "${EvidencePath}";
}

function main() {
  acquire_lock;
  parse_args "$@";
  resolve_evidence_path;

  if [[ ! -f "${EvidencePath}" ]];
  then
    printf '%s\n' "ERROR: Evidence file not found: ${EvidencePath}";
    exit 1;
  fi;

  RunUser="${SUDO_USER:-${USER}}";

  snapshot_checks;
  reality_checks;
  compare_snapshot_vs_reality;
  audit_trail_check;
  disk_space_check;
  choose_next_action;

  append_to_evidence;

  printf '%s\n' "Updated evidence: ${EvidencePath}";

  if [[ "${ReturnCode}" -eq 0 ]];
  then
    exit 0;
  fi;

  exit 1;
}

main "$@";
