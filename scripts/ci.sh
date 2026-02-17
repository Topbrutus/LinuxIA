#!/usr/bin/env bash
set -euo pipefail

echo "=== LinuxIA CI (local) ==="
echo "Host: $(hostname)"
echo "Date: $(date -Iseconds)"
echo

# Liste de scripts bash à vérifier
mapfile -d '' files < <(find scripts -maxdepth 1 -type f -name '*.sh' -print0 2>/dev/null || true)

if [ "${#files[@]}" -eq 0 ]; then
  echo "WARN: no scripts/*.sh found"
  exit 0
fi

echo "== bash -n =="
for f in "${files[@]}"; do
  bash -n "$f"
done
echo "OK: bash -n on ${#files[@]} files"
echo

if command -v shellcheck >/dev/null 2>&1; then
  echo "== shellcheck =="
  # Exclusions utiles: SC1091 (sources dynamiques) selon tes scripts
  shellcheck -x -S warning "${files[@]}" || true
  echo "OK: shellcheck (warnings allowed for now)"
else
  echo "WARN: shellcheck not installed (local). On CI it will run."
fi

echo
echo "DONE"
