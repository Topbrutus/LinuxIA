#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

# ----------------- LinuxIA Config Snapshot -----------------
# Capture un "snapshot" des configs / scripts / unités utiles
# sans embarquer data/logs/workspace ni secrets évidents.

TS="$(date +%F_%H%M%S)"
BASE="/opt/linuxia"
DEFAULT_OUT="$BASE/data/shareA/archives/configsnap"
OUTDIR="${1:-$DEFAULT_OUT}"

WORK="$(mktemp -d "/tmp/linuxia-configsnap.${TS}.XXXX")"
FILES_DIR="$WORK/files"
META_DIR="$WORK/meta"
STAGE_LIST="$WORK/filelist.txt"

log(){ printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

cleanup(){
  rm -rf "$WORK" 2>/dev/null || true
}
trap cleanup EXIT

# --- Dossiers scannés (limités, sinon tu snapshot la planète) ---
SCAN_DIRS=(
  /etc
  /usr/local/sbin
  /usr/local/bin
  "$BASE"
)

# --- Exclusions (secrets + bruit + gros dossiers inutiles) ---
# Regex ERE (utilisée par [[ =~ ]]) sur CHEMIN COMPLET
EXCLUDE_REGEX='^(/root/\.smb-|/root/\.ssh/|/home/[^/]+/\.ssh/|/etc/(shadow|gshadow)(\.|$)|/etc/ssh/ssh_host_.*key|/etc/ssl/private/|/etc/pki/.*/private/|/etc/krb5\.keytab$|/opt/linuxia/(data|logs|workspace)/|/opt/linuxia/data/|/opt/linuxia/logs/|/opt/linuxia/workspace/|/opt/linuxia/\.git/)'

# Exclusion par extension (cert/keys/keystores)
EXCLUDE_EXT_REGEX='(\.pem|\.key|\.p12|\.pfx|\.jks|\.kdb)$'

should_exclude(){
  local p="$1"
  [[ "$p" =~ $EXCLUDE_REGEX ]] && return 0
  [[ "$p" =~ $EXCLUDE_EXT_REGEX ]] && return 0
  return 1
}

# --- Types de fichiers qu’on considère comme "config / infra" ---
# Tu peux ajouter/retirer des patterns ici.
FIND_MATCH=(
  -name "*.conf" -o -name "*.cfg" -o -name "*.ini" -o -name "*.cnf"
  -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.toml"
  -o -name "*.service" -o -name "*.timer" -o -name "*.socket" -o -name "*.target"
  -o -name "*.mount" -o -name "*.automount"
  -o -name "*.sh"
  -o -name "fstab" -o -name "hosts" -o -name "hostname" -o -name "resolv.conf"
  -o -name "sshd_config" -o -name "ssh_config"
  -o -name "smb.conf"
  -o -name "sudoers" -o -path "*/sudoers.d/*"
)

# --- Prépare sorties ---
install -d -m 0755 "$OUTDIR"
install -d -m 0755 "$FILES_DIR" "$META_DIR"
: > "$STAGE_LIST"

log "Capture état système..."
{
  echo "ts=$TS"
  echo "host=$(hostname)"
  echo "kernel=$(uname -a)"
  echo "user=$(id -un)"
  echo "uid=$(id -u)"
} > "$META_DIR/identity.txt"

# Petits dumps utiles (best-effort)
{
  echo "### date"; date
  echo
  echo "### uname -a"; uname -a
  echo
  echo "### lsblk -f"; lsblk -f || true
  echo
  echo "### df -hT"; df -hT || true
  echo
  echo "### findmnt"; findmnt || true
  echo
  echo "### ip -br a"; ip -br a || true
  echo
  echo "### ip r"; ip r || true
} > "$META_DIR/system_overview.txt" 2>&1 || true

# systemd: services LinuxIA (si présent)
{
  echo "### systemctl list-unit-files | grep linuxia"
  systemctl list-unit-files 2>/dev/null | grep -i linuxia || true
  echo
  echo "### systemctl status linuxia-samba-remount.service"
  systemctl --no-pager -l status linuxia-samba-remount.service 2>/dev/null || true
} > "$META_DIR/systemd_linuxia.txt" 2>&1 || true

# Git état du repo LinuxIA (best-effort)
{
  if command -v git >/dev/null 2>&1 && [ -d "$BASE/.git" ]; then
    echo "### git remote -v"
    (cd "$BASE" && git remote -v) || true
    echo
    echo "### git status --porcelain"
    (cd "$BASE" && git status --porcelain) || true
    echo
    echo "### git log --oneline -n 20"
    (cd "$BASE" && git log --oneline -n 20) || true
  else
    echo "git: repo non détecté dans $BASE"
  fi
} > "$META_DIR/git_state.txt" 2>&1 || true

log "Collecte configs (find sans warning)..."
for d in "${SCAN_DIRS[@]}"; do
  [ -d "$d" ] || continue

  # -maxdepth AVANT -type (sinon warning)
  while IFS= read -r -d '' f; do
    should_exclude "$f" && continue
    printf '%s\n' "$f" >> "$STAGE_LIST"
  done < <(
    find "$d" -maxdepth 6 -type f \( "${FIND_MATCH[@]}" \) -print0 2>/dev/null
  )
done

# Dé-doublonnage
sort -u "$STAGE_LIST" -o "$STAGE_LIST"

# Manifest
cp -a "$STAGE_LIST" "$META_DIR/MANIFEST_FILES.txt"

log "Copie des fichiers (rsync -aR)..."
# On copie depuis / pour que -aR recrée les chemins complets dans $FILES_DIR
rsync -aR --files-from="$STAGE_LIST" / "$FILES_DIR" 2>/dev/null || true

# Archive
ARCHIVE="$OUTDIR/linuxia-configsnap_${TS}.tar.zst"
log "Archive -> $ARCHIVE"

if command -v zstd >/dev/null 2>&1; then
  tar -C "$WORK" -cf - files meta | zstd -T0 -19 -o "$ARCHIVE"
else
  # fallback si zstd absent
  ARCHIVE="${ARCHIVE%.zst}.gz"
  tar -C "$WORK" -czf "$ARCHIVE" files meta
fi

log "OK ✅  => $ARCHIVE"
echo "$ARCHIVE"

