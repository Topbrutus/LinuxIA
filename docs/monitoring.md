# LinuxIA — Monitoring

## Daily (automated)
- configsnap timer runs successfully
- healthcheck timer runs successfully

## Weekly (manual, read-only)
```bash
cd /opt/linuxia
bash scripts/verify-systemd.sh
bash scripts/verify-platform.sh
bash scripts/health-report.sh
```

## Monthly (manual)
- Review `docs/COPILOT_CONTRACT.md`
- Validate backup/restore procedure (sample)
- Review logs (errors/security) and update runbook if needed
