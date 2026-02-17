#!/usr/bin/env bash
# [BLOC COPILOT — VM102 | "Sanity + Discovery + Handoff" ✅🧾]
# Objectif: sur VM102, valider l'environnement, mettre le repo à jour, faire une découverte du code orchestrateur,
# générer des preuves (logs), et préparer un "handoff" clair pour la prochaine étape (/api/state).
# Non-destructif. STOP ⚠️ si conflit git, erreur non comprise, ou commande dangereuse.

set -euo pipefail

cd /opt/linuxia

TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUTDIR="docs/verifications/vm102_${TS}"
mkdir -p "${OUTDIR}"

echo "==[0) IDENTITÉ / CONTEXTE]=="
{
  echo "timestamp_utc=${TS}"
  echo "pwd=$(pwd)"
  echo
  echo "[os]"; cat /etc/os-release || true; uname -a || true
  echo
  echo "[whoami]"; id || true
  echo
  echo "[network]"; ip -br a || true; ip r || true
  echo
  echo "[tools]"; git --version || true; python3 --version || true; jq --version || true; rg --version || true
} | tee "${OUTDIR}/00_env.txt"

echo "==[1) GIT SAFE UPDATE]=="
{
  echo "[git status before]"; git status
  echo
  echo "[remotes]"; git remote -v
  echo
  echo "[branch]"; git branch --show-current || true
} | tee "${OUTDIR}/01_git_before.txt"

# Mise à jour safe (fast-forward only)
git fetch origin | tee "${OUTDIR}/01_git_fetch.txt"
git pull --ff-only | tee "${OUTDIR}/01_git_pull_ffonly.txt" || {
  echo "STOP: pull non fast-forward (ou erreur). Voir ${OUTDIR}/01_git_pull_ffonly.txt"
  exit 1
}

# Branche de travail (ne touche pas main)
BR="vm102-discovery-${TS}"
git checkout -b "${BR}" | tee "${OUTDIR}/01_git_checkout_branch.txt" || git checkout "${BR}"

echo "==[2) VERIFY READY (si script existe)]=="
if [[ -x "./scripts/verify_vm102_ready.sh" ]]; then
  ./scripts/verify_vm102_ready.sh | tee "${OUTDIR}/02_verify_vm102_ready_run.txt"
else
  echo "NOTE: scripts/verify_vm102_ready.sh absent. On enregistre juste un mini-check." | tee "${OUTDIR}/02_verify_vm102_ready_run.txt"
fi

echo "==[3) INVENTAIRE RAPIDE DU REPO]=="
{
  echo "[top-level]"; git rev-parse --show-toplevel
  echo
  echo "[ls root]"; ls -la
  echo
  echo "[structure (maxdepth=3)]"
  find . -maxdepth 3 -type d \
    ! -path "./.git*" \
    ! -path "./.venv*" \
    ! -path "./node_modules*" \
    -print | sed 's|^\./||'
} | tee "${OUTDIR}/03_repo_inventory.txt"

echo "==[4) DISCOVERY ORCHESTRATEUR / API / STATE]=="
# On cherche des indices: frameworks web, routes /api, state envelope, jsonl logs, orchestrator, systemd units, etc.
{
  echo "### Keywords scan"
  echo
  echo "[A) web frameworks]"
  rg -n --hidden --glob '!.git/*' --glob '!**/.venv/*' \
    'FastAPI|Flask|Sanic|Starlette|uvicorn|gunicorn|aiohttp|quart|falcon' . || true
  echo
  echo "[B) routes /api / state]"
  rg -n --hidden --glob '!.git/*' --glob '!**/.venv/*' \
    '/api|api/state|state|StateEnvelope|getState|setState|mergeState|JSONL|ndjson|event.*log|orchestrator' . || true
  echo
  echo "[C) likely entrypoints]"
  rg -n --hidden --glob '!.git/*' --glob '!**/.venv/*' \
    'if __name__ == "__main__"|app\.run\(|uvicorn\.run\(|create_app\(|FastAPI\(|Flask\(' . || true
  echo
  echo "[D) systemd units]"
  find . -maxdepth 5 -type f \( -name "*.service" -o -name "*.timer" \) -print || true
} | tee "${OUTDIR}/04_orchestrator_discovery_rg.txt"

echo "==[5) PYTHON PROJECT DETECT + VENV OPTIONAL]=="
# But: installer deps DEV si nécessaire, sans commiter la venv.
{
  echo "[pyproject/requirements]"
  ls -la pyproject.toml requirements*.txt setup.py setup.cfg 2>/dev/null || true
} | tee "${OUTDIR}/05_python_project_detect.txt"

# Crée un venv local si on voit un projet Python (safe)
if [[ -f "pyproject.toml" || -f "requirements.txt" || -f "requirements-dev.txt" || -f "setup.py" ]]; then
  if [[ ! -d ".venv" ]]; then
    python3 -m venv .venv
  fi
  # shellcheck disable=SC1091
  source .venv/bin/activate
  python -m pip install -U pip wheel setuptools | tee "${OUTDIR}/05_pip_upgrade.txt"

  if [[ -f "requirements.txt" ]]; then
    python -m pip install -r requirements.txt | tee "${OUTDIR}/05_pip_install_requirements.txt"
  fi
  if [[ -f "requirements-dev.txt" ]]; then
    python -m pip install -r requirements-dev.txt | tee "${OUTDIR}/05_pip_install_requirements_dev.txt"
  fi

  # Bonus "safe lint/test" si présent, sinon compilation Python
  echo "==[6) SAFE CHECKS]=="
  {
    echo "[compileall]"
    python -m compileall -q . || true
    echo
    echo "[pytest if tests]"
    if find . -maxdepth 4 -type f -name "test_*.py" -o -path "./tests/*" | grep -q .; then
      python -m pip install -U pytest >/dev/null 2>&1 || true
      pytest -q || true
    else
      echo "No tests detected."
    fi
  } | tee "${OUTDIR}/06_safe_checks.txt"

  deactivate || true
else
  echo "Aucun projet Python détecté (pyproject/requirements/setup). Skip venv." | tee "${OUTDIR}/06_safe_checks.txt"
fi

echo "==[7) HANDOFF CONTEXTE POUR LA SUITE (/api/state)]=="
HANDOFF="docs/handoff/COPILOT_VM102_HANDOFF_${TS}.md"
mkdir -p docs/handoff
cat > "${HANDOFF}" <<EOF
# VM102 Handoff — ${TS} (UTC)

## Rôle VM102
- **agent-runner / sandbox orchestrateur**
- Objectifs: tests, validations, découverte code, implémentation contrôlée de **/api/state**, comms agents.

## Règles (preuve-first)
- Pas de modifications sur VM100/VM101 (sauf lecture).
- Pas de secrets dans repo.
- STOP si pull non fast-forward / conflit / action destructive.

## Preuves générées
- Dossier: \\\`${OUTDIR}/\\\`
  - env: \\\`00_env.txt\\\`
  - git: \\\`01_git_*.txt\\\`
  - inventory: \\\`03_repo_inventory.txt\\\`
  - discovery: \\\`04_orchestrator_discovery_rg.txt\\\`
  - checks: \\\`06_safe_checks.txt\\\`

## Prochaine étape ciblée
1) Identifier le serveur API (fichier/entrypoint/framework) à partir de \\\`04_orchestrator_discovery_rg.txt\\\`.
2) Définir le contrat \\\`StateEnvelope\\\` (si déjà existant, réutiliser) + stratégie **merge-safe**.
3) Implémenter:
   - **GET /api/state** → renvoie l'état courant (source: replay JSONL ou store mémoire).
   - **POST /api/state** → applique un patch/merge validé, loggue un event JSONL, retourne nouvel état.
4) Ajouter un test minimal (smoke) + preuve de run dans \\\`${OUTDIR}/\\\`.

EOF

echo "Handoff écrit: ${HANDOFF}" | tee "${OUTDIR}/07_handoff_written.txt"

echo "==[8) COMMIT (local) + PUSH (optionnel)]=="
git add "${OUTDIR}" "${HANDOFF}" 2>/dev/null || true

# Commit seulement si quelque chose à commiter
if ! git diff --cached --quiet; then
  git commit -m "vm102: discovery + proofs + handoff (${TS})

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" | tee "${OUTDIR}/08_git_commit.txt"
else
  echo "Rien à commiter (déjà propre)." | tee "${OUTDIR}/08_git_commit.txt"
fi

cat <<TXT
✅ Terminé.

Si tu veux pousser sur GitHub:
  git push -u origin "${BR}"

Ensuite, colle ici (ou à Copilot) le contenu:
  - ${OUTDIR}/04_orchestrator_discovery_rg.txt
  - ${HANDOFF}
TXT
