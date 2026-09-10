### Part 6: Systemd Daemonization & Linux Service Hardening (`systemd-daemonization/*`)

This section contains 6 technical specifications and configuration guides detailing production Linux service daemonization in `sentinel-stack`: lifecycle management, hardened unit files for `sentinel-nexus` and `blackbox-sentinel`, granular POSIX capabilities, real-time round-robin scheduling (`SCHED_RR`), and centralized journalctl logging.

---

### File: `sentinel-stack/docs/systemd-daemonization/systemd-architecture.md`

```markdown
# Linux Systemd Service Architecture & Lifecycle Management

In mission-critical industrial, healthcare, and defense deployments, the daemons comprising the Aryorithm ecosystem (`sentinel-nexus` and `sentinel`) must run continuously as hardened background system services managed by the Linux system and service manager (`systemd`).

---

## 1. Systemd Service Hierarchy & Dependencies

```text
 [ Network & Filesystem Targets (network-online.target, local-fs.target) ]
                                    │
                                    ▼ Requires BPF Virtual Filesystem Mounted
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ /sys/fs/bpf (Mounted via bpffs during Phase 0)                          │
 └──────────────────────────────────┬──────────────────────────────────────┘
                                    │
        ┌───────────────────────────┴───────────────────────────┐
        ▼ Starts Central Hub First                              ▼ Starts Edge Defense Node
 ┌─────────────────────────────┐                         ┌─────────────────────────────┐
 │ sentinel-nexus.service      │                         │ sentinel.service            │
 │ • Fleet Hub (Port 50051)    │◄────────────────────────┤ • Edge XDR Daemon           │
 │ • Web Console (Port 9443)   │   gRPC Connection       │ • In-Kernel eBPF XDP Drops  │
 │ • WorkingDir: /var/lib/...  │                         │ • Real-Time SCHED_RR Pri 98 │
 └─────────────────────────────┘                         └─────────────────────────────┘
```

---

## 2. Process Lifecycle & Auto-Restart Invariants

* **Crash Recovery Circuit:** Configured with `Restart=always` and `RestartSec=3s`. If an unhandled fatal condition occurs, systemd relaunches the process automatically within 3 seconds.
* **Rapid Restart Throttling:** Includes `StartLimitIntervalSec=60s` and `StartLimitBurst=5` to prevent tight crash-loop spinning if configuration files are missing.
* **Graceful Teardown Signaling:** Dispatches `SIGTERM` on shutdown, triggering internal signal traps that execute instant **0ms graceful deregistration** before process termination.
```

---

### File: `sentinel-stack/docs/systemd-daemonization/sentinel-nexus-service.md`

```markdown
# Production Unit Configuration: `sentinel-nexus.service`

The `sentinel-nexus.service` unit manages the Tier 6 central fleet command hub, binding gRPC port **50051**, HTTPS port **9443**, and SSE port **9444**.

---

## 1. Unit File Definition (`/etc/systemd/system/sentinel-nexus.service`)

```ini
[Unit]
Description=Aryorithm Sentinel-Nexus Central Fleet Command Plane & Collective Defense Grid
Documentation=https://docs.aryorithm.com/nexus/
After=network-online.target local-fs.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root

# Binary Invocation & Configuration Manifest
ExecStart=/usr/local/bin/sentinel-nexus --config /etc/sentinel-nexus/nexus.yaml
ExecReload=/bin/kill -HUP $MAINPID

# Process Lifecycle
Restart=always
RestartSec=3s
KillMode=mixed
TimeoutStopSec=10s

# Resource Limits for High-Density Fleet Management (5,000 Nodes)
LimitNOFILE=1048576
LimitNPROC=65536
LimitMEMLOCK=infinity

# Scheduler & Priority Tuning
CPUSchedulingPolicy=rr
CPUSchedulingPriority=80
Nice=-10
OOMScoreAdjust=-500

# Security Hardening Sandbox
ProtectHome=true
ProtectSystem=full
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

---

## 2. Managing the Service

```bash
# Enable on system boot and start immediately
sudo systemctl enable --now sentinel-nexus.service

# Query real-time execution status
sudo systemctl status sentinel-nexus.service

# Reload configuration without restarting process
sudo systemctl reload sentinel-nexus.service
```
```

---

### File: `sentinel-stack/docs/systemd-daemonization/blackbox-sentinel-service.md`

```markdown
# Production Unit Configuration: `sentinel.service`

The `sentinel.service` unit manages the Tier 3 edge appliance daemon (`sentinel`), enforcing in-kernel eBPF packet mitigation directly on network device driver rings.

---

## 1. Unit File Definition (`/etc/systemd/system/sentinel.service`)

```ini
[Unit]
Description=Aryorithm Blackbox-Sentinel Cyber-Physical Edge XDR Appliance
Documentation=https://docs.aryorithm.com/sentinel/
After=network-online.target local-fs.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root

# Binary Invocation & Active Config
ExecStart=/usr/local/bin/sentinel --config /etc/sentinel/sentinel.yaml
ExecReload=/bin/kill -HUP $MAINPID

# Process Lifecycle
Restart=always
RestartSec=3s
KillMode=mixed
TimeoutStopSec=5s

# Unrestricted Locked Physical Memory for AF_XDP & eBPF Maps
LimitMEMLOCK=infinity
LimitNOFILE=1048576
LimitNPROC=65536

# Maximum Real-Time Priority Scheduling
CPUSchedulingPolicy=rr
CPUSchedulingPriority=98
Nice=-20
OOMScoreAdjust=-1000

# Linux Capabilities Granular Delegation
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_BPF CAP_SYS_RESOURCE CAP_SYS_PTRACE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_BPF CAP_SYS_RESOURCE CAP_SYS_PTRACE

# Sandboxing
ProtectHome=true
ProtectSystem=full
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

---

## 2. Managing the Edge Service

```bash
# Start edge defense engine
sudo systemctl enable --now sentinel.service

# Inspect active status and in-kernel eBPF attachment
sudo systemctl status sentinel.service
```
```

---

### File: `sentinel-stack/docs/systemd-daemonization/linux-capabilities-management.md`

```markdown
# Granular Linux Capabilities Management

Running security daemons as unrestricted `root` violates the principle of least privilege. `sentinel-stack` restricts process execution using **Linux POSIX Capabilities**, granting only the exact kernel privileges required for packet filtering and hardware attestation.

---

## 1. Required Capabilities Matrix

| Capability Flag | Subsystem Function | Reason Required |
| :--- | :--- | :--- |
| **`CAP_NET_ADMIN`** | Tier 2 `libblackbox.so` | Attaching eBPF programs to XDP netdev driver hooks. |
| **`CAP_NET_RAW`** | Tier 5 `sentinel_lab` | Binding to `AF_PACKET` raw sockets for wire injection. |
| **`CAP_BPF`** | In-Kernel Fast Path | Loading BPF bytecode and managing kernel map descriptors. |
| **`CAP_SYS_RESOURCE`**| Memory Management | Locking physical pages (`mlock`) without `ulimit -l` ceiling. |
| **`CAP_SYS_PTRACE`** | Subsystem `11_rasp` | Inspecting process memory maps (`/proc/self/maps`). |

---

## 2. Ambient Capability Inheritance

In `sentinel.service`, capabilities are bound using both bounding sets and ambient capabilities:

```ini
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_BPF CAP_SYS_RESOURCE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_BPF CAP_SYS_RESOURCE
```

This configuration ensures that worker threads spawned by the C++ engine retain the necessary network and BPF privileges without granting full superuser permissions.
```

---

### File: `sentinel-stack/docs/systemd-daemonization/real-time-process-scheduling.md`

```markdown
# Real-Time Process Scheduling (`SCHED_RR` Priority 98)

To enforce the **$< 0.84\,\mu\text{s}$ mitigation SLA**, the `sentinel` daemon must not be delayed by the Linux Completely Fair Scheduler (CFS) when other background processes (such as log rotation or cron jobs) execute.

---

## 1. Round-Robin Real-Time Scheduling (`SCHED_RR`)

`sentinel.service` requests the kernel's real-time round-robin scheduler:

```ini
CPUSchedulingPolicy=rr
CPUSchedulingPriority=98
Nice=-20
```

### Scheduling Properties:
* **Preemptive Execution:** A thread with `SCHED_RR` priority 98 immediately preempts standard user-space and kernel CFS threads.
* **Deterministic Execution:** The network driver poll loop executes immediately upon packet arrival, eliminating scheduling jitter.
* **OOM Immunity (`OOMScoreAdjust=-1000`):** Protects the mitigation daemon from being terminated by the kernel out-of-memory killer during severe DDoS floods.

---

## 2. Verifying Real-Time Priority

Verify the active scheduling policy using `chrt`:

```bash
chrt -p $(pgrep sentinel)
```

### Expected Output
```text
pid 14022's current scheduling policy: SCHED_RR
pid 14022's current scheduling priority: 98
```
```

---

### File: `sentinel-stack/docs/systemd-daemonization/daemon-logging-and-journalctl.md`

```markdown
# Centralized Daemon Logging & `journalctl` Filtering

`sentinel-stack` integrates service logging directly with the systemd journal (`systemd-journald`), providing centralized log rotation, structured filtering, and rate limiting.

---

## 1. Querying Real-Time Service Logs

### 1. Follow Live Logs Across Both Daemons:
```bash
journalctl -u sentinel -u sentinel-nexus -f
```

### 2. Filter for Active In-Kernel Drops:
```bash
journalctl -u sentinel -g "XDP_DROP" -n 50 --no-pager
```

### 3. Filter by Log Priority (Errors and Critical Only):
```bash
journalctl -u sentinel-nexus -p err..emerg -n 25
```

---

## 2. Automated Log Rotation (`/etc/logrotate.d/sentinel`)

For secondary log files stored in `/var/log/sentinel/`, `sentinel-stack` deploys a logrotate manifest:

```text
/var/log/sentinel/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl reload sentinel > /dev/null 2>&1 || true
    endscript
}
```
```

---

### Complete in Part 6
- `sentinel-stack/docs/systemd-daemonization/systemd-architecture.md`
- `sentinel-stack/docs/systemd-daemonization/sentinel-nexus-service.md`
- `sentinel-stack/docs/systemd-daemonization/blackbox-sentinel-service.md`
- `sentinel-stack/docs/systemd-daemonization/linux-capabilities-management.md`
- `sentinel-stack/docs/systemd-daemonization/real-time-process-scheduling.md`
- `sentinel-stack/docs/systemd-daemonization/daemon-logging-and-journalctl.md`

All 6 Systemd Daemonization documentation files are now generated.

---

### Files to be Generated in Part 7

The next phase covers **Post-Build Automated Quality Gates & Smoke Tests** (`verification-and-smoke-tests/` - 8 files):

1. `verification-and-smoke-tests/verification-suite-overview.md` (`05_verify_installation.sh` test matrix and exit codes)
2. `verification-and-smoke-tests/tier-1-libxinfer-check.md` (Verifying `libxinfer.so` in dynamic linker cache)
3. `verification-and-smoke-tests/tier-2-libblackbox-check.md` (Verifying `libblackbox.so` and `xdp_filter.o` bytecode)
4. `verification-and-smoke-tests/tier-3-sentinel-check.md` (Testing `sentinel` daemon binary execution and version)
5. `verification-and-smoke-tests/tier-4-forge-cli-check.md` (Validating `forge-cli` wrapper, venv, and PyTorch)
6. `verification-and-smoke-tests/tier-5-sentinel-lab-check.md` (Testing `sentinel_lab` binary and SLAB socket hooks)
7. `verification-and-smoke-tests/tier-6-nexus-ctl-check.md` (Testing `sentinel-nexus` daemon and `nexus-ctl` CLI)
8. `verification-and-smoke-tests/automated-ci-cd-integration.md` (Running verification in GitHub Actions / GitLab CI)

Confirm when you are ready to proceed with Part 7.