## What
<!-- Describe WHAT is changing in this PR (technical changes) -->


## Why
<!-- Explain WHY this change is needed (business/operational justification) -->


## How to Test
<!-- Provide step-by-step commands to verify this change works -->

```bash
# Example verification commands (replace with actual)
cd /opt/linuxia
./scripts/verify-systemd.sh
```


## Rollback Plan
<!-- Describe how to undo this change if it causes problems -->

```bash
# Example rollback (replace with actual)
git revert <commit-hash>
# OR
git checkout <previous-commit> -- <files>
```


## Checklist
- [ ] Changes follow repo conventions (scripts executable, no `echo` in scripts)
- [ ] Documentation updated (if applicable)
- [ ] Verification commands tested locally
- [ ] Rollback plan documented and tested
- [ ] No secrets committed
- [ ] SELinux implications considered (if touching files/mounts)
- [ ] Related GitHub Issue linked (if exists)


## Risk Assessment
<!-- Rate risk: LOW / MEDIUM / HIGH and justify -->

**Risk Level**: 

**Justification**:


## Additional Notes
<!-- Any other context, screenshots, or information -->
