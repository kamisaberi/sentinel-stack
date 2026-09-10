### Part 1: Root Configuration & Getting Started (`mkdocs.yml`, `index.md`, and `getting-started/*`)

This initial set of 8 files establishes the full documentation engine configuration, the executive meta-installer overview, and the complete onboarding track for **`sentinel-stack`** (`sentinel-stack`).

---

### File: `sentinel-stack/docs/mkdocs.yml`

```yaml
site_name: Sentinel-Stack Documentation
site_description: 1-Click Topological DAG Meta-Installer, Ubuntu 24.04/26.04 Packaging Engine, and Ecosystem Deployment Orchestrator
site_author: Aryorithm Technologies B.V.
site_url: https://docs.aryorithm.com/stack/
repo_name: kamisaberi/sentinel-stack
repo_url: https://github.com/kamisaberi/sentinel-stack

theme:
  name: material
  language: en
  palette:
    - scheme: slate
      primary: deep purple
      accent: cyan
      toggle:
        icon: material/weather-night
        name: Switch to light mode
    - scheme: default
      primary: deep purple
      accent: cyan
      toggle:
        icon: material/weather-sunny
        name: Switch to dark mode
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.suggest
    - search.highlight
    - content.code.copy
    - content.code.annotate

plugins:
  - search

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.highlight:
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
  - pymdownx.inlinehilite
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.arithmatex:
      generic: true
  - tables
  - attr_list
  - md_in_html

extra_javascript:
  - https://polyfill.io/v3/polyfill.min.js?features=es6
  - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js

nav:
  - Home: index.md
  - Getting Started:
      - Overview: getting-started/overview.md
      - System Requirements: getting-started/system-requirements.md
      - 1-Click Quickstart: getting-started/one-click-quickstart.md
      - Verifying Installed Stack: getting-started/verifying-installed-stack.md
      - Architecture at a Glance: getting-started/architecture-at-a-glance.md
      - Post-Install Next Steps: getting-started/post-install-next-steps.md
  - Architecture:
      - Meta-Installer Architecture: architecture/meta-installer-architecture.md
      - Topological Compilation DAG: architecture/topological-compilation-dag.md
      - Dependency Graph Formalization: architecture/dependency-graph-formalization.md
      - System Layout & Paths: architecture/system-layout-and-paths.md
      - Air-Gapped Installation Model: architecture/air-gapped-installation-model.md
      - Atomic Rollback Safeguards: architecture/atomic-rollback-safeguards.md
  - Installation Phases:
      - Pipeline Overview: installation-phases/pipeline-overview.md
      - Phase 0 System Validation: installation-phases/phase-0-system-validation.md
      - Phase 1 Dependency Resolution: installation-phases/phase-1-dependency-resolution.md
      - Phase 2 Repository Sync: installation-phases/phase-2-repository-synchronization.md
      - Phase 3 Topological Build: installation-phases/phase-3-topological-compilation.md
      - Phase 4 Systemd Daemonization: installation-phases/phase-4-systemd-daemonization.md
      - Phase 5 Smoke Testing: installation-phases/phase-5-smoke-testing.md
  - Dependency Management:
      - Ubuntu Packaging Engine: dependency-management/ubuntu-packaging-engine.md
      - t64 Package Resolution: dependency-management/t64-package-resolution.md
      - PEP 668 Python venv: dependency-management/pep-668-python-virtual-env.md
      - eBPF Compiler Toolchains: dependency-management/ebpf-compiler-toolchains.md
      - OpenVINO / CUDA Prerequisites: dependency-management/openvino-tensorrt-prerequisites.md
      - Non-Interactive Execution: dependency-management/non-interactive-execution.md
  - Compilation DAG Tiers:
      - Tier 1 xinfer-essential: compilation-dag-tiers/building-tier-1-xinfer.md
      - Tier 2 blackbox-essential: compilation-dag-tiers/building-tier-2-blackbox.md
      - Tier 3 blackbox-sentinel: compilation-dag-tiers/building-tier-3-sentinel.md
      - Tier 4 xinfer-forge: compilation-dag-tiers/building-tier-4-forge.md
      - Tier 5 sentinel-lab: compilation-dag-tiers/building-tier-5-lab.md
      - Tier 6 sentinel-nexus: compilation-dag-tiers/building-tier-6-nexus.md
      - Dynamic Linker ldconfig: compilation-dag-tiers/dynamic-linker-cache-ldconfig.md
      - Parallel Job Scaling & RAM: compilation-dag-tiers/parallel-job-scaling-ram.md
  - Systemd Daemonization:
      - Systemd Architecture: systemd-daemonization/systemd-architecture.md
      - sentinel-nexus Service: systemd-daemonization/sentinel-nexus-service.md
      - blackbox-sentinel Service: systemd-daemonization/blackbox-sentinel-service.md
      - Linux Capabilities Management: systemd-daemonization/linux-capabilities-management.md
      - Real-Time Process Scheduling: systemd-daemonization/real-time-process-scheduling.md
      - Logging & journalctl: systemd-daemonization/daemon-logging-and-journalctl.md
  - Verification & Smoke Tests:
      - Verification Suite Overview: verification-and-smoke-tests/verification-suite-overview.md
      - Tier 1 libxinfer Check: verification-and-smoke-tests/tier-1-libxinfer-check.md
      - Tier 2 libblackbox Check: verification-and-smoke-tests/tier-2-libblackbox-check.md
      - Tier 3 sentinel Check: verification-and-smoke-tests/tier-3-sentinel-check.md
      - Tier 4 forge-cli Check: verification-and-smoke-tests/tier-4-forge-cli-check.md
      - Tier 5 sentinel-lab Check: verification-and-smoke-tests/tier-5-sentinel-lab-check.md
      - Tier 6 nexus-ctl Check: verification-and-smoke-tests/tier-6-nexus-ctl-check.md
      - Automated CI/CD Integration: verification-and-smoke-tests/automated-ci-cd-integration.md
  - Bridge to Sentinel-Matrix:
      - Matrix Bridge Architecture: bridge-to-sentinel-matrix/matrix-bridge-architecture.md
      - Harvesting Host Binaries: bridge-to-sentinel-matrix/harvesting-host-binaries.md
      - Dynamic Library Extraction (ldd): bridge-to-sentinel-matrix/dynamic-library-extraction-ldd.md
      - Proto & Web Asset Handover: bridge-to-sentinel-matrix/proto-and-web-asset-handover.md
      - VMware / Docker Handshake: bridge-to-sentinel-matrix/vmware-docker-mesh-handshake.md
  - Configuration & Customization:
      - stack.yaml Specification: configuration-and-customization/stack-yaml-specification.md
      - Customizing Install Paths: configuration-and-customization/customizing-install-paths.md
      - Git Branches & Tags: configuration-and-customization/configuring-git-branches-and-tags.md
      - Customizing CMake Flags: configuration-and-customization/customizing-cmake-build-flags.md
  - Operations & Makefile:
      - Makefile Reference: operations-and-makefile/makefile-reference.md
      - Updating Installed Tiers: operations-and-makefile/updating-installed-tiers.md
      - Monitoring Daemons Status: operations-and-makefile/monitoring-daemons-status.md
      - Clean Uninstallation Guide: operations-and-makefile/clean-uninstallation-guide.md
      - Backup & Recovery: operations-and-makefile/automated-backup-and-recovery.md
  - Troubleshooting:
      - OOM Compiler Crashes: troubleshooting/oom-compiler-crashes.md
      - Missing Kernel Headers: troubleshooting/missing-kernel-headers.md
      - gRPC & Protobuf Linking: troubleshooting/grpc-protobuf-linking-errors.md
      - PEP 668 Python Errors: troubleshooting/python-externally-managed-errors.md
      - Systemd Failed Starts: troubleshooting/systemd-service-failed-starts.md
      - Dynamic Library Not Found: troubleshooting/dynamic-linker-library-not-found.md
      - FAQ: troubleshooting/faq.md
      - Support & SLAs: troubleshooting/support.md
```

---

### File: `sentinel-stack/docs/index.md`

```markdown
# Sentinel-Stack (`sentinel-stack`)

**1-Click Topological DAG Meta-Installer & Master Deployment Orchestrator**  
*Tier 8 Meta-Deployment Tier of the Aryorithm / Blackbox Sentinel Ecosystem*

---

## Executive Architectural Overview

`sentinel-stack` is the master build automation, dependency resolver, and deployment orchestrator for the entire Aryorithm 8-tier ecosystem. Executing via a single command (**`sudo ./install.sh`**), it validates host kernel capabilities, resolves complex package transitions (**Ubuntu 24.04/26.04 `t64` year-2038 libraries and PEP 668 Python environments**), and compiles all six runtime tiers in strict topological dependency order.

Upon build completion, `sentinel-stack` deploys hardened systemd service units with real-time priority (`SCHED_RR`), configures the in-kernel BPF virtual filesystem (`bpffs`), runs automated post-installation smoke tests, and harvests dynamic libraries into `sentinel-matrix/shared/lib/` for immediate digital twin simulation.

```text
====================================================================================================
                        SENTINEL-STACK 1-CLICK TOPOLOGICAL COMPILATION DAG
====================================================================================================
 [ENTRY POINT]                 sudo ./install.sh (or sudo make all)
                                      │
                                      ▼ PHASE 0: SYSTEM VALIDATION (00_check_system.sh)
                               Probes Linux Kernel >= 5.15, mounts bpffs, calculates RAM/CPU
                                      │
                                      ▼ PHASE 1: DEPENDENCY RESOLUTION (01_install_dependencies.sh)
                               Installs Clang-16, LLVM, t64 packages, builds /opt/sentinel-stack/venv
                                      │
                                      ▼ PHASE 2: REPOSITORY SYNC (02_clone_repositories.sh)
                               Local rsync or shallow git clone across all 6 tier repositories
                                      │
                                      ▼ PHASE 3: TOPOLOGICAL COMPILATION (03_build_all_tiers.sh)
 ┌────────────────────────────────────┴────────────────────────────────────────────────────────────┐
 │  [TIER 1: AI INFERENCE]        xinfer-essential (libxinfer.so -> /usr/local/lib)                │
 │                                 │                                                               │
 │                                 ▼ ldconfig                                                      │
 │  [TIER 2: ACTIVE MITIGATION]   blackbox-essential (xdp_filter.o, libblackbox.so)                │
 │                                 │                                                               │
 │                                 ▼ ldconfig                                                      │
 │  [TIER 3: EDGE XDR APPLIANCE]  blackbox-sentinel (sentinel daemon, 26 subsystems, 30 plugins)   │
 │                                 │                                                               │
 │                                 ▼ /opt/sentinel-stack/venv                                      │
 │  [TIER 4: CONTINUAL AI]        xinfer-forge (forge-cli -> /usr/local/bin/forge-cli)             │
 │                                 │                                                               │
 │                                 ▼ cmake build                                                   │
 │  [TIER 5: RESEARCH TESTBED]    sentinel-lab (sentinel_lab binary, SLAB protocol tools)          │
 │                                 │                                                               │
 │                                 ▼ gRPC HTTP/2                                                   │
 │  [TIER 6: COMMAND PLANE]       sentinel-nexus (sentinel-nexus daemon, nexus-ctl CLI, web SPA)  │
 └────────────────────────────────────┬────────────────────────────────────────────────────────────┘
                                      │
                                      ▼ PHASE 4: SYSTEMD DAEMONIZATION (04_setup_systemd.sh)
                               Deploys sentinel-nexus.service & blackbox-sentinel.service (SCHED_RR)
                                      │
                                      ▼ PHASE 5: POST-BUILD SMOKE TESTS (05_verify_installation.sh)
                               Runs 6-tier quality gate assertions; validates ports 50051, 9443, 9444
                                      │
                                      ▼ BRIDGE TO CYBER-RANGE (sentinel-matrix)
                               Auto-harvests host binaries and dynamic libs (ldd) into shared/lib/
====================================================================================================
```

---

## Core Invariants

1. **Zero-Prompt Automation:** Executes end-to-end non-interactively without pausing for APT debconf prompts, git credential queries, or manual intervention.
2. **Strict Topological Invariance:** Tiers compile strictly in acyclic dependency order ($T_1 \to T_2 \to T_3 \to T_4 \to T_5 \to T_6$); the dynamic linker cache (`ldconfig`) is updated after each tier build to satisfy subsequent link dependencies.
3. **PEP 668 & `t64` Compliance:** Bypasses Ubuntu 24.04/26.04 `externally-managed-environment` restrictions using an isolated virtual environment at `/opt/sentinel-stack/venv`, resolving all 64-bit time `t64` package names.
4. **Dynamic RAM Throttling:** Calculates host memory per CPU core, dynamically throttling compiler parallelism (e.g., `make -j2` under $< 8\text{ GB}$ RAM) to prevent internal compiler Out-of-Memory (OOM) fatal crashes.
5. **Turn-Key Cyber-Range Bridge:** Harvests host-compiled binaries and dynamic libraries (`libabsl`, `libre2`, `libgrpc++`) directly into `sentinel-matrix/shared/lib/` for zero-friction digital twin execution.
```

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

