---
name: Operational Change
about: Propose an operational change requiring validation (systemd, scripts, configs)
title: '[OPS] '
labels: ops, needs-validation
assignees: ''
---

## Intention
<!-- What operational change are you proposing? -->


## Justification
<!-- Why is this change needed? What problem does it solve? -->


## Proposed Changes
<!-- List specific files/services that will be modified -->

- [ ] File/Service 1:
- [ ] File/Service 2:


## Risk Assessment

### Impact Scope
<!-- Which VMs/services are affected? -->
- [ ] VM100 (Factory) - Critical control plane
- [ ] VM101 (Layer2) - Agent execution
- [ ] VM102 (Tool) - Agent tooling
- [ ] Shared mounts (shareA/shareB)
- [ ] SystemD units/timers

### Risk Level
<!-- Select one -->
- [ ] **LOW** - Documentation only, no system changes
- [ ] **MEDIUM** - Script changes, read-only operations, config updates
- [ ] **HIGH** - SystemD units, destructive operations, security changes

### Potential Failure Modes
<!-- What could go wrong? -->
1. 
2. 


## Validation Plan
<!-- How will you verify the change works? -->

```bash
# Verification commands (example)
./scripts/verify-systemd.sh
systemctl status linuxia-*.timer
```


## Rollback Plan
<!-- How will you undo this change if it fails? -->

```bash
# Rollback commands (example)
git revert <commit-hash>
sudo systemctl stop linuxia-*.timer
```


## Testing Checklist
- [ ] Changes tested on non-production system (if applicable)
- [ ] Verification commands are read-only
- [ ] Rollback plan documented and tested
- [ ] SELinux implications reviewed
- [ ] No secrets exposed


## Additional Context
<!-- Screenshots, logs, or other supporting information -->
