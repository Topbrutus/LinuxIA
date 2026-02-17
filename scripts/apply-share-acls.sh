#!/usr/bin/env bash
set -euo pipefail

# LinuxIA — apply-share-acls.sh
# Applique les ACL par défaut sur les répertoires shareA pour garantir
# des permissions prédictibles (groupe linuxia, pas d'exec accidentel).

SHAREA="/opt/linuxia/data/shareA"
GROUP="users"  # ou "linuxia" si le groupe existe

if [[ ! -d "$SHAREA" ]]; then
  echo "WARN: $SHAREA not mounted or missing, skipping ACL setup"
  exit 0
fi

# Vérifier si le groupe linuxia existe, sinon utiliser users
if getent group linuxia >/dev/null 2>&1; then
  GROUP="linuxia"
fi

echo "== Applying ACLs to shareA with group: $GROUP =="

# Répertoires clés
REPORTS="${SHAREA}/reports"
ARCHIVES="${SHAREA}/archives"

mkdir -p "$REPORTS" "$ARCHIVES" || true

# ACL par défaut : groupe rwX, autres r-X
for dir in "$REPORTS" "$ARCHIVES"; do
  if [[ -d "$dir" ]]; then
    echo "Setting ACLs on: $dir"
    
    # Default ACLs pour nouveaux fichiers/dossiers
    setfacl -d -m g:${GROUP}:rwX "$dir" || true
    setfacl -d -m o::r-X "$dir" || true
    
    # ACLs actuelles
    setfacl -m g:${GROUP}:rwX "$dir" || true
    setfacl -m o::r-X "$dir" || true
  fi
done

echo "OK: ACLs applied"
