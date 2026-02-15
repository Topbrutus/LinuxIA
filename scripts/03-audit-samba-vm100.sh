#!/usr/bin/env bash
# Title: 03-audit-samba-vm100.sh
# Description: Audit Samba VM100 anti-fausse preuve. Vérifie services, ports 139/445, firewalld (service samba ou ports), lit config via testparm, vérifie paths des shares. Non interactif, lecture seule système. Évidence dans docs/verifications/.
# Date: 2026-02-08
# Version: 0.99
# Usage: /opt/linuxia/scripts/03-audit-samba-vm100.sh [--expected-host vm100-factory] [--expected-prefix vm100] [--config /etc/samba/smb.conf] [--force] [--no-git] [--no-production-append]
# Bash version: 5.1+
# Notes: Ne lance jamais sudo. À exécuter en root (ou via sudo -n). Commandes potentiellement lentes protégées par timeout.

set -euo pipefail;
IFS=$'\n\t';

declare -r ScriptName="$(basename "${BASH_SOURCE[0]}")";
declare -r BaseDir="/opt/linuxia";
declare -r DocsDir="${BaseDir}/docs";
declare -r VerifDir="${DocsDir}/verifications";
declare -r DefaultConfig="/etc/samba/smb.conf";
declare -r TimeStampUtc="$(date -u +%Y%m%dT%H%M%SZ)";
declare -r TimeStampLocal="$(date -Is)";

declare ExpectedHost="vm100-factory";
declare ExpectedPrefix="vm100";
declare ConfigPath="${DefaultConfig}";
declare ForceRun="false";
declare NoGit="false";
declare NoProductionAppend="false";

declare -i ReturnCode=0;

declare HostShort="";
declare HostFqdn="";
declare EvidenceRepoPath="";
declare GitTag="";

declare -r LockDir="/run/lock/${ScriptName}.lock.d";
declare -r LockDirFallback="/tmp/${ScriptName}.lock.d";

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

  printf '%s\n' "ERROR: Lock exists (${LockDir} or ${LockDirFallback}). Another run may be in progress.";
  exit 1;
}

function warn() {
  declare Msg="${1}";
  printf '%s\n' "WARN: ${Msg}";
  ReturnCode=1;
}

function fail() {
  declare Msg="${1}";
  printf '%s\n' "ERROR: ${Msg}";
  ReturnCode=1;
}

function have_cmd() {
  declare Cmd="${1}";
  if command -v "${Cmd}" >/dev/null 2>&1;
  then
    return 0;
  fi;
  return 1;
}

function print_usage() {
  printf '%s\n' "Usage: ${ScriptName} [options]";
  printf '%s\n' "  --expected-host <name>     (default: vm100-factory)";
  printf '%s\n' "  --expected-prefix <pref>   (default: vm100)";
  printf '%s\n' "  --config <path>            (default: /etc/samba/smb.conf)";
  printf '%s\n' "  --force                    ignore anti-fausse preuve";
  printf '%s\n' "  --no-git                   skip commit/tag/push";
  printf '%s\n' "  --no-production-append     do not append docs/PRODUCTION.md";
  printf '%s\n' "  -h, --help                 help";
}

function parse_args() {
  declare Arg="";
  while [[ $# -gt 0 ]];
  do
    Arg="${1}";
    case "${Arg}" in
      --expected-host)
        ExpectedHost="${2:-}";
        shift 2;
        ;;
      --expected-prefix)
        ExpectedPrefix="${2:-}";
        shift 2;
        ;;
      --config)
        ConfigPath="${2:-}";
        shift 2;
        ;;
      --force)
        ForceRun="true";
        shift 1;
        ;;
      --no-git)
        NoGit="true";
        shift 1;
        ;;
      --no-production-append)
        NoProductionAppend="true";
        shift 1;
        ;;
      -h|--help)
        print_usage;
        exit 0;
        ;;
      *)
        printf '%s\n' "ERROR: Unknown arg: ${Arg}";
        print_usage;
        exit 1;
        ;;
    esac;
  done;
}

function require_root() {
  if [[ "${EUID}" -ne 0 ]];
  then
    printf '%s\n' "ERROR: Must run as root (script does not call sudo).";
    exit 1;
  fi;
}

function detect_host() {
  HostShort="$(hostname -s 2>/dev/null || hostname)";
  HostFqdn="$(hostname -f 2>/dev/null || true)";
}

function refuse_if_not_vm100() {
  if [[ "${ForceRun}" == "true" ]];
  then
    warn "--force enabled: anti-fausse preuve disabled.";
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

  printf '%s\n' "ERROR: Anti-fausse preuve: allowed only on VM100.";
  printf '%s\n' "       Detected host: ${HostShort} (fqdn: ${HostFqdn:-N/A})";
  printf '%s\n' "       Expected: host='${ExpectedHost}' OR prefix='${ExpectedPrefix}*'";
  exit 1;
}

function section() {
  declare Title="${1}";
  printf '\n%s\n' "=== ${Title} ===";
}

function run_cmd() {
  declare Title="${1}";
  shift;

  section "${Title}";

  if have_cmd "timeout";
  then
    timeout 12s "$@" || warn "Timeout/fail (best effort): $*";
  else
    "$@" || warn "Fail (best effort): $*";
  fi;
}

function preflight_pty() {
  declare PtyNr="0";
  declare PtyMax="0";
  declare -i Pct=0;

  section "Preflight (PTY)";
  if [[ -r /proc/sys/kernel/pty/nr && -r /proc/sys/kernel/pty/max ]];
  then
    PtyNr="$(cat /proc/sys/kernel/pty/nr 2>/dev/null || echo 0)";
    PtyMax="$(cat /proc/sys/kernel/pty/max 2>/dev/null || echo 0)";
    if [[ "${PtyMax}" -gt 0 ]];
    then
      Pct=$(( (PtyNr * 100) / PtyMax ));
    fi;
    printf '%s\n' "pty.nr=${PtyNr} pty.max=${PtyMax} (${Pct}%)";
    if [[ "${Pct}" -ge 95 ]];
    then
      fail "PTY almost exhausted (>=95%). Close extra SSH/sessions before running audit.";
      exit 1;
    fi;
  else
    warn "Cannot read /proc/sys/kernel/pty/*";
  fi;
}

function collect_env() {
  section "Header";
  printf '%s\n' "Timestamp(local): ${TimeStampLocal}";
  printf '%s\n' "Timestamp(UTC):   $(date -u -Is)";
  printf '%s\n' "Host short:       ${HostShort}";
  printf '%s\n' "Host fqdn:        ${HostFqdn:-N/A}";
  printf '%s\n' "smb.conf:         ${ConfigPath}";
  printf '%s\n' "force:            ${ForceRun}";

  run_cmd "OS / kernel" bash -c 'hostnamectl 2>/dev/null || true; echo; cat /etc/os-release 2>/dev/null || true; echo; uname -a;';
  run_cmd "Listening ports (139/445)" bash -c "ss -lntup 2>/dev/null | egrep ':(139|445)\\b' || true;";
  run_cmd "Samba services (systemd)" bash -c 'systemctl --no-pager --full status smb nmb 2>/dev/null || true; echo; systemctl --no-pager is-active smb nmb 2>/dev/null || true;';
}

function firewall_verdict() {
  section "Firewall verdict (Samba allowed?)";

  if ! have_cmd "firewall-cmd";
  then
    warn "firewall-cmd not found; cannot confirm firewalld rules.";
    return 0;
  fi;

  if ! firewall-cmd --state >/dev/null 2>&1;
  then
    warn "firewalld not running (or access denied); cannot confirm rules.";
    return 0;
  fi;

  declare ActiveZones="";
  declare Line="";
  declare Zone="";
  declare Services="";
  declare Ports="";
  declare AnyOk="false";

  ActiveZones="$(firewall-cmd --get-active-zones 2>/dev/null || true)";

  while IFS= read -r Line;
  do
    if [[ -n "${Line}" && "${Line}" != " "* && "${Line}" != $'\t'* ]];
    then
      Zone="${Line%% *}";
      Services="$(firewall-cmd --zone="${Zone}" --list-services 2>/dev/null || true)";
      Ports="$(firewall-cmd --zone="${Zone}" --list-ports 2>/dev/null || true)";

      printf '%s\n' "--- zone: ${Zone}";
      printf '%s\n' "services: ${Services}";
      printf '%s\n' "ports:    ${Ports}";

      if [[ " ${Services} " == *" samba "* ]];
      then
        AnyOk="true";
      fi;

      if [[ "${AnyOk}" != "true" ]];
      then
        if [[ " ${Ports} " == *" 139/tcp "* && " ${Ports} " == *" 445/tcp "* ]];
        then
          AnyOk="true";
        fi;
      fi;
    fi;
  done <<< "${ActiveZones}";

  if [[ "${AnyOk}" == "true" ]];
  then
    printf '%s\n' "OK: Samba allowed (service samba OR ports 139/tcp+445/tcp in an active zone).";
  else
    fail "NOT OK: Samba NOT allowed in firewalld (no service samba, no ports 139/445).";
  fi;
}

function dump_config_and_shares() {
  if [[ ! -f "${ConfigPath}" ]];
  then
    fail "smb.conf missing: ${ConfigPath}";
    return 0;
  fi;

  if have_cmd "testparm";
  then
    run_cmd "Samba config (testparm -s)" testparm -s "${ConfigPath}";
  else
    warn "testparm missing; dumping raw smb.conf excerpt.";
    run_cmd "Samba config (raw excerpt)" bash -c "sed -n '1,260p' \"${ConfigPath}\" 2>/dev/null || true;";
  fi;

  section "Share paths extracted + filesystem checks";

  declare TmpConf="";
  TmpConf="$(mktemp -t samba_eff_XXXXXX.conf)";

  if have_cmd "testparm";
  then
    testparm -s "${ConfigPath}" >"${TmpConf}" 2>/dev/null || cat -- "${ConfigPath}" >"${TmpConf}";
  else
    cat -- "${ConfigPath}" >"${TmpConf}";
  fi;

  awk '
    BEGIN { s=""; }
    /^[[:space:]]*\[/ {
      t=$0; gsub(/^[[:space:]]*\[/,"",t); gsub(/\][[:space:]]*$/,"",t);
      s=t; next;
    }
    s != "" && tolower(s) != "global" {
      if ($0 ~ /^[[:space:]]*path[[:space:]]*=/) {
        p=$0; sub(/^[[:space:]]*path[[:space:]]*=[[:space:]]*/,"",p); gsub(/[[:space:]]*$/,"",p);
        print s "|" p;
      }
    }
  ' "${TmpConf}" | \
  while IFS= read -r Line;
  do
    declare ShareName="";
    declare SharePath="";
    ShareName="${Line%%|*}";
    SharePath="${Line#*|}";
    printf '%s\n' "--- [${ShareName}] path = ${SharePath}";

    if [[ -z "${SharePath}" ]];
    then
      warn "Share [${ShareName}]: empty path.";
      continue;
    fi;

    if [[ "${SharePath}" != /* ]];
    then
      fail "Share [${ShareName}]: non-absolute path: ${SharePath}";
      continue;
    fi;

    if [[ ! -e "${SharePath}" ]];
    then
      fail "Share [${ShareName}]: path missing: ${SharePath}";
      continue;
    fi;

    if [[ ! -d "${SharePath}" ]];
    then
      fail "Share [${ShareName}]: exists but not a dir: ${SharePath}";
      continue;
    fi;

    ls -lad -- "${SharePath}" 2>/dev/null || true;

    if have_cmd "findmnt";
    then
      printf '%s\n' "Mount: $(findmnt -T "${SharePath}" -rno TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null || true)";
    fi;
  done;

  rm -f -- "${TmpConf}" 2>/dev/null || true;

  run_cmd "pdbedit (passdb)" bash -c 'if command -v pdbedit >/dev/null 2>&1; then pdbedit -L 2>/dev/null || true; else echo "pdbedit not installed"; fi;';
  run_cmd "smbstatus" bash -c 'if command -v smbstatus >/dev/null 2>&1; then smbstatus 2>/dev/null || true; else echo "smbstatus not installed"; fi;';
}

function append_production() {
  if [[ "${NoProductionAppend}" == "true" ]];
  then
    return 0;
  fi;

  if [[ ! -f "${DocsDir}/PRODUCTION.md" ]];
  then
    warn "docs/PRODUCTION.md missing; skip append.";
    return 0;
  fi;

  cat >> "${DocsDir}/PRODUCTION.md" <<EOT

## Checkpoint C — Samba audited (VM100)
- Date: ${TimeStampLocal}
- Evidence (repo): docs/verifications/$(basename "${EvidenceRepoPath}")
- Notes: Non-interactive, anti-fausse preuve, timeouts to avoid hangs.
EOT
}

function git_best_effort() {
  if [[ "${NoGit}" == "true" ]];
  then
    return 0;
  fi;

  if ! git -C "${BaseDir}" rev-parse --is-inside-work-tree >/dev/null 2>&1;
  then
    warn "Not a git repo: ${BaseDir}; skip git.";
    return 0;
  fi;

  export GIT_TERMINAL_PROMPT=0;
  export GIT_ASKPASS=/bin/false;

  GitTag="checkpointC-vm100-samba-audited-${TimeStampUtc}";

  git -C "${BaseDir}" add "docs/PRODUCTION.md" "docs/verifications/$(basename "${EvidenceRepoPath}")" 2>/dev/null || true;
  git -C "${BaseDir}" commit -m "Checkpoint C (vm100): samba audited ${TimeStampUtc}" >/dev/null 2>&1 || warn "No commit created (maybe no changes).";
  git -C "${BaseDir}" push >/dev/null 2>&1 || warn "git push failed (best effort).";
  git -C "${BaseDir}" tag -a "${GitTag}" -m "Samba audited vm100 ${TimeStampUtc}" >/dev/null 2>&1 || warn "git tag failed (exists?).";
  git -C "${BaseDir}" push origin "${GitTag}" >/dev/null 2>&1 || warn "git push tag failed (best effort).";

  section "Git status";
  git -C "${BaseDir}" status -sb 2>/dev/null || true;
  printf '%s\n' "Tag: ${GitTag}";
}

function main() {
  acquire_lock;
  parse_args "$@";
  require_root;
  detect_host;
  refuse_if_not_vm100;

  mkdir -p "${VerifDir}";
  EvidenceRepoPath="${VerifDir}/audit_samba_vm100_${TimeStampUtc}.txt";

  {
    preflight_pty;
    collect_env;
    firewall_verdict;
    dump_config_and_shares;

    section "Result";
    if [[ "${ReturnCode}" -eq 0 ]];
    then
      printf '%s\n' "OK: audit completed.";
    else
      printf '%s\n' "NOT OK: issues detected (see WARN/ERROR).";
    fi;
  } | tee "${EvidenceRepoPath}";

  append_production;
  git_best_effort;

  printf '%s\n' "Evidence (repo): ${EvidenceRepoPath}";
  exit "${ReturnCode}";
}

main "$@";
