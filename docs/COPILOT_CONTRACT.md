# Copilot Contract - LinuxIA AI-Assisted Operations

## Purpose
This document establishes rules and expectations for AI-assisted operations in the LinuxIA project. It ensures that AI tools (GitHub Copilot, ChatGPT, etc.) augment human decision-making without compromising safety, security, or operational integrity.

---

## Core Principles

### 1. Human-in-the-Loop (Non-Negotiable)
**AI proposes, human validates and executes.**

- AI must **NEVER** execute commands automatically
- Every proposed action requires explicit human approval
- Destructive operations require additional confirmation
- Humans retain full responsibility for all actions

### 2. Proof-First Methodology
Every AI-proposed change must include:

1. **Verification commands** (read-only) to validate the change
2. **Rollback plan** with explicit commands to undo the change
3. **Risk assessment** (LOW/MEDIUM/HIGH)
4. **Testing checklist** completed before production deployment

### 3. Transparency and Traceability
- AI-assisted commits include `Co-authored-by: Copilot <...>` trailer
- AI cannot suppress warnings or errors without disclosure
- All AI recommendations must be auditable (captured in Issues/PRs)

---

## AI Operational Rules

### Commands and Scripts

**✅ AI MAY:**
- Propose commands with explanations
- Suggest script improvements
- Recommend best practices
- Provide read-only verification commands

**❌ AI MUST NOT:**
- Execute commands without explicit user confirmation
- Use `rm -rf`, `dd`, or other destructive commands without PROMINENT warnings
- Modify production systemd units without review
- Auto-commit or auto-push to Git
- Suppress error messages or return codes

### Example: Acceptable AI Response
```markdown
**Proposed Change:**
Create a new systemd timer for daily cleanup.

**Commands to Execute (DO NOT RUN YET):**
```bash
sudo cp services/linuxia-cleanup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now linuxia-cleanup.timer
```

**Verification:**
```bash
systemctl status linuxia-cleanup.timer
systemctl list-timers | grep cleanup
```

**Rollback:**
```bash
sudo systemctl disable --now linuxia-cleanup.timer
sudo rm /etc/systemd/system/linuxia-cleanup.timer
sudo systemctl daemon-reload
```

**Risk:** MEDIUM - Creates new timer but no data modification
```

---

## Mandatory Warning Blocks

When AI proposes operations with risk, it MUST include an **ATTENTION** block:

### Template: ATTENTION Block
```markdown
⚠️ **ATTENTION**
**Risk Level:** [LOW/MEDIUM/HIGH]
**Destructive Potential:** [YES/NO]
**Reversibility:** [FULLY REVERSIBLE / PARTIALLY REVERSIBLE / IRREVERSIBLE]

**What could go wrong:**
- [List specific failure modes]
- [Include worst-case scenarios]

**Mitigation:**
- [Steps to reduce risk]
- [Backup/snapshot recommendations]
```

### Example: ATTENTION for Destructive Operation
```markdown
⚠️ **ATTENTION**
**Risk Level:** HIGH
**Destructive Potential:** YES
**Reversibility:** IRREVERSIBLE

**What could go wrong:**
- Deletes all config snapshots older than 7 days (permanent data loss)
- May remove snapshots needed for compliance/audit
- Cannot be undone once executed

**Mitigation:**
- Run with `--dry-run` first to review what would be deleted
- Verify backup retention policy compliance before execution
- Consider archiving to secondary storage before deletion
- Execute during maintenance window with team awareness

**Recommended First Step:**
```bash
# DRY RUN (safe, no changes)
./scripts/backup-configsnap-retention.sh --dry-run --keep-days 7
```
```

---

## Validation Commands

All AI-proposed changes must include validation commands that are:
- **Read-only** (no side effects)
- **Explicit** (clear what is being checked)
- **Copy-pasteable** (user can run directly)

### Example: Good Validation Commands
```bash
# Verify timer is enabled
systemctl is-enabled linuxia-configsnap.timer

# Check timer next run time
systemctl list-timers linuxia-configsnap.timer

# Verify service runs successfully
sudo systemctl start linuxia-configsnap.service
systemctl status linuxia-configsnap.service
journalctl -u linuxia-configsnap.service -n 20 --no-pager
```

### Example: Bad Validation (Missing Details)
```bash
# ❌ Too vague
systemctl status linuxia-*

# ❌ No explanation of expected output
./scripts/verify-systemd.sh
```

---

## Rollback Requirements

Every change must have a documented rollback plan with:
1. **Exact commands** to reverse the change
2. **Verification** that rollback succeeded
3. **Dependencies** (what needs to be rolled back together)

### Example: Comprehensive Rollback
```markdown
**Rollback Plan:**

**Step 1: Stop and disable timer**
```bash
sudo systemctl stop linuxia-cleanup.timer
sudo systemctl disable linuxia-cleanup.timer
```

**Step 2: Remove unit files**
```bash
sudo rm /etc/systemd/system/linuxia-cleanup.{timer,service}
sudo systemctl daemon-reload
```

**Step 3: Verify removal**
```bash
systemctl list-unit-files | grep linuxia-cleanup
# Expected: No output

systemctl list-timers | grep cleanup
# Expected: No output
```

**Step 4: Revert Git changes**
```bash
cd /opt/linuxia
git revert <commit-hash>
git push
```
```

---

## GitHub Workflow Integration

### Issues
When AI suggests creating a GitHub Issue:
- Use appropriate template (e.g., `ops_change.md`)
- Include risk assessment
- Provide validation plan
- Document rollback strategy

### Pull Requests
AI-assisted PRs must include:
- Clear "What/Why/How to Test" sections
- Rollback plan in PR description
- Risk assessment completed
- All checklist items addressed

**AI must NOT:**
- Auto-merge PRs
- Skip required reviews
- Bypass CI/CD checks

---

## Code Quality Standards

### Shell Scripts
AI-generated shell scripts must:
- Use `set -euo pipefail` for robustness
- Avoid `echo` commands (per repo convention)
- Be idempotent (safe to run multiple times)
- Include usage/help output

### Documentation
AI-generated documentation must:
- Be in Markdown format
- Use consistent formatting (headings, code blocks, lists)
- Include examples with actual commands
- Avoid placeholders (e.g., `<your-value-here>`) unless necessary

---

## Secrets and Sensitive Data

### Absolute Prohibitions
AI must **NEVER**:
- Commit secrets to Git (even in examples)
- Display passwords, API keys, or tokens in output
- Store credentials in plain text scripts
- Include secrets in commit messages or PR descriptions

### Detection and Prevention
When AI suggests code/config, it must:
1. Scan for potential secrets (regex for common patterns)
2. Warn if sensitive data detected
3. Suggest using environment variables or secret management tools

### Example: Safe Credential Handling
```bash
# ❌ NEVER do this
API_KEY="sk-abcdef123456"

# ✅ Use environment variable
API_KEY="${LINUXIA_API_KEY:-}"
if [[ -z "$API_KEY" ]]; then
    echo "Error: LINUXIA_API_KEY not set" >&2
    exit 1
fi

# ✅ Or load from secure file
if [[ -f ~/.linuxia/secrets ]]; then
    source ~/.linuxia/secrets
fi
```

---

## Testing and Validation Workflow

### AI-Assisted Change Process
1. **AI Proposes** → Draft PR with full details
2. **Human Reviews** → Validates logic, security, rollback
3. **Human Tests** → Executes validation commands in test environment
4. **Human Approves** → Explicit "proceed" before production
5. **Human Executes** → Runs commands in production
6. **Human Verifies** → Confirms success with validation commands

### Checklist Before Production
- [ ] AI proposal reviewed for security risks
- [ ] Validation commands tested (read-only)
- [ ] Rollback plan tested in non-production environment
- [ ] ATTENTION block reviewed if present
- [ ] No secrets in proposed code/config
- [ ] Git commit message includes Co-authored-by trailer
- [ ] Related Issue/PR created and linked

---

## Handling AI Errors

### When AI Makes Mistakes
AI errors are expected and acceptable IF:
1. Human catches the error before execution
2. Error is documented for learning
3. Correction is proposed and validated

**Example: AI Error Documentation**
```markdown
**AI Mistake:** Proposed `rm -rf /opt/linuxia/data/*` without dry-run option

**Risk:** HIGH - Would delete all data irreversibly

**Correction:** Add `--dry-run` flag and explicit confirmation prompt

**Lesson:** Always require dry-run for destructive operations on data directories
```

### AI Uncertainty
When AI is uncertain, it must explicitly state:
- "I'm not certain about [X]"
- "This may vary depending on [Y]"
- "Please verify [Z] before proceeding"

AI must **NOT** fill gaps with assumptions that could cause harm.

---

## Continuous Improvement

### Feedback Loop
- Document AI-assisted wins and failures in Issues
- Update this contract based on lessons learned
- Share learnings across team

### Contract Updates
This document is versioned in Git and updated as needed:
- Minor clarifications: Direct commit to main
- Major policy changes: PR with review required

---

## Enforcement

### Human Responsibility
Humans are ultimately responsible for:
- Reading and understanding AI proposals
- Validating safety and correctness
- Executing commands with full awareness
- Rolling back failed changes

### AI Accountability
AI tools must adhere to this contract. Violations to report:
- Auto-execution without consent
- Missing ATTENTION blocks for risky operations
- Secrets exposed in proposals
- Incomplete rollback plans

---

## Quick Reference: AI Do's and Don'ts

### ✅ DO
- Propose commands with full context
- Include verification and rollback steps
- Use ATTENTION blocks for risky operations
- Suggest best practices and alternatives
- Document assumptions and uncertainties
- Add Co-authored-by trailers to commits

### ❌ DON'T
- Execute commands automatically
- Hide errors or warnings
- Commit secrets to Git
- Skip validation or rollback plans
- Make assumptions about critical configurations
- Auto-merge or auto-push without approval

---

## Signature
By using AI assistance in LinuxIA, you acknowledge:
1. You have read and understood this contract
2. You will validate all AI proposals before execution
3. You accept full responsibility for AI-assisted actions
4. You will report violations or improvements to this contract

**Contract Version:** 1.0  
**Last Updated:** 2026-02-16  
**Review Frequency:** Quarterly or as needed
