# Sentinel Stack: Master Autonomous Deployment & Cyber-Range Mesh

```text
====================================================================================================
                        ARYORITHM SIX-TIER ACTIVE DEFENSE ECOSYSTEM
====================================================================================================
                                         │
 ┌───────────────────────────────────────┴───────────────────────────────────────┐
 │ TIER 6: SENTINEL-NEXUS (Fleet Orchestrator & Collective Defense Grid)         │
 │ • gRPC 0.0.0.0:50051  • Web Command Center :9443  • Real-Time SSE Stream :9444│
 └───────────────────────────────────────┬───────────────────────────────────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    ▼                                         ▼
 ┌─────────────────────────────────────┐   ┌─────────────────────────────────────┐
 │ TIER 4: XINFER-FORGE (Continual AI) │   │ TIER 5: SENTINEL-LAB (Research)     │
 │ • Self-Supervised Learning (MAE)    │   │ • Academic Preprint (paper.tex)     │
 │ • Golden Attacks Safety Gate        │   │ • SLAB Binary Wire Protocol         │
 │ • Automated ONNX Opset 17 Stager    │   │ • CIC-IDS-2017 Benchmark Testbed    │
 └──────────────────┬──────────────────┘   └──────────────────┬──────────────────┘
                    │                                         │
                    └────────────────────┬────────────────────┘
                                         │
 ┌───────────────────────────────────────┴───────────────────────────────────────┐
 │ TIER 3: BLACKBOX-SENTINEL (Edge Cyber-Physical XDR & SIEM Appliance)          │
 │ • 26 Decoupled Native Modules (WAF, CWPP, ITDR, SCADA CPS, EDR, SIEM)         │
 │ • 30 Industrial Protocol Plugins (Modbus, DNP3, PROFINET, S7Comm, DICOM)      │
 │ • NexusUplink: Live Telemetry, Instant 0ms Disconnect, Automated OTA Reload   │
 └───────────────────────────────────────┬───────────────────────────────────────┘
                                         │
 ┌───────────────────────────────────────┴───────────────────────────────────────┐
 │ TIER 2: BLACKBOX-ESSENTIAL (Active Mitigation Kernel Core - libblackbox.so)   │
 │ • Driver-Level eBPF/XDP Kernel Filter (xdp_filter.o) -> Sub-Microsecond Drops │
 │ • Lock-Free Single-Producer Multi-Consumer (SPMC) EventRingBuffer             │
 │ • 3-Tier Hardware Identity (Physical TPM 2.0 / VMware vTPM / DMI UUID)        │
 └───────────────────────────────────────┬───────────────────────────────────────┘
                                         │
 ┌───────────────────────────────────────┴───────────────────────────────────────┐
 │ TIER 1: XINFER-ESSENTIAL (Universal AI Inference Runtime - libxinfer.so)      │
 │ • Zero-Copy C++20 Heterogeneous Execution (DMA-BUF, Host-Pinned, Unified)     │
 │ • 15 Silicon Target Backends (OpenVINO, TensorRT, RKNN, QNN, Vitis AI, etc.)  │
 └───────────────────────────────────────────────────────────────────────────────┘
                                         │
 ┌───────────────────────────────────────┴───────────────────────────────────────┐
 │ ENCAPSULATED SIMULATION MESH: SENTINEL-MATRIX (Docker-in-VMware Range)        │
 │ • Automated Multi-Container Grid (Substation, Hospital, Refinery, Traffic, TUI│
 │ • Subnet: 10.240.0.0/24 (Zero route collisions)                               │
 └───────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Executive Summary

**Sentinel Stack** is the master meta-builder, installer, and cyber-range orchestration platform for the **Aryorithm / Blackbox Sentinel** ecosystem. 

Designed for mission-critical infrastructure (energy grids, naval vessels, hospital networks, smart manufacturing), it transitions cybersecurity from retrospective, cloud-bound log querying ($15 - 60\,\text{s}$ delay) to **autonomous, air-gapped, sub-microsecond edge mitigation ($< 0.84\,\mu\text{s}$ eBPF kernel drops)**.

### Primary Capabilities
1. **Topological 6-Tier Build Automation:** Detects toolchains and compiles the entire stack in strict dependency order (`xinfer` $\rightarrow$ `blackbox` $\rightarrow$ `sentinel` $\rightarrow$ `forge` $\rightarrow$ `lab` $\rightarrow$ `nexus`).
2. **Dynamic Library Extraction & Bundling:** Automatically extracts all host-compiled shared libraries (`libabsl_*`, `libre2`, `libgrpc++`, `libprotobuf`) and binds them into Docker container environments, eliminating dynamic linker mismatches.
3. **VMware-Optimized Cyber Range (`sentinel-matrix`):** Instantiates an autonomous multi-node simulation mesh running inside a dedicated `10.240.0.0/24` subnet with in-kernel XDP (Generic SKB mode) and simulated vTPM identities.
4. **Infinite Active Learning Flywheel:** Edge appliances stream high-uncertainty NetFlow vectors to Nexus $\rightarrow$ Nexus curates training batches $\rightarrow$ Forge trains self-supervised autoencoders $\rightarrow$ Nexus runs Canary rollouts $\rightarrow$ Edge nodes execute zero-downtime hot-reloads.

---

## 2. System Prerequisites

### Supported Environments
* **Host Operating System:** Ubuntu 24.04 LTS or Ubuntu 26.04 LTS (x86_64 / aarch64)
* **Virtualization (Optional):** VMware Workstation Pro / ESXi / Fusion (VT-x/AMD-V virtualization enabled)
* **Hardware Allocation:** Minimum 4 vCPUs, 8 GB RAM, 40 GB NVMe/SSD storage.

### Automated Package Resolution
The automated installer handles all package dependencies without manual intervention:
* **Compilers & Build Tools:** `build-essential`, `cmake (>=3.20)`, `clang`, `llvm`, `libelf-dev`, `libssl-dev`.
* **RPC & Serialization:** `protobuf-compiler`, `libprotobuf-dev`, `libgrpc++-dev`, `protobuf-compiler-grpc`.
* **Kernel & Networking:** `linux-headers-generic`, `iproute2`, `iptables`, `ethtool`, `bpftool`, `net-tools`.
* **Python Runtime:** Python 3.11+, isolated `venv` (PEP 668 compliant), `torch` (CPU), `onnx`, `rich`, `grpcio`.
* **Container Runtime:** `docker.io`, `docker-compose-v2`.

---

## 3. Quickstart: 1-Click Master Installation

To compile all 6 tiers on your host and install the libraries and daemons system-wide, execute:

```bash
git clone https://github.com/kamisaberi/sentinel-stack.git
cd sentinel-stack
chmod +x install.sh scripts/*.sh
sudo ./install.sh
```

### What `install.sh` Does Automatically:
1. **Phase 0:** Probes CPU architecture, RAM, and mounts `/sys/fs/bpf`.
2. **Phase 1:** Installs all APT packages and configures a clean virtual environment at `/opt/sentinel-stack/venv`.
3. **Phase 2:** Synchronizes the source trees from local workspace (`/home/kami/`) or clones missing repos from GitHub.
4. **Phase 3:** Compiles and installs:
   * `libxinfer.so` $\rightarrow$ `/usr/local/lib/`
   * `libblackbox.so` & `xdp_filter.o` $\rightarrow$ `/usr/local/lib/`
   * `sentinel` daemon $\rightarrow$ `/usr/local/bin/sentinel`
   * `forge-cli` $\rightarrow$ `/usr/local/bin/forge-cli`
   * `sentinel_lab` testbed $\rightarrow$ `/usr/local/bin/sentinel_lab`
   * `sentinel-nexus` & `nexus-ctl` $\rightarrow$ `/usr/local/bin/`
5. **Phase 4:** Configures, enables, and starts the systemd services (`sentinel-nexus.service`).
6. **Phase 5:** Runs smoke tests verifying that all 6 tiers load and execute cleanly.

---

## 4. Launching the Autonomous Simulation Mesh (`sentinel-matrix`)

Once the host builds are verified, launch the encapsulated multi-tier cyber range inside VMware.

### Architecture of the Simulation Mesh
The mesh runs in a dedicated private subnet **`10.240.0.0/24`**:

| Container Name | Role / Profile | IP Address | Ports / Capabilities |
| :--- | :--- | :--- | :--- |
| **`matrix-nexus`** | Central Command Plane (Tier 6) | `10.240.0.10` | Ports `50051`, `9443`, `9444` |
| **`matrix-forge`** | Continuous Retraining (Tier 4) | `10.240.0.20` | Watches `/shared/datasets/` |
| **`matrix-traffic-gen`** | Traffic & Attack Scenario Engine | `10.240.0.50` | Injects ambient NetFlow & exploits |
| **`matrix-monitor`** | Terminal UI (TUI) Dashboard | `10.240.0.60` | Live curses monitoring screen |
| **`matrix-edge-substation-01`**| Industrial SCADA Substation | `10.240.0.101`| OpenVINO, Modbus/DNP3, XDP SKB |
| **`matrix-edge-hospital-02`**  | Healthcare PACS Medical Enclave | `10.240.0.102`| TensorRT, DICOM/HL7, XDP SKB |
| **`matrix-edge-refinery-03`**  | Refinery Critical Infrastructure | `10.240.0.103`| RKNN, PROFINET/S7, XDP SKB |

---

### Step-by-Step Mesh Launch

```bash
cd /home/kami/sentinel-matrix

# 1. Initialize shared folders, copy binaries, extract host libs, generate mTLS certs:
make init

# 2. Build the Docker images (Nexus, Sentinel, Forge, Traffic, Monitor):
make build

# 3. Start the entire mesh:
sudo make up
```

### Verify Container Health
```bash
sudo docker compose ps
```
All containers should be in state **`Up (healthy)`** or **`Up`**.

---

## 5. Live Observability & Command Consoles

### A. Air-Gapped Web Command Center (Single-Page Application)
Open your browser to:
```text
http://localhost:9443
```
*(If accessing from a host outside VMware, use `http://<vmware-guest-ip>:9443`)*

* **Active Telemetry Cards:** Live view of Online Appliances, eBPF Kernel Drops, Forge Buffered Samples, and Active ONNX Model Version.
* **Radial Topology Canvas:** Interactive HTML5 Canvas showing live radial links connecting the edge appliances to the central Nexus hub.
* **MITRE ATT&CK Matrix:** Color-coded heatmap showing active tactic hit counters (`T0855`, `T1071`, `T1190`, `T1110`).
* **Canary Staging Controls:** 1-Click controls to promote candidate models (`Shadow Mode` $\rightarrow$ `5% Canary` $\rightarrow$ `Fleet-Wide`) or trigger an immediate Emergency Rollback.

### B. Live Terminal Dashboard (TUI)
To monitor the mesh in a real-time terminal dashboard:
```bash
cd /home/kami/sentinel-matrix
make tui
```
Displays a live split screen:
* **Left:** Connected Edge Appliances table (Node ID, Site, CPU, Drops, Microsecond Latency SLA).
* **Right:** MITRE ATT&CK Detections table with live tactic hit counts.

---

## 6. Real-Time Scenario Injections & Chaos Testing

Test active defense, collective immunity, and automated safety circuits with pre-packaged commands:

### 1. SCADA Modbus PLC Override Attack (T0855)
Simulates an attacker attempting an unauthorized valve coil override on `Edge-Substation-01`:
```bash
make attack-modbus
```
* **What happens:** 
  1. Substation Node 01 intercepts the packet, executes an in-kernel eBPF drop in $< 1\,\mu\text{s}$, and emits a `ThreatIndicator` upstream to Nexus.
  2. Nexus broadcasts a `FleetDefenseRule` fleet-wide via bidirectional gRPC.
  3. Hospital Node 02 and Refinery Node 03 inject the attacker's IP (`198.51.100.44`) into their local kernel's `blocked_ip_map` in **$< 50\,\text{ms}$**.
  4. The adversary is blocked enterprise-wide before ever reaching the other two sites.

### 2. C2 Egress Beacon Wave (T1071)
Simulates high-entropy encrypted C2 outbound traffic from `Edge-Hospital-PACS-02`:
```bash
make attack-c2
```
* **What happens:** Nexus registers the detection, the MITRE ATT&CK panel in the Web UI and TUI turns red on `T1071 (C2 Application Protocol)`, and the drop counter increments immediately.

### 3. SLA Latency Breach & Automated Rollback
Simulates a candidate model causing inference degradation ($> 1{,}000\,\mu\text{s}$):
```bash
make chaos-latency
```
* **What happens:** Nexus's `RollbackGuard` detects the SLA latency breach ($1{,}650\,\mu\text{s} > 1{,}000\,\mu\text{s}$ SLA limit), logs an emergency alert, purges the candidate model, and rolls back the fleet to stable weights.

### 4. Instant 0 ms Graceful Disconnect
Simulates an edge node abruptly shutting down:
```bash
make chaos-sever
```
* **What happens:** Node 01 emits a `DeregistrationRequest` frame on `SIGINT`. In the Web Command Center and TUI, Node 01 turns **`OFFLINE` (Red) in 0 milliseconds**, bypassing the standard 15-second heartbeat timeout.

To bring the node back online:
```bash
sudo docker compose start sentinel-edge-01
```

---

## 7. The Continuous Active Learning Loop (xInfer-Forge)

The platform autonomously adapts to local site traffic without cloud connectivity:

```text
[ Ambient Traffic Generator ]
              │ (5,000 EPS ambient NetFlow)
              ▼
[ Edge Nodes (OpenVINO / TensorRT) ]
              │ (Extracts vectors with uncertainty 0.40 <= p <= 0.60)
              ▼
[ Nexus Telemetry Buffer ]
              │ (Curates into /shared/datasets/forge_dataset_*.csv)
              ▼
[ xInfer-Forge Container ]
              ├── 1. Trains Self-Supervised Masked Autoencoder (MAE)
              ├── 2. Evaluates against immutable configs/safety/golden_attacks.yaml
              ├── 3. Compiles candidate model to ONNX Opset 17 (network_threat_v2.onnx)
              └── 4. Calls REST POST http://10.240.0.10:9443/api/v1/ota/stage
                            │
                            ▼
[ Nexus Canary Staged Rollout ]
              ├── Stage 1: SHADOW_MODE (Passive evaluation, zero drops)
              ├── Stage 2: CANARY_5_PCT (Deployed to hash cohort)
              └── Stage 3: FLEET_WIDE (Promoted)
                            │
                            ▼
[ Edge Nodes Auto-Pull & Hot-Reload ]
              └── Downloads ONNX -> Verifies SHA-256 -> Hot-reloads in < 1ms
```

To watch the live retraining loop in real time:
```bash
sudo docker compose logs -f forge
```

---

## 8. Command-Line Administration (`nexus-ctl`)

`sentinel-stack` installs `nexus-ctl` to `/usr/local/bin/nexus-ctl` for terminal-based SOC administration:

```bash
# Display full fleet status, sites, and microsecond latencies
nexus-ctl fleet list

# Broadcast an immediate in-kernel eBPF drop across all 5,000 appliances
nexus-ctl threat drop 198.51.100.99

# Query CMMC 2.0 Level 2 / NIST SP 800-171 compliance audit status
nexus-ctl report cmmc

# Query IEC 62443 industrial SCADA compliance audit status
nexus-ctl report scada

# Model lifecycle management
nexus-ctl ota status      # Check current rollout stage
nexus-ctl ota stage       # Stage candidate weights into SHADOW_MODE
nexus-ctl ota advance     # Advance stage (Shadow -> 5% Canary -> Fleet-Wide)
nexus-ctl ota rollback    # Trigger manual emergency rollback
```

---

## 9. Comprehensive Troubleshooting Guide

| Issue / Error | Root Cause | Solution |
| :--- | :--- | :--- |
| `Pool overlaps with other one on this address space` | Docker or VMware previously assigned a conflicting `172.x` route block. | The project uses `10.240.0.0/24`. Run `sudo docker network prune -f` and re-run `sudo make up`. |
| `cannot open shared object file: libabsl_...` or `libre2...` | Host-compiled binaries require specific dynamic library versions not present in stock Docker image. | Run `make init` in `sentinel-matrix`. It uses `ldd` to automatically collect all host `.so` files into `shared/lib/` and binds them to `LD_LIBRARY_PATH`. |
| `mkdir /usr/local/lib: read-only file system` | Docker daemon attempted to mount host root path in an environment with AppArmor/Snap confinement. | `docker-compose.yml` mounts local `./shared/lib:/usr/local/lib/matrix-deps:ro`. Do not mount host `/usr/local/lib`. |
| `Container matrix-nexus is unhealthy` | Port `50051` or `9443` is already held by a host process from prior testing. | Run `sudo pkill -f sentinel-nexus` and `sudo pkill -f sentinel` on the host, then run `sudo make restart`. |
| `attack-c2` hangs or `make tui` shows 0 threats | Old container image was running without live `./src` mount. | Ensure `- ./src:/app/src:ro` is in `docker-compose.yml` for `traffic-gen` and `monitor`, then run `sudo docker compose up -d --force-recreate traffic-gen monitor`. |
| `Permission denied` on BPF map injection | Virtual container lacks Linux kernel capabilities. | Ensure `privileged: true` and `cap_add: [NET_ADMIN, SYS_ADMIN, BPF]` are enabled in `docker-compose.yml`. |

---

## 10. Repository Directory Structure Reference

```text
/home/kami/
├── xinfer-essential/                  # Tier 1: Universal AI Runtime (libxinfer.so)
├── blackbox-essential/                # Tier 2: Active Security Core (libblackbox.so & eBPF)
├── blackbox-sentinel/                 # Tier 3: Edge XDR Appliance (sentinel daemon)
│   └── xinfer-forge/                  # Tier 4: Continuous Retraining Service (forge-cli)
├── sentinel-lab/                      # Tier 5: Academic Research & Testbed (paper.tex)
├── sentinel-nexus/                    # Tier 6: Central Fleet Command Plane (sentinel-nexus)
├── sentinel-matrix/                   # Encapsulated Cyber-Range Mesh (Docker / VMware)
└── sentinel-stack/                    # Master Automated Meta-Installer & Orchestrator
    ├── install.sh                     # 1-Click Master Installation Script
    ├── Makefile                       # Developer shortcuts
    ├── README.md                      # This master runbook
    ├── configs/                       # Stack configurations and systemd units
    └── scripts/                       # Phased build and verification scripts
```

---

## 11. Verification Checklist

Run this command at any time to verify the health of the entire ecosystem:

```bash
cd /home/kami/sentinel-stack
sudo make verify
```

Expected output:
```text
=== [PHASE 5] Executing End-to-End System Health Checks ===
[*] Testing Tier 1: libxinfer.so... [PASS]
[*] Testing Tier 2: libblackbox.so... [PASS]
[*] Testing Tier 3: sentinel binary... [PASS]
[*] Testing Tier 4: forge-cli runtime... [PASS]
[*] Testing Tier 5: sentinel_lab binary... [PASS]
[*] Testing Tier 6: sentinel-nexus & nexus-ctl... [PASS]
--------------------------------------------------------
[+] Smoke Test Results: 6/6 Tiers Verified Healthy.
[+] All 6 tiers compiled, linked, and verified successfully!
```