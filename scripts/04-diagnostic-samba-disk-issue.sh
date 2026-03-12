#!/usr/bin/env bash
# Title: 04-diagnostic-samba-disk-issue.sh
# Description: Diagnostic complet d'un problème de disque Samba (partition resize/block move). Analyse partitions, filesystem NTFS, montages, logs système. Mode lecture seule.
# Date: 2026-03-12
# Version: 1.0
# Usage: sudo /opt/linuxia/scripts/04-diagnostic-samba-disk-issue.sh [--force] [--no-git]
# Bash version: 5.1+
# Notes: Lecture seule. Anti-fausse preuve (VM100 only). Génère rapport dans docs/verifications/ + evidence dans sessions/20260312_samba-disk-diagnostic/evidence/

set -euo pipefail
IFS=$'\n\t'

declare -r BaseDir="/opt/linuxia"
declare -r DocsDir="${BaseDir}/docs"
declare -r VerifDir="${DocsDir}/verifications"
declare -r SessionDir="${BaseDir}/sessions/20260312_samba-disk-diagnostic"
declare -r EvidenceDir="${SessionDir}/evidence"

declare ScriptName TimeStampUtc TimeStampLocal
ScriptName="$(basename "${BASH_SOURCE[0]}")"
TimeStampUtc="$(date -u +%Y%m%dT%H%M%SZ)"
TimeStampLocal="$(date -Is)"
declare -r ScriptName TimeStampUtc TimeStampLocal

declare ExpectedHost="vm100-factory"
declare ExpectedPrefix="vm100"
declare ForceRun="false"
declare NoGit="false"

declare -i ReturnCode=0
declare HostShort=""
declare HostFqdn=""
declare EvidencePath=""

declare -a Issues=()
declare -a Warnings=()

function cleanup() {
  declare -r LockDir="/tmp/${ScriptName}.lock.d"
  if [[ -d "${LockDir}" ]]; then
    rmdir "${LockDir}" 2>/dev/null || true
  fi
}

function acquire_lock() {
  declare -r LockDir="/tmp/${ScriptName}.lock.d"
  if ! mkdir "${LockDir}" 2>/dev/null; then
    printf '%s\n' "ERROR: Lock exists (${LockDir}). Another run in progress."
    exit 1
  fi
  trap cleanup EXIT INT TERM
}

function add_issue() {
  declare Msg="${1}"
  Issues+=("${Msg}")
  ReturnCode=1
}

function add_warning() {
  declare Msg="${1}"
  Warnings+=("${Msg}")
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --force)
        ForceRun="true"
        shift
        ;;
      --no-git)
        NoGit="true"
        shift
        ;;
      -h|--help)
        printf '%s\n' "Usage: ${ScriptName} [--force] [--no-git]"
        exit 0
        ;;
      *)
        printf '%s\n' "ERROR: Unknown arg: ${1}"
        exit 1
        ;;
    esac
  done
}

function require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    printf '%s\n' "ERROR: Must run as root (or via sudo)."
    exit 1
  fi
}

function detect_host() {
  HostShort="$(hostname -s 2>/dev/null || hostname)"
  HostFqdn="$(hostname -f 2>/dev/null || true)"
}

function refuse_if_not_vm100() {
  if [[ "${ForceRun}" == "true" ]]; then
    add_warning "FORCE enabled: anti-fausse preuve disabled"
    return 0
  fi

  if [[ "${HostShort}" == "${ExpectedHost}" ]]; then
    return 0
  fi

  if [[ -n "${ExpectedPrefix}" && "${HostShort}" == "${ExpectedPrefix}"* ]]; then
    return 0
  fi

  printf '%s\n' "ERROR: Anti-fausse preuve: VM100 only."
  printf '%s\n' "       Host: ${HostShort} (fqdn: ${HostFqdn:-N/A})"
  exit 1
}

function section() {
  declare Title="${1}"
  printf '\n%s\n' "=== ${Title} ==="
}

function run_cmd() {
  declare Title="${1}"
  shift
  section "${Title}"
  "$@" || add_warning "Command failed (best effort): $*"
}

function header() {
  section "Header"
  printf '%s\n' "Timestamp(local): ${TimeStampLocal}"
  printf '%s\n' "Timestamp(UTC):   $(date -u -Is)"
  printf '%s\n' "Host:             ${HostShort} (fqdn: ${HostFqdn:-N/A})"
  printf '%s\n' "Purpose:          Diagnostic Samba disk issue (partition resize/block move)"
}

function check_disks_basic() {
  run_cmd "Disk list (lsblk)" lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,MODEL,SERIAL
  run_cmd "Block devices (blkid)" blkid
  run_cmd "Partitions (fdisk -l sdb)" fdisk -l /dev/sdb
  run_cmd "Partitions (fdisk -l sdc)" fdisk -l /dev/sdc
}

function check_partition_tables() {
  section "Partition Tables (GPT/MBR)"

  # Check if GPT or MBR
  if command -v sgdisk >/dev/null 2>&1; then
    printf '%s\n' "--- /dev/sdb (sgdisk) ---"
    sgdisk --print /dev/sdb 2>&1 || add_warning "sgdisk failed for /dev/sdb"
    printf '\n%s\n' "--- /dev/sdc (sgdisk) ---"
    sgdisk --print /dev/sdc 2>&1 || add_warning "sgdisk failed for /dev/sdc"
  else
    add_warning "sgdisk not available"
  fi

  if command -v parted >/dev/null 2>&1; then
    printf '\n%s\n' "--- /dev/sdb (parted) ---"
    parted /dev/sdb print 2>&1 || add_warning "parted failed for /dev/sdb"
    printf '\n%s\n' "--- /dev/sdc (parted) ---"
    parted /dev/sdc print 2>&1 || add_warning "parted failed for /dev/sdc"
  else
    add_warning "parted not available"
  fi
}

function check_ntfs_health() {
  section "NTFS Filesystem Health"

  # Check sdb6 (DATA_1TB_A main partition)
  if [[ -b /dev/sdb6 ]]; then
    printf '%s\n' "--- /dev/sdb6 (DATA_1TB_A) ---"
    if command -v ntfsfix >/dev/null 2>&1; then
      ntfsfix --no-action /dev/sdb6 2>&1 || add_issue "ntfsfix check failed for /dev/sdb6"
    else
      add_warning "ntfsfix not available"
    fi

    if command -v ntfsinfo >/dev/null 2>&1; then
      ntfsinfo /dev/sdb6 2>&1 | head -100 || add_warning "ntfsinfo failed for /dev/sdb6"
    fi
  else
    add_issue "/dev/sdb6 device not found"
  fi

  # Check sdc3 (DATA_1TB_B main partition)
  if [[ -b /dev/sdc3 ]]; then
    printf '\n%s\n' "--- /dev/sdc3 (DATA_1TB_B) ---"
    if command -v ntfsfix >/dev/null 2>&1; then
      ntfsfix --no-action /dev/sdc3 2>&1 || add_issue "ntfsfix check failed for /dev/sdc3"
    else
      add_warning "ntfsfix not available"
    fi

    if command -v ntfsinfo >/dev/null 2>&1; then
      ntfsinfo /dev/sdc3 2>&1 | head -100 || add_warning "ntfsinfo failed for /dev/sdc3"
    fi
  else
    add_issue "/dev/sdc3 device not found"
  fi
}

function check_mounts() {
  run_cmd "Current mounts (findmnt)" findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS

  section "Expected mounts status"
  declare -a ExpectedMounts=(
    "/srv/linuxia-share/DATA_1TB_A"
    "/srv/linuxia-share/DATA_1TB_B"
    "/opt/linuxia/data/shareA"
    "/opt/linuxia/data/shareB"
  )

  for mount in "${ExpectedMounts[@]}"; do
    if findmnt -T "${mount}" >/dev/null 2>&1; then
      printf '%s\n' "✅ ${mount}: MOUNTED"
    else
      printf '%s\n' "❌ ${mount}: NOT MOUNTED"
      add_issue "Expected mount not found: ${mount}"
    fi
  done
}

function check_samba_status() {
  run_cmd "Samba services" systemctl --no-pager status smb nmb
  run_cmd "Samba listening ports" ss -lntup | grep -E ':(139|445)\b' || true
  run_cmd "Samba config (testparm)" testparm -s /etc/samba/smb.conf
  run_cmd "Samba shares status" smbstatus
}

function check_dmesg_errors() {
  section "Recent kernel messages (dmesg)"
  printf '%s\n' "Looking for errors related to sdb, sdc, NTFS, I/O errors..."
  dmesg -T | grep -iE '(sd[bc]|ntfs|error|fail|corrupt|i/o)' | tail -100 || printf '%s\n' "(no relevant messages)"
}

function check_journal_logs() {
  section "Systemd journal (disk/filesystem errors)"
  printf '%s\n' "Last 50 lines with disk/filesystem keywords..."
  journalctl --no-pager -n 50 -p err -g 'sd[bc]|ntfs|filesystem|mount' 2>/dev/null || printf '%s\n' "(no relevant errors)"
}

function check_fstab() {
  run_cmd "fstab configuration" cat /etc/fstab
}

function compare_with_snapshot() {
  section "Comparison with previous snapshot"
  declare SnapshotFile="${DocsDir}/verifications/verify_disks_20260208T223316Z.txt"

  if [[ -f "${SnapshotFile}" ]]; then
    printf '%s\n' "Reference snapshot: ${SnapshotFile}"
    printf '%s\n' "Extracting key partition info from snapshot..."
    grep -E '(sdb|sdc)' "${SnapshotFile}" | head -20 || true
  else
    add_warning "Reference snapshot not found: ${SnapshotFile}"
  fi

  printf '\n%s\n' "Current partition layout (sdb):"
  lsblk /dev/sdb 2>/dev/null || add_warning "lsblk failed for /dev/sdb"
  printf '\n%s\n' "Current partition layout (sdc):"
  lsblk /dev/sdc 2>/dev/null || add_warning "lsblk failed for /dev/sdc"
}

function disk_smart_check() {
  section "SMART disk health (if available)"

  if command -v smartctl >/dev/null 2>&1; then
    printf '%s\n' "--- /dev/sdb ---"
    smartctl -H /dev/sdb 2>&1 || add_warning "smartctl failed for /dev/sdb"
    printf '\n%s\n' "--- /dev/sdc ---"
    smartctl -H /dev/sdc 2>&1 || add_warning "smartctl failed for /dev/sdc"
  else
    add_warning "smartctl not available (smartmontools package)"
  fi
}

function summary() {
  section "Summary"

  printf '%s\n' "Total issues: ${#Issues[@]}"
  printf '%s\n' "Total warnings: ${#Warnings[@]}"

  if [[ "${#Issues[@]}" -gt 0 ]]; then
    printf '\n%s\n' "ISSUES:"
    for issue in "${Issues[@]}"; do
      printf '%s\n' "  ❌ ${issue}"
    done
  fi

  if [[ "${#Warnings[@]}" -gt 0 ]]; then
    printf '\n%s\n' "WARNINGS:"
    for warning in "${Warnings[@]}"; do
      printf '%s\n' "  ⚠️  ${warning}"
    done
  fi

  if [[ "${ReturnCode}" -eq 0 ]]; then
    printf '\n%s\n' "✅ Diagnostic completed without critical issues"
  else
    printf '\n%s\n' "❌ Diagnostic completed with issues (see above)"
  fi
}

function yaml_output() {
  section "YAML Summary"
  printf '%s\n' "diagnostic_result:"
  printf '%s\n' "  date: \"${TimeStampLocal}\""
  printf '%s\n' "  machine: \"${HostShort}\""
  printf '%s\n' "  purpose: \"Samba disk diagnostic (partition resize/block move issue)\""
  printf '%s\n' "  issues_count: ${#Issues[@]}"
  printf '%s\n' "  warnings_count: ${#Warnings[@]}"
  printf '%s\n' "  status: $(if [[ "${ReturnCode}" -eq 0 ]]; then echo '✅ OK'; else echo '❌ ISSUES'; fi)"
  printf '%s\n' "  evidence_file: \"${EvidencePath}\""
}

function git_best_effort() {
  if [[ "${NoGit}" == "true" ]]; then
    return 0
  fi

  if ! git -C "${BaseDir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    add_warning "Not a git repo: ${BaseDir}"
    return 0
  fi

  export GIT_TERMINAL_PROMPT=0
  export GIT_ASKPASS=/bin/false

  git -C "${BaseDir}" add "${EvidencePath}" "${SessionDir}/"*.md 2>/dev/null || true
  git -C "${BaseDir}" commit -m "diagnostic: Samba disk issue ${TimeStampUtc}" >/dev/null 2>&1 || add_warning "No commit created"
  git -C "${BaseDir}" push >/dev/null 2>&1 || add_warning "git push failed"

  section "Git status"
  git -C "${BaseDir}" status -sb 2>/dev/null || true
}

function main() {
  acquire_lock
  parse_args "$@"
  require_root
  detect_host
  refuse_if_not_vm100

  mkdir -p "${VerifDir}" "${EvidenceDir}"
  EvidencePath="${VerifDir}/diagnostic_samba_disk_${TimeStampUtc}.txt"

  {
    header
    check_disks_basic
    check_partition_tables
    check_ntfs_health
    check_mounts
    check_samba_status
    check_fstab
    check_dmesg_errors
    check_journal_logs
    compare_with_snapshot
    disk_smart_check
    summary
    yaml_output
  } | tee "${EvidencePath}"

  # Copy to session evidence
  cp "${EvidencePath}" "${EvidenceDir}/diagnostic_${TimeStampUtc}.txt"

  git_best_effort

  printf '\n%s\n' "Evidence saved:"
  printf '%s\n' "  - ${EvidencePath}"
  printf '%s\n' "  - ${EvidenceDir}/diagnostic_${TimeStampUtc}.txt"

  exit "${ReturnCode}"
}

main "$@"
