#!/usr/bin/env bash
# Title: 01-verify-disks-mounts-vm100.sh
# Description: Vérifie cohérence snapshot vs état réel (lsblk/findmnt), statut des 4 montages (open/closed), et présence audit trail externe. Génère une preuve dans docs/verifications/ + un résumé YAML.
# Date: 2026-02-08
# Version: 0.99
# Usage: /opt/linuxia/scripts/01-verify-disks-mounts-vm100.sh --snapshot /opt/linuxia/docs/PRODUCTION.snapshot.md [--force]
# Bash version: 5.1+
# Notes: Lecture seule système (aucune modification). Anti-fausse preuve (VM100 only) sauf --force. Ne lance jamais sudo.

set -euo pipefail;
IFS=$'\n\t';

declare -r BaseDir="/opt/linuxia";
declare -r DocsDir="${BaseDir}/docs";
declare -r VerifDir="${DocsDir}/verifications";

declare ExpectedHost="vm100-factory";
declare ExpectedPrefix="vm100";
declare SnapshotPath="${DocsDir}/PRODUCTION.snapshot.md";
declare ForceRun="false";

declare ScriptName TimeStampUtc TimeStampLocal
ScriptName="$(basename "${BASH_SOURCE[0]}")"
TimeStampUtc="$(date -u +%Y%m%dT%H%M%SZ)"
TimeStampLocal="$(date -Is)"
declare -r ScriptName TimeStampUtc TimeStampLocal
declare EvidencePath="";

declare HostShort="";
declare HostFqdn="";

declare SnapshotExists="❌";
declare SnapshotDisksReadable="❌";
declare SnapshotMountsReadable="❌";

declare LsblkOk="❌";
declare FindmntOk="❌";
declare SnapshotMatchesReality="⚠️ mismatches";

declare AuditTrailPathExists="❌";
declare AuditTrailLocationFound="not found";
declare AuditTrailRecommendation="Plan for next session";

declare MntLinuxiaFree="unknown";
declare SrvLinuxiaShareFree="unknown";
declare DiskSpaceStatus="✅ sufficient";

declare -a Issues=();
declare -i ReturnCode=0;

declare -a MountTargets=("/opt/linuxia/data/shareA" "/opt/linuxia/data/shareB" "/srv/linuxia-share/DATA_1TB_A" "/srv/linuxia-share/DATA_1TB_B");
declare -a MountStates=();

function cleanup() {
  declare -r LockDir="/tmp/${ScriptName}.lock.d";
  if [[ -d "${LockDir}" ]];
  then
    rmdir "${LockDir}" 2>/dev/null || true;
  fi;
}

function acquire_lock() {
  declare -r LockDir="/tmp/${ScriptName}.lock.d";
  if ! mkdir "${LockDir}" 2>/dev/null;
  then
    printf '%s\n' "ERROR: Lock exists (${LockDir}).";
    exit 1;
  fi;
  trap cleanup EXIT INT TERM;
}

function add_issue() {
  declare Msg="${1}";
  Issues+=("${Msg}");
  ReturnCode=1;
}

function parse_args() {
  declare Arg="";
  while [[ $# -gt 0 ]];
  do
    Arg="${1}";
    case "${Arg}" in
      --snapshot)
        SnapshotPath="${2:-}";
        shift 2;
        ;;
      --expected-host)
        ExpectedHost="${2:-}";
        shift 2;
        ;;
      --expected-prefix)
        ExpectedPrefix="${2:-}";
        shift 2;
        ;;
      --force)
        ForceRun="true";
        shift 1;
        ;;
      -h|--help)
        printf '%s\n' "Usage: ${ScriptName} --snapshot <file> [--force]";
        exit 0;
        ;;
      *)
        printf '%s\n' "ERROR: Unknown arg: ${Arg}";
        exit 1;
        ;;
    esac;
  done;
}

function detect_host() {
  HostShort="$(hostname -s 2>/dev/null || hostname)";
  HostFqdn="$(hostname -f 2>/dev/null || true)";
}

function refuse_if_not_vm100() {
  if [[ "${ForceRun}" == "true" ]];
  then
    add_issue "FORCE enabled: anti-fausse preuve disabled";
    return 0;
  fi;

  if [[ "${HostShort}" == "${ExpectedHost}" ]];
  then
    return 0;
  fi;

  if [[ -n "${ExpectedPrefix}" && "${HostShort}" == "${ExpectedPrefix}"* ]];
  then
    return 0;
  fi;

  printf '%s\n' "ERROR: Anti-fausse preuve: VM100 only. Host=${HostShort} fqdn=${HostFqdn:-N/A}";
  exit 1;
}

function section() {
  declare Title="${1}";
  printf '\n%s\n' "=== ${Title} ===";
}

function snapshot_extract() {
  section "SNAPSHOT";
  if [[ -f "${SnapshotPath}" ]];
  then
    SnapshotExists="✅";

    if grep -qE '^##[[:space:]]+Disques[[:space:]]+/[[:space:]]+Partitions' "${SnapshotPath}" 2>/dev/null;
    then
      SnapshotDisksReadable="✅";
      printf '%s\n' "--- Disques / Partitions (extrait) ---";
      awk 'BEGIN{p=0} /^## Disques \/ Partitions/{p=1} p{print} /^## Montages/{exit}' "${SnapshotPath}" | sed -n '1,200p';
    else
      add_issue "Snapshot: section 'Disques / Partitions' introuvable";
    fi;

    if grep -qE '^##[[:space:]]+Montages' "${SnapshotPath}" 2>/dev/null;
    then
      SnapshotMountsReadable="✅";
      printf '%s\n' "--- Montages (extrait) ---";
      awk 'BEGIN{p=0} /^## Montages/{p=1} p{print} /^## /{if(seen++){exit}}' "${SnapshotPath}" | sed -n '1,200p';
    else
      add_issue "Snapshot: section 'Montages' introuvable";
    fi;
  else
    add_issue "Snapshot: fichier absent (${SnapshotPath})";
  fi;
}

function reality_lsblk_findmnt() {
  section "REALITY (lsblk)";
  if command -v lsblk >/dev/null 2>&1;
  then
    LsblkOk="✅";
    lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,MODEL,SERIAL 2>/dev/null || true;
  else
    add_issue "lsblk not found";
  fi;

  section "REALITY (findmnt)";
  if command -v findmnt >/dev/null 2>&1;
  then
    FindmntOk="✅";
    findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null || true;
  else
    add_issue "findmnt not found";
  fi;
}

function check_mounts_open_closed() {
  section "4 mounts status (open/closed)";
  declare Target="";
  declare Line="";

  MountStates=();
  for Target in "${MountTargets[@]}";
  do
    Line="$(findmnt -T "${Target}" -rno TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null || true)";
    if [[ -n "${Line}" ]];
    then
      MountStates+=("${Target}: ✅ open");
      printf '%s\n' "${Target}: ${Line}";
    else
      MountStates+=("${Target}: ❌ closed");
      add_issue "Mount target not mounted: ${Target}";
      printf '%s\n' "${Target}: NOT MOUNTED";
    fi;
  done;
}

function compare_snapshot_best_effort() {
  section "SNAPSHOT vs REALITY (best effort)";
  if [[ "${SnapshotExists}" != "✅" ]];
  then
    SnapshotMatchesReality="⚠️ mismatches";
    printf '%s\n' "Snapshot absent: comparaison impossible.";
    return 0;
  fi;

  declare Missing=0;
  declare Dev="";

  mapfile -t Devs < <(
    awk 'BEGIN{p=0} /^## Disques \/ Partitions/{p=1} p{print} /^## Montages/{exit}' "${SnapshotPath}" 2>/dev/null \
      | grep -Eo '(/dev/sd[a-z][0-9]+)' 2>/dev/null | sort -u
  );

  for Dev in "${Devs[@]:-}";
  do
    if [[ -n "${Dev}" ]];
    then
      if ! lsblk -nr "${Dev}" >/dev/null 2>&1;
      then
        Missing=$((Missing + 1));
        add_issue "Snapshot device missing in reality: ${Dev}";
      fi;
    fi;
  done;

  if [[ "${Missing}" -eq 0 ]];
  then
    SnapshotMatchesReality="✅";
    printf '%s\n' "OK: rien de manquant côté /dev (best effort).";
  else
    SnapshotMatchesReality="⚠️ mismatches";
    printf '%s\n' "MISMATCH: voir Issues.";
  fi;
}

function check_audit_trail() {
  section "AUDIT TRAIL (external media)";
  declare Path="";
  declare Found="false";

  ls -la /run/media/gaby 2>/dev/null || true;

  shopt -s nullglob;
  for Path in /run/media/gaby/*/linuxia_audit_trail/vm100;
  do
    if [[ -d "${Path}" ]];
    then
      Found="true";
      AuditTrailPathExists="✅";
      AuditTrailLocationFound="${Path}";
      AuditTrailRecommendation="Use existing";
      printf '%s\n' "Found: ${Path}";
      ls -la "${Path}" 2>/dev/null || true;
      break;
    fi;
  done;
  shopt -u nullglob;

  if [[ "${Found}" != "true" ]];
  then
    add_issue "Audit trail path not found under /run/media/gaby/*/linuxia_audit_trail/vm100";
    AuditTrailRecommendation="Create";
  fi;
}

function check_disk_space() {
  section "DISK SPACE";
  declare Pct="";
  declare Avail="";

  if command -v df >/dev/null 2>&1;
  then
    if [[ -d /mnt/linuxia ]];
    then
      Avail="$(df -h --output=avail /mnt/linuxia 2>/dev/null | tail -1 | tr -d ' ')";
      Pct="$(df --output=pcent /mnt/linuxia 2>/dev/null | tail -1 | tr -d ' %')";
      MntLinuxiaFree="${Avail:-unknown}";
      if [[ -n "${Pct}" && "${Pct}" -ge 95 ]];
      then
        DiskSpaceStatus="❌ critical";
        add_issue "/mnt/linuxia usage critical: ${Pct}%";
      elif [[ -n "${Pct}" && "${Pct}" -ge 80 ]];
      then
        DiskSpaceStatus="⚠️ warning (>80%)";
        add_issue "/mnt/linuxia usage high: ${Pct}%";
      fi;
    fi;

    if [[ -d /srv/linuxia-share ]];
    then
      Avail="$(df -h --output=avail /srv/linuxia-share 2>/dev/null | tail -1 | tr -d ' ')";
      Pct="$(df --output=pcent /srv/linuxia-share 2>/dev/null | tail -1 | tr -d ' %')";
      SrvLinuxiaShareFree="${Avail:-unknown}";
      if [[ -n "${Pct}" && "${Pct}" -ge 95 ]];
      then
        DiskSpaceStatus="❌ critical";
        add_issue "/srv/linuxia-share usage critical: ${Pct}%";
      elif [[ -n "${Pct}" && "${Pct}" -ge 80 ]];
      then
        DiskSpaceStatus="⚠️ warning (>80%)";
        add_issue "/srv/linuxia-share usage high: ${Pct}%";
      fi;
    fi;
  fi;
}

function yaml_summary() {
  section "YAML SUMMARY";
  printf '%s\n' "verify_disks_result:";
  printf '%s\n' "  date: \"${TimeStampLocal}\"";
  printf '%s\n' "  machine: \"${HostShort}\"";
  printf '%s\n' "  snapshot_status:";
  printf '%s\n' "    file_exists: \"${SnapshotExists}\"";
  printf '%s\n' "    disques_section_readable: \"${SnapshotDisksReadable}\"";
  printf '%s\n' "    montages_section_readable: \"${SnapshotMountsReadable}\"";
  printf '%s\n' "  reality_check:";
  printf '%s\n' "    lsblk_ok: \"${LsblkOk}\"";
  printf '%s\n' "    findmnt_ok: \"${FindmntOk}\"";
  printf '%s\n' "    snapshot_matches_reality: \"${SnapshotMatchesReality}\"";
  printf '%s\n' "  mounts_open_closed:";
  printf '%s\n' "    - \"${MountStates[0]:-}\"";
  printf '%s\n' "    - \"${MountStates[1]:-}\"";
  printf '%s\n' "    - \"${MountStates[2]:-}\"";
  printf '%s\n' "    - \"${MountStates[3]:-}\"";
  printf '%s\n' "  audit_trail:";
  printf '%s\n' "    path_exists: \"${AuditTrailPathExists}\"";
  printf '%s\n' "    location_found: \"${AuditTrailLocationFound}\"";
  printf '%s\n' "    recommendation: \"${AuditTrailRecommendation}\"";
  printf '%s\n' "  disk_space:";
  printf '%s\n' "    mnt_linuxia_free: \"${MntLinuxiaFree}\"";
  printf '%s\n' "    srv_linuxia_share_free: \"${SrvLinuxiaShareFree}\"";
  printf '%s\n' "    status: \"${DiskSpaceStatus}\"";
  printf '%s\n' "  issues: |";
  if [[ "${#Issues[@]}" -eq 0 ]];
  then
    printf '%s\n' "    none";
  else
    declare Msg="";
    for Msg in "${Issues[@]}";
    do
      printf '%s\n' "    - ${Msg}";
    done;
  fi;
}

function main() {
  acquire_lock;
  parse_args "$@";
  cd "${BaseDir}";

  detect_host;
  refuse_if_not_vm100;

  mkdir -p "${VerifDir}";
  EvidencePath="${VerifDir}/verify_disks_mounts_vm100_${TimeStampUtc}.txt";

  {
    printf '%s\n' "=== VERIFY DISKS + MOUNTS + AUDIT TRAIL (VM100) ===";
    printf '%s\n' "Timestamp(local): ${TimeStampLocal}";
    printf '%s\n' "Timestamp(UTC):   $(date -u -Is)";
    printf '%s\n' "Host:             ${HostShort} (fqdn: ${HostFqdn:-N/A})";
    printf '%s\n' "Snapshot file:    ${SnapshotPath}";
    printf '\n';

    snapshot_extract;
    reality_lsblk_findmnt;
    check_mounts_open_closed;
    compare_snapshot_best_effort;
    check_audit_trail;
    check_disk_space;
    yaml_summary;
    printf '\n%s\n' "=== END ===";
  } | tee "${EvidencePath}";

  printf '\n%s\n' "Evidence saved: ${EvidencePath}";
  exit "${ReturnCode}";
}

main "$@";
