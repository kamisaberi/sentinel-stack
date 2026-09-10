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

