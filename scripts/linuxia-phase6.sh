#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/opt/linuxia}"
BRANCH_DEFAULT="${BRANCH_DEFAULT:-chore/phase6-healthchecks}"
COMMIT_DEFAULT="${COMMIT_DEFAULT:-chore: document and verify health-report outputs}"

# files we may edit in this phase
PHASE_FILES=(
  "scripts/verify-platform.sh"
  "docs/runbook.md"
)

say(){ printf "%s\n" "$*"; }
hr(){ printf "%s\n" "------------------------------------------------------------"; }
die(){ printf "ERROR: %s\n" "$*" >&2; exit 1; }

confirm() {
  local prompt="${1:-Continue?}"
  read -r -p "$prompt [y/N] " ans || true
  [[ "${ans:-}" == "y" || "${ans:-}" == "Y" ]]
}

need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"; }
gitc(){ git -C "$REPO_DIR" "$@"; }

ensure_vm100(){
  hr
  say "Host check (proof)"
  local h
  h="$(hostname || true)"
  say "hostname=$h"
  date -Is || true
  if [[ "$h" != "vm100-factory" ]]; then
    die "Not on vm100-factory. STOP. (Current: $h)"
  fi
  hr
}

ensure_repo(){
  [[ -d "$REPO_DIR" ]] || die "Repo dir not found: $REPO_DIR"
  git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not a git repo: $REPO_DIR"
}

show_git_state(){
  hr
  say "Git state (read-only)"
  gitc status || true
  say "branch=$(gitc branch --show-current 2>/dev/null || echo '?')"
  gitc remote -v || true
  hr
}

assert_clean_or_stop(){
  if [[ -n "$(gitc status --porcelain)" ]]; then
    say "STOP: working tree is NOT clean."
    say "Run: git status && git diff --name-only"
    exit 3
  fi
}

backup_file(){
  local f="$1"
  local src="$REPO_DIR/$f"
  [[ -f "$src" ]] || return 0
  local bak
  bak="/tmp/$(basename "$f").bak.$(date +%Y%m%d-%H%M%S)"
  cp -a "$src" "$bak"
  say "Backup: $f -> $bak"
}

patch_verify_platform_health_section(){
  local target="$REPO_DIR/scripts/verify-platform.sh"
  [[ -f "$target" ]] || die "Missing file: scripts/verify-platform.sh"

  backup_file "scripts/verify-platform.sh"

  python3 - <<'PY'
from pathlib import Path
import re

p = Path("/opt/linuxia/scripts/verify-platform.sh")
s = p.read_text(encoding="utf-8")

marker = "## HEALTH_REPORT_CHECKS_BEGIN"
if marker in s:
    print("OK: Health report checks already present; no change.")
    raise SystemExit(0)

# Try to insert after the "Configsnap archives" section header in the script code.
# If not found, append near the end before "=== Summary ===" output block.
insert_block = r'''
# ----------------------------
# Health report checks (WARN)
# ----------------------------
## HEALTH_REPORT_CHECKS_BEGIN
HEALTH_LOG_DIR="${HEALTH_LOG_DIR:-/opt/linuxia/logs/health}"
HEALTH_SHARE_DIR="${HEALTH_SHARE_DIR:-/opt/linuxia/data/shareA/reports/health}"
HEALTH_GLOB="${HEALTH_GLOB:-health-*.txt}"
HEALTH_MAX_AGE_SECONDS="${HEALTH_MAX_AGE_SECONDS:-172800}"  # 48h

health_checks() {
  section "Health reports"
  if [[ ! -d "$HEALTH_LOG_DIR" ]]; then
    warn "Health log dir missing: $HEALTH_LOG_DIR"
    bump_warn
    return 0
  fi

  local latest=""
  latest="$(ls -1t "$HEALTH_LOG_DIR"/$HEALTH_GLOB 2>/dev/null | head -n 1 || true)"

  if [[ -z "$latest" ]]; then
    warn "No health reports found in $HEALTH_LOG_DIR"
    bump_warn
  else
    ok "Latest health report: $latest"
    # age check (WARN if too old)
    if command -v stat >/dev/null 2>&1; then
      local now ts age
      now="$(date +%s)"
      ts="$(stat -c %Y "$latest" 2>/dev/null || echo 0)"
      if [[ "$ts" =~ ^[0-9]+$ ]] && [[ "$ts" -gt 0 ]]; then
        age="$((now - ts))"
        if (( age > HEALTH_MAX_AGE_SECONDS )); then
          warn "Health report older than threshold: age=${age}s > ${HEALTH_MAX_AGE_SECONDS}s"
          bump_warn
        fi
      fi
    fi
  fi

  # Share copy check (WARN only)
  if [[ -d "$HEALTH_SHARE_DIR" ]]; then
    local share_latest=""
    share_latest="$(ls -1t "$HEALTH_SHARE_DIR"/$HEALTH_GLOB 2>/dev/null | head -n 1 || true)"
    if [[ -z "$share_latest" ]]; then
      warn "No health reports found in share dir: $HEALTH_SHARE_DIR"
      bump_warn
    else
      ok "Latest shareA health report: $share_latest"
      # Best-effort name match check
      if [[ -n "$latest" ]]; then
        if [[ "$(basename "$latest")" == "$(basename "$share_latest")" ]]; then
          ok "Share copy matches latest filename"
        else
          warn "Share latest filename differs from local latest (may still be OK)"
          bump_warn
        fi
      fi
    fi
  else
    warn "Share health dir missing (skip copy check): $HEALTH_SHARE_DIR"
    bump_warn
  fi
}
## HEALTH_REPORT_CHECKS_END
'''.lstrip("\n")

# We need to ensure the script has helper functions section()/ok()/warn()/bump_warn.
# We'll insert a call to health_checks() in main flow by finding "Configsnap archives" section call
# OR fallback: insert before "Optional mounts" section header if present.

# Find a stable insertion point for calling health_checks:
# Prefer inserting right after configsnap checks output block in main sequence.
call_inserted = False

# Common header lines in this script's output:
# "Configsnap archives" then later "Optional mounts"
# We'll inject health_checks() call just before "Optional mounts" if possible.

# Insert the function block near other function definitions:
# Place it right after OPTIONAL_PATHS array, which is easy to locate.
m = re.search(r'^\)\s*$\n\n# Critical paths', s, flags=re.M)
if not m:
    # fallback: after OPTIONAL_PATHS array close
    m2 = re.search(r'^\)\s*$\n\n# ----------------------------\n# Helper functions', s, flags=re.M)
    if m2:
        insert_at = m2.start()
        s = s[:insert_at] + "\n" + insert_block + "\n" + s[insert_at:]
    else:
        # ultimate fallback: append near top after arrays
        s = insert_block + "\n\n" + s
else:
    insert_at = m.start()
    s = s[:insert_at] + "\n" + insert_block + "\n" + s[insert_at:]

# Now insert a call to health_checks() in main() flow.
# Find "Optional mounts" output header line inside script (code), not runtime.
# We'll search for the exact printed section label "Optional mounts".
m_call = re.search(r'section\s+"Optional mounts"', s)
if m_call:
    # Insert just before it
    insert_at = m_call.start()
    s = s[:insert_at] + '  health_checks\n\n  ' + s[insert_at:]
    call_inserted = True

if not call_inserted:
    # fallback: before network listeners section
    m_call2 = re.search(r'section\s+"Network listeners', s)
    if m_call2:
        insert_at = m_call2.start()
        s = s[:insert_at] + '  health_checks\n\n  ' + s[insert_at:]
        call_inserted = True

if not call_inserted:
    # fallback: before summary printing (look for "=== Summary ===")
    m_call3 = re.search(r'echo\s+"=== Summary ==="', s)
    if m_call3:
        insert_at = m_call3.start()
        s = s[:insert_at] + '  health_checks\n\n  ' + s[insert_at:]
        call_inserted = True

p.write_text(s, encoding="utf-8")
print("OK: inserted health report checks into verify-platform.sh")
PY

  # Quick syntax check (read-only)
  bash -n "$target" || die "Syntax error after patch: scripts/verify-platform.sh"
  say "OK: bash -n scripts/verify-platform.sh"
}

patch_runbook_health_section(){
  local target="$REPO_DIR/docs/runbook.md"
  [[ -f "$target" ]] || die "Missing file: docs/runbook.md"

  backup_file "docs/runbook.md"

  python3 - <<'PY'
from pathlib import Path

p = Path("/opt/linuxia/docs/runbook.md")
s = p.read_text(encoding="utf-8")

marker = "## Health report (daily)"
if marker in s:
    print("OK: runbook already has Health report section; no change.")
    raise SystemExit(0)

block = r'''
## Health report (daily)

LinuxIA generates a read-only diagnostics report daily via systemd.

### Run now (manual)
```bash
sudo systemctl start linuxia-health-report.service
sudo systemctl status linuxia-health-report.service --no-pager -l
sudo journalctl -u linuxia-health-report.service -n 120 --no-pager
```

### Where reports are stored

* Local: `/opt/linuxia/logs/health/`
* ShareA copy (best-effort): `/opt/linuxia/data/shareA/reports/health/`

### Notes

* Some share mounts may not support `chmod` (permissions may appear as executable on share). This is not a functional issue.
* Retention (if enabled): `bash scripts/health-retention.sh`
'''.lstrip("\n")

# Insert block near troubleshooting section if exists; else append at end.

needle = "## Troubleshooting"
idx = s.find(needle)
if idx != -1:
    insert_at = idx
    s2 = s[:insert_at] + block + "\n\n" + s[insert_at:]
else:
    s2 = s.rstrip() + "\n\n" + block + "\n"

p.write_text(s2, encoding="utf-8")
print("OK: added Health report section to docs/runbook.md")
PY
}

run_proof_tests_optional(){
  hr
  say "Optional proof tests (read-only + sudo only if you confirm)"
  if ! confirm "Run sudo-based proof (start service + status + list files)?"; then
    say "Skipped sudo proof tests."
    hr
    return 0
  fi

  need_cmd sudo
  sudo -v || die "sudo auth failed"

  say "== Start service now =="
  sudo systemctl start linuxia-health-report.service || true

  say "== Status =="
  sudo systemctl status linuxia-health-report.service --no-pager -l || true

  say "== Latest local report =="
  ls -lt /opt/linuxia/logs/health 2>/dev/null | head -n 5 || true

  say "== Latest share report =="
  ls -lt /opt/linuxia/data/shareA/reports/health 2>/dev/null | head -n 5 || true

  say "== verify-platform =="
  bash "$REPO_DIR/scripts/verify-platform.sh"; echo "exit_code=$?"
  hr
}

commit_push_guided(){
  hr
  say "Commit/push guided (NO add -A)"
  local changed
  changed="$(gitc diff --name-only || true)"
  if [[ -z "$changed" ]]; then
    say "No changes to commit."
    hr
    return 0
  fi

  say "Changed files:"
  printf "%s\n" "$changed" | sed 's/^/  - /'
  say

  local to_add=()
  for f in "${PHASE_FILES[@]}"; do
    [[ -n "$(gitc diff --name-only -- "$f" 2>/dev/null || true)" ]] && to_add+=("$f")
  done

  if ((${#to_add[@]} == 0)); then
    say "No phase files detected as changed (unexpected)."
    hr
    return 0
  fi

  say "Will stage (targeted):"
  for f in "${to_add[@]}"; do say "  - $f"; done

  if confirm "Stage these files now?"; then
    gitc add "${to_add[@]}"
    gitc status
  else
    say "Skipped staging."
    hr
    return 0
  fi

  local msg="$COMMIT_DEFAULT"
  say
  say "Commit message default:"
  say "  $msg"
  if confirm "Commit with default message?"; then
    gitc commit -m "$msg"
  else
    read -r -p "Enter commit message: " msg2
    [[ -n "${msg2:-}" ]] || die "Empty commit message."
    gitc commit -m "$msg2"
  fi

  if confirm "Push now (git push)?"; then
    gitc push
    say "OK pushed."
  else
    say "Skipped push."
  fi
  hr
}

maybe_create_branch(){
  hr
  say "Branch (optional)"
  local cur
  cur="$(gitc branch --show-current)"
  say "current_branch=$cur"
  say "default_new_branch=$BRANCH_DEFAULT"
  if ! confirm "Create/switch to a Phase 6 branch?"; then
    say "Staying on current branch."
    hr
    return 0
  fi

  read -r -p "Branch name (Enter=default): " b || true
  b="${b:-$BRANCH_DEFAULT}"

  if [[ "$b" == "$cur" ]]; then
    say "Already on $b"
    hr
    return 0
  fi

  if confirm "Checkout new branch '$b'?"; then
    gitc checkout -b "$b"
    say "Now on: $(gitc branch --show-current)"
  else
    say "Skipped branch creation."
  fi
  hr
}

main(){
  need_cmd git
  need_cmd python3
  ensure_vm100
  ensure_repo

  show_git_state
  assert_clean_or_stop

  maybe_create_branch

  hr
  say "PHASE 6: patch verify-platform + runbook"
  hr
  say "About to edit:"
  for f in "${PHASE_FILES[@]}"; do say "  - $f"; done

  if ! confirm "Proceed with file patches?"; then
    say "Aborted by user."
    exit 0
  fi

  patch_verify_platform_health_section
  patch_runbook_health_section

  hr
  say "Diff preview (first 120 lines)"
  gitc diff -- "${PHASE_FILES[@]}" | sed -n '1,120p' || true
  hr

  say "Run verify-platform now (read-only)?"
  if confirm "Run: bash scripts/verify-platform.sh"; then
    bash "$REPO_DIR/scripts/verify-platform.sh"; echo "exit_code=$?"
  else
    say "Skipped verify-platform run."
  fi

  run_proof_tests_optional

  commit_push_guided

  show_git_state
  say "Phase 6 complete."
}

main "$@"
