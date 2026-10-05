---

### File: `sentinel-stack/docs/operations-and-makefile/updating-installed-tiers.md`

```markdown
# Updating Installed Tiers & Incremental Recompilation

When new commits or security patches are merged into any of the ecosystem repositories, `sentinel-stack` allows administrators to pull updates and perform incremental recompilations without reinstalling OS dependencies.

---

## 1. The Update Command (`sudo make update`)

Execute the automated update target:

```bash
cd /opt/sentinel-stack
sudo make update
```

---

## 2. What `make update` Executes Under the Hood

```text
 1. REPOSITORY SYNCHRONIZATION:
    Executes git pull --recurse-submodules across all 6 tiers in /opt/sentinel-stack/src/
                   │
                   ▼
 2. INCREMENTAL TOPOLOGICAL RECOMPILATION:
    Runs ninja across existing build/ directories:
    • Unchanged C++ compilation units (.o) are preserved (Near-Instant Build)
    • Modified source files and headers are recompiled
                   │
                   ▼
 3. DYNAMIC LINKER CACHE UPDATE:
    Executes ldconfig to refresh newly linked shared object exports
                   │
                   ▼
 4. IN-PROCESS SERVICE RELOAD:
    Dispatches SIGHUP to running daemons to reload models and configs without packet loss
```

---

## 3. Updating an Individual Tier

If you only modified code in a specific tier (e.g., `blackbox-sentinel`), rebuild that tier individually:

```bash
sudo ./scripts/03_build_all_tiers.sh --tier sentinel
```
```

---

### File: `sentinel-stack/docs/operations-and-makefile/monitoring-daemons-status.md`

```markdown
# Monitoring Daemon Health & Socket Listeners (`sudo make status`)

The `make status` target checks service health, process CPU/RAM consumption, and active network socket listeners.

---

## 1. Execution Command

```bash
sudo make status
```

---

## 2. Output Breakdown

```text
================================================================================
                    ARYORITHM SENTINEL-STACK SERVICE HEALTH
================================================================================

------------------------------ SYSTEMD SERVICES --------------------------------
 ● sentinel-nexus.service - Aryorithm Sentinel-Nexus Central Command Plane
     Active: active (running) since Mon 2026-10-05 08:00:00 UTC; 4h 12min ago
   Main PID: 12040 (sentinel-nexus)
      Tasks: 18 (limit: 65536)
     Memory: 142.0M (limit: 2.0G)
        CPU: 4.2% (SCHED_RR Priority 80)

 ● sentinel.service - Aryorithm Blackbox-Sentinel Cyber-Physical Edge XDR
     Active: active (running) since Mon 2026-10-05 08:00:05 UTC; 4h 11min ago
   Main PID: 14022 (sentinel)
      Tasks: 24 (limit: 65536)
     Memory: 180.4M (limit: 2.0G)
        CPU: 2.1% (SCHED_RR Priority 98)

------------------------------ LISTENER SOCKETS --------------------------------
 [OK] TCP 0.0.0.0:50051   sentinel-nexus (gRPC Fleet Service)
 [OK] TCP 0.0.0.0:9443    sentinel-nexus (Web Command Center & REST API)
 [OK] TCP 0.0.0.0:9444    sentinel-nexus (Real-Time SSE Stream)
 [OK] TCP 0.0.0.0:8443    sentinel       (Local Edge Web Console)

------------------------------ IN-KERNEL eBPF HOOK -----------------------------
 [OK] Interface: eth0     Program ID: 142 (xdp_filter.o)  Mode: DRIVER (<0.84µs)
================================================================================
```
```

---

### File: `sentinel-stack/docs/operations-and-makefile/clean-uninstallation-guide.md`

```markdown
# Clean Uninstallation & System Purge Guide

If an appliance is being decommissioned or repurposed, `sentinel-stack` provides a clean uninstallation target that stops all services, removes installed binaries, shared libraries, headers, and restores default OS dynamic linker states.

---

## 1. Execution Command

Execute the uninstaller:

```bash
cd /opt/sentinel-stack
sudo make uninstall
```

---

## 2. Uninstallation Actions Executed

```text
 1. SERVICE TERMINATION:
    • Stops sentinel-nexus.service and sentinel.service
    • Disables systemd service units and unlinks /etc/systemd/system/sentinel*
    • Runs systemctl daemon-reload
              │
              ▼
 2. BINARY & LIBRARY REMOVAL:
    • Removes /usr/local/bin/{sentinel, sentinel-nexus, nexus-ctl, sentinel_lab, forge-cli}
    • Removes /usr/local/lib/libxinfer* and libblackbox*
    • Removes /usr/local/lib/bpf/xdp_filter.o
    • Removes /usr/local/lib/sentinel-plugins/
    • Removes /usr/local/include/{xinfer, blackbox}
              │
              ▼
 3. RUNTIME & LINKER CLEANUP:
    • Removes /etc/ld.so.conf.d/sentinel.conf
    • Runs ldconfig to refresh system cache
    • Removes isolated virtual environment /opt/sentinel-stack/venv/
```

---

## 3. Preserving Configuration (Optional)

By default, `make uninstall` preserves configuration files in `/etc/sentinel/` and state databases in `/var/lib/sentinel-nexus/`. To purge all configuration and logs permanently:

```bash
sudo make purge-all
```
```

---

### File: `sentinel-stack/docs/operations-and-makefile/automated-backup-and-recovery.md`

```markdown
# Automated Configuration & State Backup

To prepare for hardware replacements or disaster recovery, `sentinel-stack` provides an automated backup target that packages runtime manifests, PKI certificates, and state journals into an encrypted tarball.

---

## 1. Creating a System Backup (`sudo make backup`)

Execute the backup target:

```bash
sudo make backup
```

### Archive Generated:
```text
/opt/sentinel-stack/backups/sentinel_backup_20261005_083500.tar.gz
```

### Packaged Items:
* `/etc/sentinel/` (Edge runtime YAML manifests and SSL certs).
* `/etc/sentinel-nexus/` (Hub YAML manifests, mTLS server keys, and client certs).
* `/var/lib/sentinel-nexus/data/nexus_state.json` (Fleet NodeRegistry state database).
* `/var/lib/sentinel-nexus/models/*.manifest.json` (Model verification checksums).

---

## 2. Disaster Recovery Restoration

To restore an appliance from a backup archive:

```bash
# 1. Re-install base stack on fresh server
sudo ./install.sh

# 2. Extract backup archive over root filesystem
sudo tar -xzf /path/to/sentinel_backup_*.tar.gz -C /

# 3. Reload services
sudo systemctl restart sentinel-nexus sentinel
```
```
