#!/usr/bin/env bash
# LinuxIA — run-seq.sh
# Exécute les commandes une par une, affiche la sortie, puis enchaîne.
#
# Usage:
#   run-seq.sh <commands-file>          # un fichier, une commande par ligne
#   run-seq.sh -- "cmd1" "cmd2" ...    # commandes en ligne directe
#
# Env (overridables):
#   LOG_FILE     chemin JSONL (défaut: /tmp/linuxia-run-seq/session.jsonl)
#   SESSION_ID   identifiant de session (défaut: horodatage ISO)
#   DRY_RUN      si "1" : planifie uniquement, n'exécute pas
#
# SECURITE: Ce script utilise eval pour executer les commandes.
#   N'executez jamais un fichier de commandes dont vous ne maitrisez pas
#   l'origine. Reserve aux flux de travail de confiance sur VMs internes.
#
# FORMAT FICHIER: Une commande par ligne. Les lignes vides et les lignes
#   commencant par '#' sont ignorees. Les commentaires en fin de ligne
#   (ex: echo hello # comment) ne sont PAS filtres : le shell les interprete
#   nativement comme partie de la commande.
#
# LOG JSONL: Echappement minimal (\, ", \n, \t). Utiliser jq pour une
#   validation stricte si necessaire.
set -euo pipefail

SESSION_ID="${SESSION_ID:-$(date +%Y%m%dT%H%M%S)}"
LOG_DIR="${LOG_DIR:-/tmp/linuxia-run-seq}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/session.jsonl}"
DRY_RUN="${DRY_RUN:-0}"

die()  { printf "ERROR: %s\n" "$*" >&2; exit 1; }
hr()   { printf "%s\n" "------------------------------------------------------------"; }

log_event() {
  local status="$1" cmd_str="$2" exit_code="${3:-0}"
  mkdir -p "$(dirname "$LOG_FILE")"
  # Echappement JSON : \ → \\ , " → \" , newline → \n , tab → \t
  local escaped
  escaped="$(printf '%s' "$cmd_str" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | tr '\n' '|' | sed 's/|/\\n/g; s/\\n$//')"
  printf '{"ts":"%s","session":"%s","cmd":"%s","status":"%s","exit_code":%d}\n' \
    "$(date -Iseconds)" "$SESSION_ID" "$escaped" "$status" "$exit_code" \
    >> "$LOG_FILE"
}

run_cmd() {
  local n="$1" total="$2" cmd="$3"
  hr
  printf "[%d/%d] CMD: %s\n" "$n" "$total" "$cmd"
  hr
  local exit_code=0
  if [[ "$DRY_RUN" == "1" ]]; then
    printf "[DRY-RUN] skipped\n"
    log_event "SKIPPED" "$cmd" 0
    return 0
  fi
  eval "$cmd" || exit_code=$?
  hr
  if [[ "$exit_code" -eq 0 ]]; then
    printf "[%d/%d] OK (exit 0) — %s\n" "$n" "$total" "$cmd"
    log_event "DONE" "$cmd" 0
  else
    printf "[%d/%d] FAIL (exit %d) — %s\n" "$n" "$total" "$exit_code" "$cmd"
    log_event "FAILED" "$cmd" "$exit_code"
  fi
  return "$exit_code"
}

usage() {
  printf "LinuxIA run-seq — exécute des commandes une par une, montre la sortie\n\n"
  printf "Usage:\n"
  printf "  run-seq.sh <commands-file>          # un fichier texte, une commande par ligne\n"
  printf "  run-seq.sh -- \"cmd1\" \"cmd2\" ...   # commandes en ligne directe\n"
  printf "  run-seq.sh -h | --help\n\n"
  printf "Env:\n"
  printf "  LOG_FILE    chemin JSONL (défaut: /tmp/linuxia-run-seq/session.jsonl)\n"
  printf "  SESSION_ID  identifiant de session (défaut: horodatage)\n"
  printf "  DRY_RUN     1 = planifier seulement, sans exécuter\n"
}

# ----- Parsing des arguments -----
mode=""
cmds=()
cmds_file=""

case "${1:-}" in
  -h|--help)
    usage; exit 0 ;;
  --)
    shift
    mode="inline"
    cmds=("$@") ;;
  "")
    usage; exit 1 ;;
  *)
    mode="file"
    cmds_file="$1" ;;
esac

if [[ "$mode" == "file" ]]; then
  [[ -f "$cmds_file" ]] || die "Fichier de commandes introuvable: $cmds_file"
  mapfile -t cmds < <(grep -v '^[[:space:]]*#' "$cmds_file" | grep -v '^[[:space:]]*$')
fi

[[ ${#cmds[@]} -gt 0 ]] || die "Aucune commande à exécuter"

# ----- Exécution séquentielle -----
total=${#cmds[@]}
hr
printf "=== LinuxIA run-seq: %d commande(s) | session=%s | dry_run=%s ===\n" \
  "$total" "$SESSION_ID" "$DRY_RUN"
printf "LOG: %s\n" "$LOG_FILE"
hr

ok_count=0
fail_count=0
for i in "${!cmds[@]}"; do
  n=$((i + 1))
  if run_cmd "$n" "$total" "${cmds[$i]}"; then
    ok_count=$((ok_count + 1))
  else
    fail_count=$((fail_count + 1))
  fi
done

hr
printf "=== Résumé: OK=%d FAIL=%d TOTAL=%d | session=%s ===\n" \
  "$ok_count" "$fail_count" "$total" "$SESSION_ID"

[[ "$fail_count" -eq 0 ]] || exit 1
