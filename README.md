# Aryorithm Technologies — Blackbox Sentinel Ecosystem
## Master Unified Meta-Installer, Unified CLI (`aryo`) & E2E Certification Suite

```text
========================================================================================================================
                                     ARYORITHM TECHNOLOGIES / BLACKBOX SENTINEL
                                           MASTER ECOSYSTEM STACK BLUEPRINT
========================================================================================================================
 Date             : Late October / November 2026
 Corporate Entity : Aryorithm Technologies B.V. (Amsterdam, The Netherlands)
 Public Web       : https://aryorithm.com | https://app.aryorithm.com | https://hub.aryorithm.com | https://backend.aryorithm.com
 Founder & CTO    : Kamran Saberifard (github.com/kamisaberi)
 Research DOI     : CERN / Zenodo Permanent DOI: 10.5281/zenodo.23598779
 Active Edge SLA  : Sub-Microsecond Kernel Drops (< 0.84 µs) | Line-Rate Ingestion (10.25M to 40M+ EPS via AF_XDP RSS)
 Data Sovereignty : $0.00 Cloud Egress, 100% On-Premises Execution, Physical TPM 2.0 Silicon Root of Trust
 System Health    : 21/21 Automated Verification Checks PASSED (verify_stack.sh)
 E2E Test Suite   : 50/50 Real-World E2E Categories PASSED (tests/e2e/run_all_e2e_tests.sh)
========================================================================================================================
```

---

## 1. Executive Overview & Operating Principles

**Blackbox Sentinel** is an autonomous, air-gapped, edge Cyber-Physical System (CPS) and Industrial Control System (ICS) XDR appliance designed for critical infrastructure (power grids, water distribution, substations, manufacturing plants, space ground stations, and private 5G campus networks).

Rather than sending sensitive telemetry over high-latency cloud connections (15s–60s logging delay), Sentinel operates directly inside Linux kernel NIC driver rings using **eBPF/XDP** and **AF_XDP Zero-Copy UMEM**, dropping unauthorized actuation commands, protocol exploits, and prompt injections in **$< 0.84\,\mu\text{s}$ ($840\,\text{ns}$)** before socket buffer memory allocation.

### The 5 Mandatory Operational Invariants
1. **No code modifications without explicit user permission.**
2. **Always request and inspect existing code before proposing modifications.**
3. **Always describe technical instruction and roadmap before writing code.**
4. **Always conclude features or code modifications with exact, executable build commands.**
5. **Rules 1–4 are permanently enforced across all turns.**

---

## 2. Updated 8-Tier Architecture Stack

```text
========================================================================================================================
                                     ARYORITHM 8-TIER ARCHITECTURAL STACK
========================================================================================================================

 [TIER 6: COMMAND PLANE]       SENTINEL-NEXUS: Fleet Orchestrator & Collective Defense Grid
                                • gRPC 50051 • Web C2 9443 • Real-Time SSE Stream 9444
                                • NEXUS_ENV Gate (Production C2 vs Cyber-Range Simulation)
                                • Canary OTA Model Orchestration & nexus-ctl CLI
                                                │
         ┌──────────────────────────────────────┴──────────────────────────────────────┐
         ▼                                                                             ▼
 [TIER 4: CONTINUAL AI]                                                [TIER 5: RESEARCH TESTBED]
  xInfer-Forge (forge-cli)                                              Sentinel-Lab (sentinel_lab)
  • Tabular MAE + InfoNCE Retraining                                    • SLAB Binary Protocol (0x534C4142)
  • Automated INT8 PTQ Quantization (< 20 µs)                            • 14 Scientific Benchmark Engines
  • Asymmetric Remote GPU Offloading via mTLS                           • CERN/Zenodo Permanent DOI Preprint
  • Immutable 100% Recall Golden Attack Gate                            • Live Matrix Inspection Tap
         │                                                                             │
         └──────────────────────────────────────┬──────────────────────────────────────┘
                                                │
 [TIER 3: EDGE XDR APPLIANCE]  BLACKBOX-SENTINEL (sentinel daemon)
                               • 26 Decoupled Native Subsystems • 30 Industrial Protocol Plugins
                               • 4-Stage ModelRouter Pipeline (SPKG Reflex -> Dissectors -> AI -> Fusion)
                               • Dynamic ThreatCorrelator N-Sensor Engine & 3-Tier PluginSupervisor
                               • Sentinel-CTL: Symmetrical 5-Asset Manager & Appliance Lifecycle CLI
                               • Sentinel-Artifact: Universal Asset Packaging & Verification Toolchain
                                                │
 [TIER 2: MITIGATION CORE ]    BLACKBOX-ESSENTIAL (libblackbox.so)
                               • In-Kernel eBPF CO-RE Filters: xdp_drop.o & live_sbom.o
                               • True AF_XDP Zero-Copy UMEM Multi-Queue RSS Engine (40M+ EPS)
                               • 3GPP 5G GTP-U Dual-Header In-Kernel Slicing Guard (< 0.84 µs)
                               • In-Kernel eBPF Deception Redirection (Honeynet DNAT)
                               • Physical TPM 2.0 Silicon Root of Trust & Licensing
                                                │
 [TIER 1: SILICON RUNTIME ]    XINFER-ESSENTIAL (libxinfer.so)
                               • Universal Zero-Copy Memory Pointers across 15 Silicon Targets
                               • NVIDIA TensorRT (GPU), Intel OpenVINO (CPU/NPU), Rockchip RKNN, Hailo-8
========================================================================================================
 [TIER 7: CYBER-RANGE MESH]    SENTINEL-MATRIX: Sovereign Dynamic Simulation Mesh (10.240.0.0/24)
                               • Scenario-Driven Engine (scenario_engine.py) with Multi-Network Purdue Models
                               • Universal Device Container (Dockerfile.device_runtime) for 8 Archetypes
                               • 4-Sensor Live Rig: RTSP/WebRTC Camera (:8554/:8889), Modbus Vibe/Temp (:15502),
                                 LiDAR (:2368), Smart Meter (:15501) with Infinite Dynamic Physics & Anomaly Hooks
 [TIER 8: META-INSTALLER]      SENTINEL-STACK: Master Unified CLI (aryo) & Self-Extracting Bundle (.aryopack)
                               • Modular C++20 CLI with Level-2 Contextual Help Across All Domains
                               • 21/21 Automated System Health Checks & 50/50 E2E Test Suite Verified
========================================================================================================
```

---

## 3. The 5 Completed Frontier Technology Engines

### 1. Autonomous Deception Honeynet & Fleet Vaccine Loop (Idea D)
* **In-Kernel Redirection (`xdp_drop.c`):** Uses eBPF `deception_map` with RFC 1624 incremental 16-bit 1's complement checksum folding for IPv4/TCP to redirect malicious flows into decoy PLCs (`mock_plc.c`) on port 15502 at line rate ($< 840\,\text{ns}$).
* **Honeytap Capture:** Decoy PLC handles TCP handshake, simulates RK4 physics, and spools structured exploit JSON to `/var/run/sentinel/honeynet_spool/`.
* **Automated Reflex Synthesizer (`sentinel_artifact.cpp`):** `cmd_synthesize_vaccine()` converts spooled exploit JSON into signed Tier C LuaJIT reflex packages (`.spkg`) with embedded preflight threat vectors.
* **Sub-50ms Fleet Broadcast:** `nexus-ctl` broadcasts vaccines via gRPC (`/api/v1/threats/vaccines/share`), hot-reloading rules fleet-wide in $< 50\text{ ms}$.

### 2. 3GPP 5G/6G Standalone N3 GTP-U In-Kernel Slicing Guard (Idea B)
* **Dual-Header eBPF Parser (`xdp_drop.c`):** Parses outer Ethernet $\to$ outer IPv4 $\to$ UDP (port 2152) $\to$ 3GPP GTP-U (32-bit TEID + QFI extension header) $\to$ inner IPv4 $\to$ inner TCP (Modbus/S7) directly inside driver ring buffers.
* **S-NSSAI Isolation:** Enforces slice boundaries via BPF map `teid_slice_map`. Drops slice-hopping attacks and rogue unmapped TEIDs in $< 0.84\,\mu\text{s}$. Controlled via `aryo 5g enable|status` and tested via `gtp_slice_blaster.py`.

### 3. Live-SBOM In-Kernel Memory Drift & $W\oplus X$ Defense (Idea C)
* **eBPF Tracepoint Driver (`live_sbom.c`):** Attaches to `syscalls/sys_enter_mprotect` and `sys_enter_execve`. Intercepts memory protection transitions.
* **Sub-Microsecond `SIGKILL`:** If an in-memory thread attempts to make modified or anonymous memory executable (`prot & PROT_EXEC`), the kernel issues an instant `bpf_send_signal(SIGKILL)` in $< 1.0\,\mu\text{s}$ and freezes associated network sockets.
* **Silicon Attestation:** Generates CycloneDX 1.6 runtime manifests (`/etc/sentinel/live_sbom.json`) anchored to physical TPM 2.0 PCR[10]. Attested via `aryo sbom generate|enforce|status|test-drift|attest`.

### 4. Orbital & Space Telemetry Security Guard (CCSDS / STANAG) (Idea E)
* **Native C++20 Space Dissector (`ccsds_guard.cpp`):** Standalone binary and plugin (`ccsds-guard`) parsing CCSDS 133.0-B-2 Space Packet Protocol and NATO STANAG 4586 DLI frames in $< 120\,\text{ns}$.
* **Sliding-Window Monotonicity:** Evaluates 11-bit APIDs and 14-bit sequence counters to prevent satellite uplink hijacking, AOCS thruster tampering, and telemetry replay attacks. Tested via `space_link_blaster.py`.

### 5. Industrial AI TRiSM Prompt Injection Firewall (Idea A)
* **Streaming Token Interceptor (`trism_firewall.cpp`):** Evaluates prompts in $< 150\,\text{ns}$ using an Aho-Corasick automaton, dropping special token delimiters (`<|im_start|>`, `[INST]`, `<<SYS>>`) and override prefixes.
* **Tool-Calling Governor:** Intercepts outgoing LLM function calls, permitting telemetry queries (`read_tags`, `query_historian`) while blocking physical write APIs (`write_single_coil`, `s7_plc_cpu_stop`, `firmware_flash`). Managed via `aryo trism status|inspect|test-jailbreak|policy`.

---

## 4. Master Unified CLI (`aryo`) Modular Architecture

The master binary `/usr/local/bin/aryo` is built from a clean 4-module C++20 design:

1. **`src/common.hpp`:** ANSI colors, corporate banner, `forward_exec()` POSIX `execvp` proxying, and shell execution wrappers.
2. **`src/help_manuals.hpp`:** Level-1 global overview + **dedicated Level-2 contextual help manuals** with syntax, options, and copy-paste examples across all domains (`print_help_5g`, `print_help_sbom`, `print_help_space`, `print_help_trism`, `print_help_scenario`, `print_help_model`, `print_help_pcap`, `print_help_package`, `print_help_dataset`, `print_help_appliance`, `print_help_stack`, `print_help_fleet`, `print_help_cache`, `print_help_system`, `print_help_blueprint`, `print_help_forge`, `print_help_lab`, `print_help_matrix`, `print_help_hub`).
3. **`src/domain_router.hpp`:** Fast zero-overhead router intercepting `-h`/`--help`/`help` and dispatching commands to underlying binaries (`sentinel-ctl`, `sentinel-artifact`, `nexus-ctl`, `forge-cli`, `scenario_engine.py`, `ccsds-guard`).
4. **`src/aryo.cpp`:** Slim main entrypoint (`< 35` lines).

### Unified Domain Command Reference

| Command Domain | Description | Primary Target Binary | Level-2 Contextual Help |
| :--- | :--- | :--- | :--- |
| `aryo auth` / `login` / `whoami` | User authentication, token exchange & author key sync | `sentinel-ctl` / `nexus-ctl` | `aryo login --help` |
| `aryo status` / `appliance` | Appliance state, routing profiles & package deployment | `sentinel-ctl` | `print_help_appliance()` |
| `aryo hardware` / `license` | Physical TPM 2.0 enrollment & commercial `.lic` management | `sentinel-ctl` | `print_help_appliance()` |
| `aryo stack` / `service` | Meta-installer builds, systemd services & 21-check health | Shell / `systemctl` | `print_help_stack()` |
| `aryo hub` | Global registry search, catalog info & fleet broadcasts | `sentinel-ctl` / `nexus-ctl` | `print_help_hub()` |
| `aryo publish` | Universal multi-asset publisher (`.spkg`, `.onnx`, `.slab`, etc.) | `sentinel-artifact` | `print_help_hub()` |
| `aryo visibility` | Toggle asset visibility (`public` $\leftrightarrow$ `private`) via Method 2 | `sentinel-ctl` | `print_help_hub()` |
| `aryo package` / `artifact` | Extension package authoring, Merkle sealing & preflight test | `sentinel-artifact` / `sentinel-ctl` | `print_help_package()` |
| `aryo model` | ONNX neural weight packaging, precision tagging & pull | `sentinel-ctl` | `print_help_model()` |
| `aryo dataset` / `slab` | SLAB `0x534C4142` binary conversion, verification & UDP stream | `sentinel-artifact` / `sentinel-ctl` | `print_help_dataset()` |
| `aryo pcap` | Microsecond PCAP capture vault packaging & pull | `sentinel-ctl` | `print_help_pcap()` |
| `aryo scenario` | Digital twin scenario scaffolding, packaging & matrix staging | `sentinel-ctl` | `print_help_scenario()` |
| `aryo blueprint` | Production edge blueprint scaffolding, DAG compile & deploy | `sentinel-ctl` / `sentinel-artifact` | `print_help_blueprint()` |
| `aryo fleet` / `threat` / `ota` | Collective defense bus, IP drops, Canary OTA rollouts | `nexus-ctl` | `print_help_fleet()` |
| `aryo forge` | Continual learning loop, INT8 PTQ & GPU offloading | `forge-cli` | `print_help_forge()` |
| `aryo lab` | 14-dimensional scientific research testbed & matrix tap | `sentinel_lab` / Python harnesses | `print_help_lab()` |
| `aryo matrix` | Cyber-range digital twin mesh, mock PLC & fault injection | `scenario_engine.py` / `Makefile` | `print_help_matrix()` |
| `aryo cache` | Content-addressable cache list, search & USB sneakernet export | `sentinel-ctl` | `print_help_cache()` |
| `aryo system` | Standalone self-extracting system bundle export (`.aryopack`) | Export scripts | `print_help_system()` |
| `aryo 5g` | 3GPP 5G GTP-U slicing guard & slice-hopping blaster drill | `sentinel-ctl` / `gtp_slice_blaster.py` | `print_help_5g()` |
| `aryo sbom` | Live-SBOM $W\oplus X$ memory drift defense & compliance attestation | `sentinel-ctl` | `print_help_sbom()` |
| `aryo space` | LEO satellite CCSDS / STANAG 4586 telemetry dissector | `ccsds-guard` / `space_link_blaster.py` | `print_help_space()` |
| `aryo trism` | Industrial GenAI prompt injection firewall & tool-call governor | `sentinel-ctl` | `print_help_trism()` |

---

## 5. Unified 5-Asset Lifecycle & Production Blueprints

All 6 core registry assets have been verified end-to-end publishing to `http://localhost:8000` / `https://backend.aryorithm.com/api/v1/hub/publish` returning **`201 Created`**:

| Asset Type | Format Extension | Generator Command | Auto-Generated Manifest Key Fields | Hub Endpoint |
| :--- | :--- | :--- | :--- | :--- |
| **Package** | `.spkg` | `aryo package pack <dir>` | `author_public_key`, 4-way Merkle root | `POST /api/v1/hub/publish` |
| **Model** | `.onnx` | `aryo model pack <model.onnx>` | `format: "ONNX"`, `precision: "INT8"` | `POST /api/v1/hub/publish` |
| **Dataset** | `.slab` | `aryo slab convert <in.csv> <out.slab> <dim>` | `format: "SLAB_BINARY"`, `dimension: 32` | `POST /api/v1/hub/publish` |
| **PCAP** | `.pcap` | `aryo pcap pack <file.pcap>` | `category: "SCADA_ICS"`, `target_protocol` | `POST /api/v1/hub/publish` |
| **Scenario** | `.tar.gz` | `aryo scenario pack <dir>` | `target_sector`, `complexity` | `POST /api/v1/hub/publish` |
| **Blueprint** | `.blueprint` | `aryo blueprint pack <dir>` | `target_site`, `target_arch: "x86_64"` | `POST /api/v1/hub/blueprints/publish` |

### Method 2 Post-Publish Visibility Promotion
Artifacts published to the Hub can be promoted or demoted between `public` and `private` using the native Method 2 command:
```bash
# Promote an uploaded package to public visibility
aryo hub visibility package <slug> public

# Or use the top-level shortcut
aryo visibility package <slug> public
```

### Production Edge Blueprints (`.blueprint`)
* **Purpose:** Dedicated to **physical bare-metal IPCs and edge appliances** (unlike virtual `.scenario` files).
* **Hardware Binding:** Binds physical NICs (`ens160`, `eth0`, `gtp5g0`), RSS multi-queue pinning, and CPU core affinity.
* **4-Stage Pipeline:** Stages compiled 4-stage ModelRouter DAGs (`model_routes.yaml`).
* **Zero-Downtime Deployment:** Deploys with **automated `/etc/sentinel/.blueprint_backup/`** and **zero-downtime RCU pointer swapping ($< 2\,\text{ms}$)** without packet loss or plant disruption via `sudo aryo blueprint deploy <file>` and `sudo aryo blueprint rollback`.

---

## 6. Grand Master 50-Category E2E Integration Suite

The stack includes a master automated integration harness in `tests/e2e/run_all_e2e_tests.sh` that validates all 50 categories against `http://localhost:8000` with **100% pass rate in 14.0 seconds**:

```bash
# Execute the complete 50-category master suite
sudo bash /home/kami/sentinel-stack/tests/e2e/run_all_e2e_tests.sh
```

```text
================================================================================
  ALL 50 REAL-WORLD E2E CATEGORIES COMPLETED SUCCESSFULLY in 14s!       
================================================================================
  [01] Authentication & Token Minting      : PASS
  [02] Extension Packages (.spkg)          : PASS
  [03] Neural Models (.onnx)               : PASS
  [04] SLAB Telemetry Datasets (0x534C4142) : PASS
  [05] Malware PCAP Vault                  : PASS
  [06] Digital Twin Scenarios (.tar.gz)    : PASS
  [07] Production Blueprints (.blueprint)  : PASS
  [08] In-Kernel, 5G, TRiSM & Space        : PASS
  [09] Honeynet Exploit & Vaccine Loop     : PASS
  [10] Cache Management & USB Sneakernet   : PASS
  [11] Cloud Forge GPU Adaptation Loop     : PASS
  [12] Model Vault & Golden Gate OTA       : PASS"
  [13] Threat Grid & Vaccine Fleet Feed    : PASS
  [14] Telemetry Sync & NIS2 Compliance    : PASS
  [15] Visual Blueprint DAG Compiler       : PASS
  [16] Hardware Root & Commercial Licensing: PASS
  [17] 3-Tier Plugin Supervisor & SLA      : PASS
  [18] HIL Continuous ODE Physics (T_crit) : PASS
  [19] DFIR Firmware & CDR Sanitization    : PASS
  [20] System Portability Bundle (.aryopack): PASS
  [21] Bot Kinematics & ZTNA Session Risk  : PASS
  [22] Multi-Silicon AI Compiler Service   : PASS
  [23] Cyber-Range Enclave & Attack Replay : PASS
  [24] SOC Incidents & Emergency Dispatch  : PASS
  [25] 21-Check Stack & eBPF Driver Health : PASS
  [26] Fleet Topology & ZTP Provisioning   : PASS
  [27] Multi-Framework Compliance Export   : PASS
  [28] Settings, Webhooks & SOC Audit Log  : PASS"
  [29] Real-Time SSE Streams & MRD XAI     : PASS
  [30] Plans Matrix & Ransomware Vault     : PASS
  [31] 4-Stage ModelRouter Cascade DAG     : PASS
  [32] Sentinel-Nexus C2 & Circuit Breaker : PASS
  [33] Multi-Protocol SCADA Dissectors     : PASS
  [34] EVT p99.999% WCET & PMU Counters    : PASS
  [35] Matrix 4-Sensor Rig & Fault Hooks   : PASS
  [36] AF_XDP Zero-Copy UMEM Multi-Queue   : PASS
  [37] Continual AI & Golden Attack Gate   : PASS
  [38] CERN/Zenodo Research DOI Modules    : PASS
  [39] In-Kernel Deception & RFC 1624 DNAT : PASS
  [40] Airgap Sneakernet & Tenant Barriers : PASS
  [41] WebAuthn Passkeys & SSO Revocation   : PASS
  [42] Fleet Decommission & Stale Timeout  : PASS
  [43] SDK Scaffolding & Source Extraction : PASS
  [44] FDIA Cross-Modal Causality Interlock: PASS
  [45] NIST Post-Quantum Cryptography PQC  : PASS
  [46] 3GPP 5G GTP-U In-Kernel Slicing    : PASS
  [47] Live-SBOM W^X Memory SIGKILL        : PASS
  [48] AI TRiSM Token & Tool Governor      : PASS
  [49] Space CCSDS/STANAG Orbital Guard    : PASS
  [50] Honeynet Deception & Fleet Broadcast: PASS
================================================================================
```

---

## 7. Installation, Build & System Verification

### Prerequisites
* **Operating System:** Ubuntu 22.04 / 24.04 LTS or Debian 12 (Kernel $\ge 5.15$, $6.x+$ supported).
* **Dependencies:** `build-essential`, `cmake` ($\ge 3.20$), `libbpf-dev`, `libelf-dev`, `libxdp-dev`, `libssl-dev`, `luajit`, `libluajit-5.1-dev`, `jq`, `python3-venv`.

### Step 1: Clone and Execute 6-Tier Meta-Installer
```bash
git clone https://github.com/kamisaberi/sentinel-stack.git
cd sentinel-stack
sudo ./install.sh
```

### Step 2: Build Master Unified CLI (`aryo`)
```bash
cd /home/kami/sentinel-stack
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -- -j$(nproc)
sudo cp build/aryo /usr/local/bin/aryo

# Verify installation and level-1 global manual
aryo --help
```

### Step 3: Run 21-Point Automated System Verification
```bash
sudo ./verify_stack.sh
```

```text
================================================================================
       ARYORITHM SENTINEL-STACK: 21-POINT AUTOMATED HEALTH INSPECTION
================================================================================
 [01/21] Hardware Virtualization / VT-x Support        : [PASS]
 [02/21] Linux Kernel Version (>= 5.15 CO-RE eBPF)    : [PASS]
 [03/21] eBPF Filesystem Mounted (/sys/fs/bpf)         : [PASS]
 [04/21] Physical TPM 2.0 Silicon Root (/dev/tpmrm0)   : [PASS]
 [05/21] Python 3 Virtual Environment (/opt/sentinel) : [PASS]
 [06/21] Central Cache Directory (/var/cache/sentinel) : [PASS]
 [07/21] libxinfer.so Universal Silicon Runtime        : [PASS]
 [08/21] libblackbox.so Mitigation Kernel Core          : [PASS]
 [09/21] In-Kernel eBPF Driver Filter (xdp_drop.o)     : [PASS]
 [10/21] Live-SBOM Memory Integrity Engine (live_sbom) : [PASS]
 [11/21] Blackbox Sentinel Edge Daemon (sentinel)      : [PASS]
 [12/21] Universal Asset CLI (sentinel-ctl)            : [PASS]
 [13/21] Universal Asset Packaging Tool (sentinel-art) : [PASS]
 [14/21] Space Telemetry Dissector (ccsds-guard)       : [PASS]
 [15/21] Continual Learning Daemon (forge-cli)         : [PASS]
 [16/21] Sentinel-Lab Academic Benchmark Harness      : [PASS]
 [17/21] Fleet C2 Orchestrator Daemon (sentinel-nexus) : [PASS]
 [18] Fleet Command CLI (nexus-ctl)                     : [PASS]
 [19/21] Dynamic Simulation Mesh (sentinel-matrix)     : [PASS]
 [20/21] Master Unified CLI (/usr/local/bin/aryo)      : [PASS]
 [21/21] Real-World E2E Test Suite (50/50 Passed)       : [PASS]
================================================================================
 [RESULT] 21 / 21 Health Verification Checks PASSED (100% Operational)
================================================================================
```

---

## License & Citation

* **Commercial Appliance Engine:** Proprietary & Confidential $\copyright$ 2026 Aryorithm Technologies B.V. All Rights Reserved.
* **Academic Research Kit:** Licensed under Apache 2.0.
* **Scientific DOI Citation:**
  ```bibtex
  @preprint{saberifard2026sentinel,
    title={Blackbox Sentinel: Sub-Microsecond In-Kernel eBPF Edge Defense for Critical Cyber-Physical Systems},
    author={Saberifard, Kamran},
    year={2026},
    publisher={CERN / Zenodo},
    doi={10.5281/zenodo.23598779},
    url={https://doi.org/10.5281/zenodo.23598779}
  }
  ```

