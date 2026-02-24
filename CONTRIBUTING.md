# Contributing to LinuxIA

Thanks for helping! 🚀

## Proof-First Principles

1. **Every change generates proof** (timestamped logs/outputs)
2. **Non-destructive** (scripts have guards: `STOP if...`)
3. **Shellcheck clean** (`bash -n` + `shellcheck -x`)
4. **Git flow:** branch → PR → CI → squash merge

## Quick Start

### 1. Fork & Clone

```bash
git clone git@github.com:<you>/LinuxIA.git
cd LinuxIA
git remote add upstream git@github.com:Topbrutus/LinuxIA.git
```

### 2. Create Branch

```bash
git checkout -b feat/my-feature
# or: fix/bug-name, docs/improve, chore/cleanup
```

### 3. Test Locally

```bash
# Syntax check
bash -n scripts/my-script.sh

# Platform verification
bash scripts/verify-platform.sh
```

### 4. Commit

Format: `type: short description`

Types: `feat`, `fix`, `docs`, `chore`, `ci`, `test`

```bash
git add .
git commit -m "feat: add awesome feature

- detail 1
- detail 2

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

### 5. Push + PR

```bash
git push -u origin feat/my-feature
gh pr create --base main --title "feat: add awesome feature"
```

### 6. After Merge

```bash
git checkout main
git pull upstream main
git branch -d feat/my-feature
```

## Standards

### Bash Scripts

- Shebang: `#!/usr/bin/env bash`
- Options: `set -euo pipefail`
- No `echo` in automated scripts (use logs/journald)
- Shellcheck warnings OK if justified with `# shellcheck disable=...`

### Proofs

Stored in `docs/verifications/<name>_<timestamp>.txt`

### Tests

- Add tests if possible (`tests/`)
- Minimum: smoke test (`bash -n`, `--version`)

## Good First Issues

Look for label [`good first issue`](https://github.com/Topbrutus/LinuxIA/labels/good%20first%20issue)

Typical tasks:
- Documentation improvements
- Shellcheck warning fixes
- Add test coverage
- Improve runbook examples

## Questions?

- Open an [issue](https://github.com/Topbrutus/LinuxIA/issues)
- Check [docs/runbook.md](docs/runbook.md)

Thanks! 🎉
