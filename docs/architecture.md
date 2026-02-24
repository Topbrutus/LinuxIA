# 🏗️ LinuxIA — Architecture

> High-level map of the platform: VMs, data flows, scripts, and CI.

---

## Infrastructure Overview

```mermaid
graph TD
    PVE["🖥️ Proxmox VE Host<br/>192.168.1.128"]

    PVE --> VM100["VM100 Factory<br/>192.168.1.135<br/>(main ops, /opt/linuxia)"]
    PVE --> VM101["VM101 Layer2<br/>192.168.1.136"]
    PVE --> VM102["VM102 Tool<br/>192.168.1.137"]

    subgraph VM100_internals["VM100 — Factory (openSUSE)"]
        SCRIPTS["scripts/<br/>verify-platform.sh<br/>linuxia-healthcheck.sh<br/>ci.sh …"]
        TIMERS["systemd timers<br/>linuxia-*.timer"]
        LOGS["logs/health/<br/>logs/reports/<br/>(append-only)"]
        SHARES["data/shareA<br/>data/shareB<br/>(bind mounts)"]
    end

    VM100 --> VM100_internals
    SCRIPTS -->|writes proof| LOGS
    TIMERS -->|triggers| SCRIPTS
    SCRIPTS -->|archived configs| SHARES
```

---

## Scripts → Logs Flow

```mermaid
sequenceDiagram
    participant Timer as systemd timer
    participant Script as scripts/*.sh
    participant Log as logs/health/
    participant Share as data/shareA/archives/

    Timer->>Script: trigger (scheduled)
    Script->>Script: run checks (READ-ONLY)
    Script->>Log: write timestamped proof
    Script-->>Share: configsnap archive (if changed)
    Script-->>GitHub: push log summary (optional)
```

---

## Timers / Services → Output Paths

```mermaid
graph LR
    T1["⏱ linuxia-configsnap.timer<br/>daily 03:00"]
    T2["⏱ linuxia-healthcheck.timer<br/>daily 03:05"]
    T3["⏱ linuxia-health-report.timer<br/>daily 03:10"]

    S1["⚙ linuxia-configsnap.service"]
    S2["⚙ linuxia-healthcheck.service"]
    S3["⚙ linuxia-health-report.service"]

    A1["/opt/linuxia/data/shareA/<br/>archives/configsnap/"]
    A2["/opt/linuxia/docs/<br/>STATE_HEALTHCHECK.md"]
    A3["/opt/linuxia/logs/health/<br/>(local report)"]
    A4["/opt/linuxia/data/shareA/<br/>reports/health/<br/>(shareA copy)"]

    T1 --> S1 --> A1
    T2 --> S2 --> A2
    T3 --> S3 --> A3
    T3 --> S3 --> A4
```

---

## CI / GitHub Actions

```mermaid
graph LR
    PR["Pull Request / Push"] --> CI1["ci.yml<br/>bash -n + ShellCheck"]
    PR --> CI2["smoke-verify.yml<br/>bash -n + ShellCheck<br/>make dry-run"]
    CI1 -->|pass| Merge["Squash merge to main"]
    CI2 -->|pass| Merge
```

All CI jobs are **read-only** — they check syntax, they do not run the scripts against a live system.

---

## Key Paths

| Path | Role |
|------|------|
| `/opt/linuxia/scripts/` | All runnable scripts |
| `/opt/linuxia/logs/health/` | Append-only health logs |
| `/opt/linuxia/data/shareA/` | Bind-mounted shared storage A |
| `/opt/linuxia/data/shareB/` | Bind-mounted shared storage B |
| `/opt/linuxia/data/shareA/archives/configsnap/` | Config snapshots |
| `/opt/linuxia/services/` | systemd unit templates |
| `/opt/linuxia/assets/readme/` | README visuals (SVGs, media) |
| `~gaby/pour_copilot/` | Agent input/output staging area |

---

## Agent Roles (TriluxIA)

| Agent | VM | Role |
|-------|----|------|
| Factory | VM100 | Main orchestrator, script runner, log writer |
| Layer2 | VM101 | Secondary processing, relay |
| Tool | VM102 | Tooling, builds, utility tasks |

Agents propose changes via `pour_copilot/` → human reviews → merge to `main` → timers apply.

---

→ Detailed script inventory: [`docs/INVENTORY.md`](INVENTORY.md)  
→ Troubleshooting: [`docs/runbook.md`](runbook.md)
