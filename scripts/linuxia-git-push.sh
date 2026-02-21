#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/opt/linuxia}"
REMOTE_NAME="${REMOTE_NAME:-origin}"
BRANCH="${BRANCH:-main}"
CLEAN_URL="https://github.com/Topbrutus/LinuxIA.git"

cd "$REPO_DIR"

# Si quelqu'un a déjà injecté un token dans l'URL du remote, on nettoie.
url="$(git remote get-url "$REMOTE_NAME" 2>/dev/null || true)"
case "$url" in
  *x-access-token:*|*github_pat_*|*'@git@github.com:'* )
    git remote set-url "$REMOTE_NAME" "$CLEAN_URL"
    git remote set-url --push "$REMOTE_NAME" "$CLEAN_URL" || true
    ;;
esac

# Évite le "fetch first" : fast-forward only, sinon on échoue (sécurité).
git pull --ff-only "$REMOTE_NAME" "$BRANCH"
git push "$REMOTE_NAME" "$BRANCH"
