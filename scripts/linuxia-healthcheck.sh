#!/usr/bin/env bash
set -euo pipefail

OUT="/opt/linuxia/docs/STATE_HEALTHCHECK.md"
HOSTNAME_VALUE="$(hostname)"
DATE_VALUE="$(date -Is)"

critical_failed=0

declare -a RESULTS=()

run_check() {
  local name="$1"
  local critical="$2"
  shift 2

  if "$@"; then
    RESULTS+=("${name}|OK|${critical}")
  else
    RESULTS+=("${name}|FAIL|${critical}")
    if [ "$critical" = "yes" ]; then
      critical_failed=1
    fi
  fi
}

run_check "preflight" "yes" /opt/linuxia/scripts/linuxia-preflight.sh
run_check "state-report" "yes" /opt/linuxia/scripts/linuxia-state-report.sh
run_check "configsnap-index" "yes" /opt/linuxia/scripts/linuxia-configsnap-index.sh

{
  printf "# STATE_HEALTHCHECK\n\n"
  printf -- "- Generated: %s\n" "$DATE_VALUE"
  printf -- "- Hostname: %s\n\n" "$HOSTNAME_VALUE"
  printf "## Checks\n\n"
  printf "| Check | Status | Critical |\n"
  printf "| --- | --- | --- |\n"

  for entry in "${RESULTS[@]}"; do
    IFS='|' read -r name status critical <<<"$entry"
    printf "| %s | %s | %s |\n" "$name" "$status" "$critical"
  done

  printf "\n"

  if [ "$critical_failed" -eq 1 ]; then
    printf "Result: FAIL\n"
  else
    printf "Result: OK\n"
  fi
} > "$OUT"

if [ "$critical_failed" -eq 1 ]; then
  exit 1
fi

exit 0
