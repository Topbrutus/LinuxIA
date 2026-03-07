#!/usr/bin/env bash
# LinuxIA — linuxia-repair.sh
# Répare tous les fichiers manquants en une seule passe.
# Idempotent (peut être relancé plusieurs fois sans danger). Nécessite root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DIR="${DEPLOY_DIR:-/opt/linuxia}"

FIXED=0; SKIPPED=0; FAILED=0
log()  { printf "[linuxia-repair] %s\n" "$*"; }
warn() { printf "[linuxia-repair] WARN: %s\n" "$*" >&2; }
fix()  { FIXED=$((FIXED+1));   log "FIXED: $*"; }
skip() { SKIPPED=$((SKIPPED+1)); log "SKIP:  $*"; }
fail() { FAILED=$((FAILED+1));  warn "FAIL:  $*"; }

# ---------------------------------------------------------
# Étape 1 : Répertoires requis
# ---------------------------------------------------------
log "--- Étape 1/5 : Répertoires ---"
REQUIRED_DIRS=(
  "$DEPLOY_DIR/scripts"
  "$DEPLOY_DIR/docs"
  "$DEPLOY_DIR/logs/health"
  "$DEPLOY_DIR/data/shareA/archives/configsnap"
  "$DEPLOY_DIR/data/shareA/reports/health"
  "$DEPLOY_DIR/data/shareB"
)
for d in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "$d" ]]; then
    err=$(install -d -m 0755 "$d" 2>&1) && fix "Créé: $d" || fail "Impossible de créer: $d ($err)"
  else skip "Existe: $d"; fi
done

# ---------------------------------------------------------
# Étape 2 : Synchronisation des scripts depuis le dépôt
# ---------------------------------------------------------
log "--- Étape 2/5 : Scripts ---"
if [[ "$REPO_DIR" == "$DEPLOY_DIR" ]]; then
  skip "Exécuté depuis le répertoire de déploiement; aucune copie nécessaire"
elif [[ -d "$REPO_DIR/scripts" ]]; then
  for f in "$REPO_DIR"/scripts/*.sh; do
    [[ -f "$f" ]] || continue
    dest="$DEPLOY_DIR/scripts/$(basename "$f")"
    if [[ ! -f "$dest" ]] || ! diff -q "$f" "$dest" >/dev/null 2>&1; then
      err=$(install -m 0755 "$f" "$dest" 2>&1) && fix "Script installé: $(basename "$f")" \
        || fail "Impossible d'installer: $(basename "$f") ($err)"
    else skip "À jour: $(basename "$f")"; fi
  done
else
  warn "Répertoire scripts introuvable: $REPO_DIR/scripts"
fi

# ---------------------------------------------------------
# Étape 3 : Unités systemd
# ---------------------------------------------------------
log "--- Étape 3/5 : Unités systemd ---"
if ! command -v systemctl >/dev/null 2>&1; then
  warn "systemctl absent; installation des unités ignorée"
else
  SYSTEMD_DEST="/etc/systemd/system"
  UNITS_CHANGED=0
  _install_unit() {
    local src="$1" name dest
    name="$(basename "$src")"
    dest="$SYSTEMD_DEST/$name"
    if [[ ! -f "$dest" ]] || ! diff -q "$src" "$dest" >/dev/null 2>&1; then
      err=$(install -m 0644 "$src" "$dest" 2>&1) && { fix "Unité installée: $name"; UNITS_CHANGED=1; } \
        || fail "Impossible d'installer l'unité: $name ($err)"
    else skip "Unité à jour: $name"; fi
  }
  for src_dir in "$REPO_DIR/services/systemd" "$REPO_DIR/services"; do
    [[ -d "$src_dir" ]] || continue
    for f in "$src_dir"/*.service "$src_dir"/*.timer \
             "$src_dir"/*.mount   "$src_dir"/*.automount \
             "$src_dir"/*.path; do
      [[ -f "$f" ]] || continue
      _install_unit "$f"
    done
  done
  if [[ "$UNITS_CHANGED" -eq 1 ]]; then
    if systemctl daemon-reload 2>/dev/null; then fix "daemon-reload"
    else fail "daemon-reload"; fi
  fi
fi

# ---------------------------------------------------------
# Étape 4 : Activation des timers
# ---------------------------------------------------------
log "--- Étape 4/5 : Timers ---"
if command -v systemctl >/dev/null 2>&1; then
  REQUIRED_TIMERS=(
    linuxia-configsnap.timer
    linuxia-healthcheck.timer
    linuxia-health-report.timer
  )
  for t in "${REQUIRED_TIMERS[@]}"; do
    if systemctl list-unit-files "$t" --no-legend 2>/dev/null | grep -q "$t"; then
      if ! systemctl is-enabled --quiet "$t" 2>/dev/null; then
        if systemctl enable --now "$t" 2>/dev/null; then fix "Timer activé: $t"
        else fail "Impossible d'activer: $t"; fi
      else skip "Timer déjà actif: $t"; fi
    else warn "Unité timer absente (peut nécessiter une ré-installation): $t"; fi
  done
fi

# ---------------------------------------------------------
# Étape 5 : Montages + vérification finale
# ---------------------------------------------------------
log "--- Étape 5/5 : Montages + vérification ---"
if mount_err=$(mount -a 2>&1); then
  log "mount -a OK"
else
  warn "mount -a non-zéro (certains montages absents; poursuite): $mount_err"
fi

log "Résumé: FIXED=$FIXED SKIPPED=$SKIPPED FAILED=$FAILED"

HEALTHCHECK_SCRIPT="$DEPLOY_DIR/scripts/linuxia-healthcheck.sh"
HEALTHCHECK_REPORT="$DEPLOY_DIR/docs/STATE_HEALTHCHECK.md"
if [[ -x "$HEALTHCHECK_SCRIPT" ]]; then
  if "$HEALTHCHECK_SCRIPT"; then
    log "Healthcheck OK après réparation."
    exit 0
  fi
  if [[ -f "$HEALTHCHECK_REPORT" ]] && grep -q '^Result: OK$' "$HEALTHCHECK_REPORT"; then
    log "Healthcheck OK après réparation (rapport)."
    exit 0
  fi
  warn "Healthcheck encore FAIL après réparation (FIXED=$FIXED FAILED=$FAILED)."
  exit 1
else
  warn "Script healthcheck absent: $HEALTHCHECK_SCRIPT"
  [[ "$FAILED" -gt 0 ]] && exit 1
  exit 0
fi
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
TAG="linuxia-repair"
HEALTHCHECK_SCRIPT="/opt/linuxia/scripts/linuxia-healthcheck.sh"
HEALTHCHECK_REPORT="/opt/linuxia/docs/STATE_HEALTHCHECK.md"
REMOUNT_SCRIPT="/usr/local/sbin/linuxia-samba-remount.sh"
SHARE_A="/opt/linuxia/data/shareA"
SHARE_B="/opt/linuxia/data/shareB"

if ! [[ -t 1 ]] && command -v systemd-cat >/dev/null 2>&1; then
  exec > >(systemd-cat -t "$TAG") 2>&1
fi

log() { printf '[%s] %s\n' "$(date -Is)" "$*"; }

log "START repair routine"
# IMPORTANT:
# - Ne pas faire "mount -a" ici.
#   Sinon ntfs-3g tourne dans le cgroup du service, et systemd le tue à la fin => UNMOUNT.
# - On se limite à relancer un remount dédié si présent, et à vérifier les bind mounts.
if [ -x "$REMOUNT_SCRIPT" ]; then
  timeout 180s "$REMOUNT_SCRIPT" || true
fi

fail=0
findmnt -T "$SHARE_A" >/dev/null 2>&1 || fail=1
findmnt -T "$SHARE_B" >/dev/null 2>&1 || fail=1

if [ "$fail" -eq 1 ]; then
  log "repair incomplete (shareA/shareB not mounted)"
  exit 1
fi

log "repair OK"
exit 0
