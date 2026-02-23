# 🚀 Start Here — LinuxIA in 15 Minutes

> **Audience**: new contributors, ops on VM100, or anyone who just cloned this repo.

---

## What is LinuxIA?

LinuxIA is a **proof-first, multi-agent infrastructure ops platform** running on Proxmox VE.

- Every script generates a timestamped log entry before and after it runs.
- AI agents (TriluxIA) propose actions — humans validate via the `pour_copilot/` workflow.
- The platform spans 3 VMs (VM100 Factory, VM101 Layer2, VM102 Tool) and a Proxmox host.

Key rule: **no silent changes**. If a script modifies the system, it writes a proof.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Proxmox VE host | `ssh root@192.168.1.128` |
| VM100 Factory | `ssh gaby@192.168.1.135` — main ops VM |
| Git access | `git@github.com:Topbrutus/LinuxIA.git` |
| Repo clone path | `/opt/linuxia` on VM100 |
| Bash ≥ 4.x | pre-installed on openSUSE |

---

## Quickstart (3 commands)

```bash
cd /opt/linuxia

# 1 — Check all scripts are syntactically valid
make syntax

# 2 — Run platform doctor (READ-ONLY — does not write anything)
make doctor

# 3 — Run full lint (bash -n + shellcheck warnings)
make lint
```

Expected output from `make doctor`:
```
  bash -n OK  scripts/verify-platform.sh
  [summary: OK / WARN / FAIL with timestamped log in logs/health/]
```

If you see `FAIL`: check `logs/health/` for details, then open an issue.

---

## Repository layout (quick map)

```
/opt/linuxia/
├── scripts/          # All runnable scripts (verify-platform, ci, healthcheck…)
├── docs/             # Runbooks, architecture, this file
├── .github/
│   ├── workflows/    # CI: ci.yml (ShellCheck) + smoke-verify.yml
│   └── ISSUE_TEMPLATE/
├── assets/readme/    # SVGs, gallery, media (README visuals)
├── services/         # systemd unit files
├── logs/             # Append-only operation logs (not committed)
└── Makefile          # Entry point: make help | doctor | lint | syntax
```

→ Full inventory: [`docs/INVENTORY.md`](INVENTORY.md)  
→ Architecture diagram: [`docs/architecture.md`](architecture.md)

---

## How to contribute in 15 minutes

1. Pick a [`good first issue`](https://github.com/Topbrutus/LinuxIA/issues?q=label%3A%22good+first+issue%22)
2. Read [`CONTRIBUTING.md`](../CONTRIBUTING.md)
3. Create a branch: `git checkout -b fix/my-fix`
4. Make your change; run `make lint` — it must pass
5. Open a PR with proof (command + output in the PR body)
6. Squash merge → done

**Proof-first rule**: every PR must include the terminal output of the change it claims to make.  
Example: if you fix a script, paste `bash -n scripts/myscript.sh` output in the PR.

---

## Useful one-liners

```bash
# See all available make targets
make help

# SSH to VM100 and run doctor
ssh gaby@192.168.1.135 "cd /opt/linuxia && make doctor"

# Check systemd timers
ssh gaby@192.168.1.135 "systemctl list-timers linuxia-*"

# View latest health log
ls -lt /opt/linuxia/logs/health/ | head -5

# Tail CI logs on last push
gh run list --repo Topbrutus/LinuxIA --limit 3
gh run view --repo Topbrutus/LinuxIA --log
```

---

## Stuck?

- Runtime errors → [`docs/runbook.md`](runbook.md)
- Security issues → [`SECURITY.md`](../SECURITY.md)
- Questions → [GitHub Discussions](https://github.com/Topbrutus/LinuxIA/discussions) or open an issue
