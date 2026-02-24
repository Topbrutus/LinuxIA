# Contribuer à LinuxIA / Contributing to LinuxIA

Merci ❤️ — Contributions are welcome if they respect proof-first, deterministic behaviour.

---

## 🌿 Branch naming / Nommage des branches

| Prefix | Usage |
|--------|-------|
| `feat/` | New feature / Nouvelle fonctionnalité |
| `fix/` | Bug fix / Correction de bug |
| `docs/` | Documentation only / Documentation uniquement |
| `chore/` | Maintenance, refactor, tooling / Maintenance |
| `ci/` | CI/CD changes / Changements CI |
| `test/` | Tests only / Tests uniquement |

Examples / Exemples :
```
feat/add-health-report
fix/timer-reload-race
docs/update-runbook
chore/cleanup-scripts
```

---

## 🔍 Proof-first expectations / Attentes "preuve-first"

Every PR **must** include verifiable evidence that the change works.

**Required proofs / Preuves requises :**
- Command output / Sortie de commande (copy-paste or log file)
- `git status` snapshot before/after
- Relevant log excerpt (`journalctl`, script output, CI run URL)

**Example / Exemple :**
```bash
# Run and capture output
bash scripts/verify-platform.sh 2>&1 | tee /tmp/verify-proof.log
cat /tmp/verify-proof.log
```

---

## 🚫 No interactive scripts in automation

> Scripts used in CI, timers, or agent pipelines **must not** require user input.

Rules / Règles :
- No `read`, `select`, or interactive prompts in automated scripts
- Use explicit flags instead of interactive menus (`--yes`, `--force`, etc.)
- Provide runnable one-liners in PR descriptions, not "follow the wizard" steps

---

## ✅ PR checklist / Liste de vérification PR

Before opening a PR, confirm all of the following:

```
[ ] bash -n on all modified scripts (syntax check)
    bash -n scripts/*.sh

[ ] verify-platform passes with FAIL=0
    bash scripts/verify-platform.sh

[ ] ShellCheck passes (if available)
    shellcheck scripts/*.sh

[ ] Tests pass (if applicable)
    make test   # or the relevant test command

[ ] Health report attached or CI run linked
    (paste output or link GitHub Actions run)

[ ] No interactive prompts in automation scripts

[ ] Proof provided: logs / command output in PR description
```

---

## 🚀 Dev quickstart / Démarrage rapide

```bash
cd /opt/linuxia
bash -n scripts/*.sh          # syntax check all scripts
bash scripts/verify-platform.sh   # platform health check
```

Expected result / Résultat attendu :
```
OK >= 20
WARN >= 0
FAIL = 0
```
