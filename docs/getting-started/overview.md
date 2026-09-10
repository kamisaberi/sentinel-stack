---

### File: `sentinel-stack/docs/getting-started/overview.md`

```markdown
# Meta-Builder Architecture: Automating the 6-Tier Ecosystem

Building, linking, and configuring a 6-tier cyber-physical security ecosystem from scratch typically requires executing dozens of disparate build steps: compiling eBPF bytecode with Clang BPF targets, generating gRPC Protobuf stubs, resolving shared library paths in `/etc/ld.so.conf.d/`, isolating Python machine learning environments, and authoring real-time systemd service units.

`sentinel-stack` acts as an **orchestrating meta-installer**, automating the entire multi-project lifecycle into a single pipeline.

---

## 1. Why a Topological Meta-Installer?

```text
 ┌─────────────────────────────────────────────────────────────┐
 │ THE MANUAL COMPILATION LABYRINTH:                           │
 │ 1. Developer builds Tier 3 (sentinel)                       │
 │    -> FAILS: Undefined reference to xinfer::InferenceEngine │
 │ 2. Developer builds Tier 1 (xinfer)                         │
 │    -> FAILS: Missing OpenVINO / Level Zero headers          │
 │ 3. Developer installs Python packages globally              │
 │    -> FAILS: PEP 668 externally-managed-environment         │
 │ 4. Developer starts daemon via systemd                      │
 │    -> FAILS: Missing CAP_NET_ADMIN; eBPF attach denied      │
 └──────────────────────────────┬──────────────────────────────┘
                                │
                                ▼ AUTOMATED BY SENTINEL-STACK
 ┌─────────────────────────────────────────────────────────────┐
 │ THE SENTINEL-STACK 1-COMMAND PARADIGM:                      │
 │ • Probes kernel, RAM, and mounts bpffs automatically        │
 │ • Resolves all OS dependencies non-interactively            │
 │ • Compiles Tiers 1 through 6 in mathematical DAG order      │
 │ • Deploys hardened systemd units with SCHED_RR real-time    │
 │ • Executes automated smoke tests across all 6 tiers         │
 └─────────────────────────────────────────────────────────────┘
```

---

## 2. Key Orchestration Responsibilities

* **Dependency Resolution:** Identifies and installs compilers (Clang 16+, GCC 12+), build systems (CMake, Ninja), kernel development headers, and runtime libraries.
* **Topological Sequentiality:** Ensures `libxinfer.so` exists before `libblackbox.so` compiles, and both shared libraries are indexed in `ldconfig` before `blackbox-sentinel` links.
* **Isolated Machine Learning Runtime:** Builds `/opt/sentinel-stack/venv` to run PyTorch and `forge-cli` without contaminating host operating system Python packages.
* **Matrix Handover:** Automatically copies compiled binaries and dependencies into `sentinel-matrix/shared/lib/`, allowing immediate transition into digital twin simulation.
```

---

### File: `sentinel-stack/docs/getting-started/system-requirements.md`

```markdown
# System Requirements & Prerequisites

Review the operating system baselines, hardware resource recommendations, and user privileges before executing `install.sh`.

---

## 1. Operating System Baseline

`sentinel-stack` is tested against modern 64-bit Linux distributions:

| Operating System | Distribution Baseline | Kernel Baseline | Supported Architectures |
| :--- | :--- | :--- | :--- |
| **Ubuntu Linux** | 24.04 LTS (Noble Numbat) | Kernel 6.8+ | `x86_64`, `aarch64` |
| **Ubuntu Linux** | 26.04 (Devel) | Kernel 6.8+ (GLIBC 2.43) | `x86_64`, `aarch64` |
| **Debian Linux** | 12 (Bookworm) | Kernel 6.1+ | `x86_64`, `aarch64` |

---

## 2. Hardware Resource Sizing

Compilation of deep C++20 templates and eBPF bytecode requires adequate RAM:

| Resource Profile | Minimal Deployment (Edge Gateway) | Recommended Build Host (Server / VM) |
| :--- | :--- | :--- |
| **CPU Allocation** | 4 Cores (2.0 GHz) | 16 to 32 Cores (Dynamic parallel build) |
| **System Memory (RAM)**| **8 GB RAM** (Compiler jobs capped at `-j2`) | **32 GB+ RAM** (Full parallel `-j$(nproc)`) |
| **Swap Space** | 4 GB Swap configured | 8 GB Swap |
| **Storage Space** | 25 GB Free NVMe SSD | 60 GB Free NVMe SSD |

---

## 3. Privileges & Execution Context

* **Superuser Privileges:** `sudo ./install.sh` is required to install system packages via APT, mount `/sys/fs/bpf`, write shared libraries to `/usr/local/lib/`, and register systemd service units.
* **Internet Access:** Initial installation requires outbound HTTP/HTTPS access to Ubuntu package mirrors and GitHub. (For offline deployments, refer to `architecture/air-gapped-installation-model.md`).
```

---

### File: `sentinel-stack/docs/getting-started/one-click-quickstart.md`

```markdown
# 1-Click Quickstart: `sudo ./install.sh`

This guide walks you through executing the automated single-command installation of the entire 6-tier Aryorithm ecosystem.

---

## 1. Single Command Execution

Clone the repository and execute the installer:

```bash
git clone --recurse-submodules https://github.com/kamisaberi/sentinel-stack.git
cd sentinel-stack
sudo ./install.sh
```

---

## 2. What the Installer Executes Automatically

```text
 [00_check_system.sh]          Validates Ubuntu 24.04/26.04, kernel >= 5.15, mounts bpffs.
 [01_install_dependencies.sh]  Resolves Clang-16, LLVM, t64 packages, builds Python venv.
 [02_clone_repositories.sh]    Synchronizes tier repositories or verifies local source trees.
 [03_build_all_tiers.sh]       Topological DAG build:
                                -> Tier 1: xinfer-essential   (libxinfer.so)
                                -> Tier 2: blackbox-essential (libblackbox.so, xdp_filter.o)
                                -> Tier 3: blackbox-sentinel  (sentinel, 26 subsystems, 30 plugins)
                                -> Tier 4: xinfer-forge       (forge-cli in /opt/sentinel-stack/venv)
                                -> Tier 5: sentinel-lab       (sentinel_lab binary & testbed)
                                -> Tier 6: sentinel-nexus     (sentinel-nexus, nexus-ctl, Web SPA)
 [04_setup_systemd.sh]         Configures & enables sentinel-nexus.service & sentinel.service.
 [05_verify_installation.sh]   Executes automated smoke tests across all 6 tiers.
```

---

## 3. Total Compilation Time

On an 8-core host with 16 GB of RAM, the complete end-to-end installation finishes in **under 8 minutes**:

```text
================================================================================
           SENTINEL-STACK 1-CLICK INSTALLATION COMPLETE!
================================================================================
Duration               : 7 minutes, 42 seconds
All 6 Tiers Installed  : /usr/local/lib and /usr/local/bin
Systemd Daemons Active : sentinel-nexus.service, sentinel.service
Web Command Center     : https://localhost:9443
================================================================================
```
```

---

### File: `sentinel-stack/docs/getting-started/verifying-installed-stack.md`

```markdown
# Verifying the Installed Stack (`sudo make verify`)

After running `install.sh`, execute the automated verification test suite to ensure that all shared libraries, in-kernel BPF filters, executables, and network listeners are healthy.

---

## 1. Running the Verification Suite

Run the smoke test harness:

```bash
sudo make verify
# Or execute directly:
sudo ./scripts/05_verify_installation.sh
```

---

## 2. Expected Verification Output

```text
================================================================================
                 SENTINEL-STACK POST-BUILD QUALITY GATE
================================================================================
 [PASS] Tier 1: /usr/local/lib/libxinfer.so found in ldconfig cache.
 [PASS] Tier 2: /usr/local/lib/libblackbox.so found in ldconfig cache.
 [PASS] Tier 2: /usr/local/lib/bpf/xdp_filter.o valid BPF ELF bytecode.
 [PASS] Tier 3: /usr/local/bin/sentinel binary executable (v2.4.0 verified).
 [PASS] Tier 4: /usr/local/bin/forge-cli functional in /opt/sentinel-stack/venv.
 [PASS] Tier 5: /usr/local/bin/sentinel_lab research testbed executable.
 [PASS] Tier 6: /usr/local/bin/sentinel-nexus command daemon active.
 [PASS] Tier 6: /usr/local/bin/nexus-ctl operations CLI functional.

------------------------------ NETWORK SERVICES --------------------------------
 [PASS] gRPC Fleet Service      : Listening on 0.0.0.0:50051 (mTLS Active)
 [PASS] Web Command Center      : Listening on 0.0.0.0:9443 (HTTPS)
 [PASS] Real-Time SSE Stream    : Listening on 0.0.0.0:9444 (HTTP/1.1)

================================================================================
Status: ALL QUALITY GATES PASSED (11/11). System is operational.
================================================================================
```
```

---

### File: `sentinel-stack/docs/getting-started/architecture-at-a-glance.md`

```markdown
# Architecture at a Glance

The diagram below details the filesystem layout, compilation dependencies, and daemonization hooks provisioned by `sentinel-stack`.

---

```text
 ┌──────────────────────────────────────────────────────────────────────────────────────────┐
 │ HOST OPERATING SYSTEM: Ubuntu 24.04 / 26.04 LTS                                          │
 │                                                                                          │
 │  ┌────────────────────────────────────────────────────────────────────────────────────┐  │
 │  │ SYSTEM-WIDE COMPILATION & RUNTIME LAYOUT                                           │  │
 │  │                                                                                    │  │
 │  │  • /usr/local/include/xinfer/       : C++20 Header API (InferenceEngine, Tensor)   │  │
 │  │  • /usr/local/include/blackbox/     : C++20 Header API (XdpManager, RingBuffer)    │  │
 │  │  • /usr/local/lib/libxinfer.so      : Tier 1 Zero-Copy Inference Core               │  │
 │  │  • /usr/local/lib/libblackbox.so    : Tier 2 Active In-Kernel Mitigation Core       │  │
 │  │  • /usr/local/lib/bpf/xdp_filter.o  : In-Kernel eBPF Driver Packet Filter           │  │
 │  │  • /usr/local/bin/sentinel          : Tier 3 Commercial XDR Edge Appliance Daemon   │  │
 │  │  • /usr/local/bin/forge-cli         : Tier 4 Continual AI Active Learning CLI       │  │
 │  │  • /usr/local/bin/sentinel_lab      : Tier 5 Academic Research & Benchmark Testbed  │  │
 │  │  • /usr/local/bin/sentinel-nexus    : Tier 6 Central Fleet Command Hub Daemon       │  │
 │  │  • /usr/local/bin/nexus-ctl         : Operations & Administration CLI               │  │
 │  └───────────────────────────────────┬────────────────────────────────────────────────┘  │
 │                                      │                                                   │
 │  ┌───────────────────────────────────┴────────────────────────────────────────────────┐  │
 │  │ SYSTEMD REAL-TIME SERVICES (SCHED_RR Priority 98, Nice -20)                        │  │
 │  │  • sentinel-nexus.service   ──► Central Hub (Ports 50051, 9443, 9444)              │  │
 │  │  • sentinel.service         ──► Local Edge Defense Node (<0.84µs In-Kernel Drops)  │  │
 │  └───────────────────────────────────┬────────────────────────────────────────────────┘  │
 │                                      │                                                   │
 │  ┌───────────────────────────────────┴────────────────────────────────────────────────┐  │
 │  │ CYBER-RANGE DIGITAL TWIN BRIDGE (sentinel-matrix)                                  │  │
 │  │ Auto-harvests binaries & ldd dependencies into:                                    │  │
 │  │ sentinel-matrix/shared/{bin, lib, models, certs}/                                 │  │
 │  └────────────────────────────────────────────────────────────────────────────────────┘  │
 └──────────────────────────────────────────────────────────────────────────────────────────┘
```
```

---

### File: `sentinel-stack/docs/getting-started/post-install-next-steps.md`

```markdown
# Post-Installation Next Steps

Once `sentinel-stack` completes installation and smoke tests verify nominal status, explore the three management interfaces:

---

## 1. Access the Local Web Command Center (Port 9443)

Open your desktop browser and navigate to:

👉 **`https://localhost:9443`**

Log in using the default administrative credentials configured during installation. Explore:
* The **HTML5 Canvas Radial Fleet Topology**.
* The **Real-Time MITRE ATT&CK Threat Matrix**.
* Active in-kernel eBPF drop rules.

---

## 2. Interrogate the Fleet via `nexus-ctl`

Test the command-line administration tool:

```bash
# Query managed edge appliances
nexus-ctl fleet list

# Check active Canary OTA rollout progression
nexus-ctl ota status

# View recent explainable AI (XAI) feature attributions
nexus-ctl report scada
```

---

## 3. Launch the Digital Twin Cyber-Range (`sentinel-matrix`)

Because `sentinel-stack` harvested host binaries and libraries into `sentinel-matrix/shared/lib/`, you can launch the containerized simulation mesh immediately:

```bash
cd sentinel-matrix
make up
make tui
```
```

