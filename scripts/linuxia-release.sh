#!/usr/bin/env bash
# linuxia-release.sh — Phase 12: Release packaging (tarball + SHA256 checksums)
# Usage:
#   bash scripts/linuxia-release.sh
#   VERSION=v1.6.0 bash scripts/linuxia-release.sh
# Outputs (in /tmp/linuxia-release-<VERSION>/):
#   linuxia-<VERSION>.tar.gz
#   linuxia-<VERSION>.tar.gz.sha256
# Proof written to docs/verifications/ if repo is writable.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

die()  { printf "ERROR: %s\n" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---------- version ----------
if [[ -z "${VERSION:-}" ]]; then
  if have git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    VERSION="$(git describe --tags --exact-match 2>/dev/null \
      || git rev-parse --short HEAD 2>/dev/null \
      || printf "dev")"
  else
    VERSION="dev"
  fi
fi

TS="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE_NAME="linuxia-${VERSION}.tar.gz"
OUT_DIR="/tmp/linuxia-release-${VERSION}"
ARCHIVE_PATH="${OUT_DIR}/${ARCHIVE_NAME}"
CHECKSUM_FILE="${ARCHIVE_NAME}.sha256"
CHECKSUM_PATH="${OUT_DIR}/${CHECKSUM_FILE}"

mkdir -p "${OUT_DIR}"

# ---------- tarball ----------
# Includes: scripts/ services/ docs/ assets/ .github/ Makefile README.md
#           CONTRIBUTING.md SECURITY.md RISKS.md CODE_OF_CONDUCT.md AGENTS.md
# Excludes: data/ logs/ sessions/ workspace/ .git/ node_modules/ .venv/ *.zip
tar -czf "${ARCHIVE_PATH}" \
  --exclude='./.git' \
  --exclude='./data' \
  --exclude='./logs' \
  --exclude='./sessions' \
  --exclude='./workspace' \
  --exclude='./node_modules' \
  --exclude='./.venv' \
  --exclude='./*.zip' \
  --exclude='./assets/readme/showcase/linuxia_-cinematic-showcase/node_modules' \
  --exclude='./assets/readme/showcase/linuxia_-cinematic-showcase/dist' \
  .

# ---------- checksum ----------
if have sha256sum; then
  ( cd "${OUT_DIR}" && sha256sum "${ARCHIVE_NAME}" > "${CHECKSUM_FILE}" )
elif have shasum; then
  ( cd "${OUT_DIR}" && shasum -a 256 "${ARCHIVE_NAME}" > "${CHECKSUM_FILE}" )
else
  die "sha256sum or shasum is required"
fi

# ---------- manifest ----------
ARCHIVE_SIZE="$(du -sh "${ARCHIVE_PATH}" | cut -f1)"

printf "\n"
printf "=== LinuxIA Release Package ===\n"
printf "Version:    %s\n" "${VERSION}"
printf "Timestamp:  %s\n" "${TS}"
printf "Archive:    %s  (%s)\n" "${ARCHIVE_PATH}" "${ARCHIVE_SIZE}"
printf "Checksum:   %s\n" "${CHECKSUM_PATH}"
printf "\nChecksum:\n"
cat "${CHECKSUM_PATH}"

# ---------- proof ----------
PROOF_DIR="${REPO_ROOT}/docs/verifications"
if [[ -d "${PROOF_DIR}" ]]; then
  PROOF_FILE="${PROOF_DIR}/release_${VERSION}_${TS}.txt"
  {
    printf "linuxia-release proof\n"
    printf "version=%s\n" "${VERSION}"
    printf "timestamp=%s\n" "${TS}"
    printf "archive=%s\n" "${ARCHIVE_PATH}"
    printf "archive_size=%s\n" "${ARCHIVE_SIZE}"
    printf "checksum_file=%s\n" "${CHECKSUM_PATH}"
    printf "checksum_contents=\n"
    cat "${CHECKSUM_PATH}"
  } > "${PROOF_FILE}"
  printf "\nProof:      %s\n" "${PROOF_FILE}"
fi

printf "\nOK: release package ready -> %s\n" "${OUT_DIR}"
