# Security Policy

## Supported Versions

Security fixes are provided for the following versions:

| Version / Branch | Supported |
|------------------|-----------|
| `main` (latest)  | ✅ Yes     |
| Latest release   | ✅ Yes     |
| Older releases   | ❌ No      |

## Reporting a Vulnerability

Please do **not** open a public issue for security vulnerabilities.

**Preferred:** Use [GitHub Security Advisories](https://github.com/Topbrutus/LinuxIA/security/advisories/new) to report privately.  
**Fallback:** Contact the maintainer via GitHub Discussions (private message) if Security Advisories are unavailable.

Please include:
- A description of the vulnerability and its potential impact
- Steps to reproduce the issue
- Any suggested mitigations (optional)

## Scope

**In scope:**
- Scripts and tooling in `/scripts/`
- `systemd` units and timers in `/services/`
- CI/CD workflows in `.github/workflows/`
- Documentation that may cause unsafe operations if followed
- VM Factory verification tooling

**Out of scope:**
- Third-party dependencies and external infrastructure not maintained here
- The underlying Proxmox/openSUSE/Linux platform itself

## Response Expectations

This project is maintained on a **best-effort** basis:

- Reports will be acknowledged as quickly as possible (typically within a few days).
- Fixes will be prioritized according to severity.
- There are no guaranteed SLAs — this is an experimental research project.

We appreciate responsible disclosure and will credit reporters (unless they prefer to remain anonymous).
