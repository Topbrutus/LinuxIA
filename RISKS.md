# LinuxIA — RISKS & MITIGATIONS

This document describes the primary technical and operational risks of LinuxIA (Palier 1–2),
with mitigations and existing controls.

---

## Scope

Applies to:
- Local LLM execution
- Proxmox VE host + VM Factory topology
- Bash automation scripts
- CI workflows
- Repository governance

---

## Risk Matrix

| # | Risk | Domain | Impact | Likelihood | Residual |
|---|------|--------|--------|------------|---------|
| R1 | Prompt injection / malicious instructions | LLM | High | Medium | **Low** (human gate) |
| R2 | Data exfiltration (local files) | LLM | High | Low | **Low** (.gitignore + no auto-upload) |
| R3 | VM Factory misconfiguration | Infra | Medium | Medium | **Low** (verify-platform READ-ONLY) |
| R4 | Privilege escalation (root-owned files) | Infra | Medium | Medium | **Low** (runbook + no sudo in scripts) |
| R5 | Destructive bash operation | Scripts | High | Low | **Low** (bash-n + ShellCheck CI) |
| R6 | Supply chain compromise (Actions) | CI | High | Low | **Low** (pinned official actions only) |
| R7 | Unreviewed / unapproved changes | Governance | Medium | Medium | **Low** (PR workflow + smoke CI) |

Overall posture: **Controlled / Low–Medium**

---

# 1. LLM Local Risks

## R1 — Prompt Injection / Malicious Instructions

| Field | Detail |
|-------|--------|
| **Impact** | Script execution outside intended scope; system mutation |
| **Likelihood** | Medium |
| **Mitigation** | Human approval required before any system command is run; CI is read-only; `make doctor` does not mutate state |
| **Controls** | Smoke CI (`bash -n` + ShellCheck); no auto-execution in GitHub Actions; `pour_copilot/` staging review |

---

## R2 — Data Exfiltration (Local Files)

| Field | Detail |
|-------|--------|
| **Impact** | Sensitive host data leakage (configs, credentials, logs) |
| **Likelihood** | Low–Medium |
| **Mitigation** | No automatic upload scripts; no secrets in repo; explicit paths only |
| **Controls** | `.gitignore` covers `.env`, `.env.local`, `node_modules/`, `dist/`; `SECURITY.md` defines reporting policy |

---

# 2. VM / Infrastructure Risks

## R3 — VM Factory Misconfiguration

| Field | Detail |
|-------|--------|
| **Impact** | Incorrect validation state; silent failures on VM100/101/102 |
| **Likelihood** | Medium |
| **Mitigation** | `verify-platform.sh` (READ-ONLY); `make doctor` as primary entry point; architecture documented |
| **Controls** | `docs/architecture.md`; smoke CI validates syntax on every PR; timers write timestamped proofs to `logs/health/` |

---

## R4 — Privilege Escalation (Root-Owned Files)

| Field | Detail |
|-------|--------|
| **Impact** | CI or script failure; git operations blocked; unintended root execution |
| **Likelihood** | Medium (has occurred: `.git/objects` root-owned) |
| **Mitigation** | Avoid `sudo` in repo scripts; restrict to `sudo -i` only when documented; fix ownership promptly |
| **Controls** | `docs/runbook.md` — exit 126 section with ownership fix commands; read-only CI cannot escalate |

---

# 3. Script Safety Risks

## R5 — Destructive Bash Operation

| Field | Detail |
|-------|--------|
| **Impact** | Data loss; irreversible filesystem changes |
| **Likelihood** | Low |
| **Mitigation** | Scripts are verification-oriented by design; `verify-platform.sh` explicitly marked READ-ONLY; `bash -n` + ShellCheck on every PR |
| **Controls** | `.github/workflows/smoke-verify.yml`; `make lint` (local); `ci.yml` (ShellCheck `--severity=warning`) |

---

# 4. CI / Supply Chain Risks

## R6 — Dependency / Supply Chain Compromise

| Field | Detail |
|-------|--------|
| **Impact** | Malicious workflow execution; secrets exfiltration; repo poisoning |
| **Likelihood** | Low |
| **Mitigation** | Official GitHub actions only (`actions/checkout@v4`); no third-party actions; no deploy pipelines; no secrets stored in workflow env |
| **Controls** | Minimal CI surface (2 workflows); no `GITHUB_TOKEN` write permissions granted; no npm publish or deploy steps |

---

# 5. Governance Risks

## R7 — Unreviewed / Unapproved Changes

| Field | Detail |
|-------|--------|
| **Impact** | Regressions; undocumented state changes; loss of proof chain |
| **Likelihood** | Medium |
| **Mitigation** | PR-based workflow enforced; smoke CI blocks merging broken scripts; proof required in PR body |
| **Controls** | `.github/ISSUE_TEMPLATE/` (proof-first templates); `CONTRIBUTING.md`; `CODE_OF_CONDUCT.md`; squash merge keeps history clean |

---

# Residual Risk Level

**Overall: Controlled / Low–Medium**

LinuxIA is designed as:
- **Verification-first** — scripts check state, they do not change it
- **Read-only by default** — `make doctor`, `verify-platform.sh`, smoke CI
- **Explicit execution required** — no auto-apply; human validates before any system mutation
- **Proof chain mandatory** — every PR requires command + output in the body

---

# Future Hardening (Palier 3+)

| Item | Benefit |
|------|---------|
| Commit signing enforcement (`vigilant` mode) | Prevents unsigned commits on main |
| Branch protection rules (require CI + review) | Blocks direct pushes to main |
| SBOM / dependency scanning | Surfaces supply chain issues |
| Automated permission scan (root-owned files) | Catches `.git/objects` ownership drift |
| LLM output sandboxing | Isolates agent proposals from live system |
| Secret scanning (Gitleaks / truffleHog) | Detects accidental credential commits |
