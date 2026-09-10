### Part 2: Systems Engineering & DAG Design (`architecture/*`)

This section contains 6 architectural specifications detailing the systems engineering principles behind `sentinel-stack`: the meta-installer architecture, the topological compilation DAG, symbol resolution formalization, filesystem layout, the air-gapped installation model, and atomic rollback safeguards.

---

### File: `sentinel-stack/docs/architecture/meta-installer-architecture.md`

```markdown
# Meta-Installer Architecture & Systems Design

`sentinel-stack` operates as a non-interactive, topological meta-installer designed to provision the entire Aryorithm 6-tier runtime ecosystem on bare-metal systems, virtual appliances, or edge gateways.

---

## 1. Meta-Builder Architectural Pipeline

```text
 ┌─────────────────────────────────────────────────────────────┐
 │ sudo ./install.sh (Master Orchestrator Entrypoint)          │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Linear Sequential Phase Dispatch
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
 ┌──────────────┐        ┌──────────────┐        ┌──────────────┐
 │ Phase 0:     │        │ Phase 1:     │        │ Phase 2:     │
 │ System Probe │───────►│ Dependencies │───────►│ Repositories │
 │ (00_check)   │        │ (01_deps)    │        │ (02_clone)   │
 └──────────────┘        └──────────────┘        └──────────────┘
                                                        │
        ┌───────────────────────────────────────────────┘
        ▼
 ┌──────────────┐        ┌──────────────┐        ┌──────────────┐
 │ Phase 3:     │        │ Phase 4:     │        │ Phase 5:     │
 │ Topological  │───────►│ Systemd Units│───────►│ Smoke Tests  │
 │ DAG Build    │        │ (04_systemd) │        │ (05_verify)  │
 └──────────────┘        └──────────────┘        └──────────────┘
```

---

## 2. Decoupled Modular Scripts

Rather than maintaining a monolithic, fragile thousand-line shell script, `sentinel-stack` partitions installation logic into modular, independently runnable phase scripts within `scripts/`:

* `scripts/00_check_system.sh`: Hardware checks, kernel capability probing, BPF filesystem mounting.
* `scripts/01_install_dependencies.sh`: APT packaging, `t64` library resolution, Python PEP 668 venv setup.
* `scripts/02_clone_repositories.sh`: Local rsync synchronization or shallow Git cloning across all 6 tiers.
* `scripts/03_build_all_tiers.sh`: The topological DAG compilation engine.
* `scripts/04_setup_systemd.sh`: Service unit deployment, capabilities, and real-time scheduling.
* `scripts/05_verify_installation.sh`: Automated post-install smoke test harness.

---

## 3. Execution Invariants

* **Idempotency:** Re-running `./install.sh` evaluates existing artifacts; already compiled tiers and configured environments are verified and preserved rather than rebuilt from scratch.
* **Fail-Fast Error Trapping:** Every script enforces strict POSIX bash safety flags:
  ```bash
  set -euo pipefail
  ```
  Any individual compilation error, missing header, or failed command immediately halts execution.
```

---

### File: `sentinel-stack/docs/architecture/topological-compilation-dag.md`

```markdown
# The Topological Compilation Directed Acyclic Graph (DAG)

Because each tier in the Aryorithm ecosystem links directly against the headers and shared objects of lower-level tiers, compiling out of order results in fatal dynamic linker errors.

`sentinel-stack` models the build process as a **Directed Acyclic Graph (DAG)** and executes a linear topological sort.

---

## 1. Mathematical Dependency Graph

Let $G = (V, E)$ represent the dependency graph, where vertices $V = \{T_1, T_2, T_3, T_4, T_5, T_6\}$ represent the ecosystem tiers:

$$V = \{ \text{xinfer}, \text{blackbox}, \text{sentinel}, \text{forge}, \text{lab}, \text{nexus} \}$$

The dependency edges $E$ denote compile-time and link-time requirements:

```text
               ┌────────────────────────────────────────────────────────┐
               │              TIER 1: xinfer-essential                  │
               │              Outputs: libxinfer.so                     │
               └──────────┬──────────────────┬──────────────────┬───────┘
                          │                  │                  │
                          ▼                  │                  │
 ┌─────────────────────────────────┐         │                  │
 │   TIER 2: blackbox-essential    │         │                  │
 │   Outputs: libblackbox.so       │         │                  │
 │            xdp_filter.o         │         │                  │
 └────────────────┬────────────────┘         │                  │
                  │                          │                  │
                  ▼                          ▼                  │
 ┌──────────────────────────────────────────────────┐           │
 │            TIER 3: blackbox-sentinel             │           │
 │            Outputs: sentinel daemon              │           │
 └────────────────────────┬─────────────────────────┘           │
                          │                                     │
                          ├──────────────────┐                  │
                          ▼                  ▼                  ▼
 ┌─────────────────────────────────┐   ┌─────────────────────────────────┐
 │       TIER 4: xinfer-forge      │   │       TIER 5: sentinel-lab      │
 │       Outputs: forge-cli        │   │       Outputs: sentinel_lab     │
 └────────────────┬────────────────┘   └────────────────┬────────────────┘
                  │                                     │
                  └──────────────────┬──────────────────┘
                                     │
                                     ▼
 ┌──────────────────────────────────────────────────────────────────────┐
 │                      TIER 6: sentinel-nexus                          │
 │                      Outputs: sentinel-nexus daemon, nexus-ctl CLI   │
 └──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Linear Topological Order

The unique topological ordering evaluated by `03_build_all_tiers.sh` is:

$$\mathcal{T} = \langle T_1 \longrightarrow T_2 \longrightarrow T_3 \longrightarrow T_4 \longrightarrow T_5 \longrightarrow T_6 \rangle$$

1. **$T_1$ (`xinfer-essential`):** Universal C++20 AI inference runtime (`libxinfer.so`).
2. **$T_2$ (`blackbox-essential`):** In-kernel eBPF filter and active mitigation core (`libblackbox.so`). Links to $T_1$.
3. **$T_3$ (`blackbox-sentinel`):** Commercial edge XDR daemon (`sentinel`). Links to $T_1$ and $T_2$.
4. **$T_4$ (`xinfer-forge`):** Continual active learning engine (`forge-cli`). Consumes $T_1$ ONNX specifications.
5. **$T_5$ (`sentinel-lab`):** Open academic benchmark testbed (`sentinel_lab`). Links to $T_1$ and $T_2$.
6. **$T_6$ (`sentinel-nexus`):** Central command plane (`sentinel-nexus`). Coordinates $T_3$, $T_4$, and $T_5$.
```

---

### File: `sentinel-stack/docs/architecture/dependency-graph-formalization.md`

```markdown
# Dependency Graph Formalization: Symbol Resolution

To understand why linear topological ordering is strictly enforced, this document examines the C++ dynamic symbol table dependencies across the shared objects.

---

## 1. Symbol Resolution Table

| Tier Binary | Required Headers | Linked Shared Libraries | Exported Symbols Used by Downstream Tiers |
| :--- | :--- | :--- | :--- |
| **`libxinfer.so`** ($T_1$) | Standard POSIX, Level Zero, CUDA | Direct driver APIs | `xinfer::InferenceEngine::initialize()`<br>`xinfer::Tensor::create_from_raw_host()` |
| **`libblackbox.so`** ($T_2$)| `<xinfer/xinfer.hpp>` | `-lxinfer` | `blackbox::XdpManager::block_ip()`<br>`blackbox::EventRingBuffer::try_enqueue()` |
| **`sentinel`** ($T_3$) | `<xinfer/xinfer.hpp>`<br>`<blackbox/blackbox.hpp>` | `-lxinfer`<br>`-lblackbox` | Native 26 subsystems, 30 protocol dissectors |
| **`forge-cli`** ($T_4$) | Python C-Extensions | PyTorch, ONNX | Exports `network_threat_v2.onnx` targeting $T_1$ |
| **`sentinel_lab`** ($T_5$)| `<xinfer/xinfer.hpp>`<br>`<blackbox/blackbox.hpp>` | `-lxinfer`<br>`-lblackbox` | SLAB protocol evaluation harness |
| **`sentinel-nexus`** ($T_6$)| `<blackbox/abi.hpp>` | `-lgrpc++`<br>`-lprotobuf` | Master command plane coordinating $T_3$ and $T_4$ |

---

## 2. Dynamic Linker Cache Refreshes (`ldconfig`)

In Linux, when a shared library is installed to `/usr/local/lib/`, it is not immediately discoverable by the GNU dynamic linker (`ld.so`) until the system cache (`/etc/ld.so.cache`) is refreshed.

`sentinel-stack` enforces an **Intermediate Cache Refresh Invariant**:

```bash
# Executed immediately after compiling Tier N:
ninja install
ldconfig
# Tier N+1 build begins ONLY after ldconfig returns 0
```

Without running `ldconfig` sequentially between tiers, compiling Tier 3 will fail during the link step with:
```text
/usr/bin/ld: cannot find -lxinfer: No such file or directory
/usr/bin/ld: cannot find -lblackbox: No such file or directory
```
```

---

### File: `sentinel-stack/docs/architecture/system-layout-and-paths.md`

```markdown
# System-Wide Filesystem Layout & Installation Paths

`sentinel-stack` adheres strictly to the Linux **Filesystem Hierarchy Standard (FHS)**, placing shared libraries, binaries, configuration manifests, and data stores into predictable system paths.

---

## 1. Target Filesystem Tree

```text
/
├── usr/local/
│   ├── include/                              # C++20 Header APIs
│   │   ├── xinfer/                          # Tier 1 Headers (xinfer.hpp, tensor.hpp)
│   │   └── blackbox/                        # Tier 2 Headers (blackbox.hpp, xdp.hpp)
│   ├── lib/                                 # Native Shared Libraries
│   │   ├── libxinfer.so -> libxinfer.so.1
│   │   ├── libblackbox.so -> libblackbox.so.1
│   │   ├── bpf/                             # In-Kernel eBPF Bytecode
│   │   │   └── xdp_filter.o
│   │   └── sentinel-plugins/                # 30 Dynamic Protocol Dissectors
│   │       ├── libsentinel_plugin_modbus.so
│   │       └── libsentinel_plugin_s7comm.so
│   └── bin/                                 # Production Executables
│       ├── sentinel                         # Tier 3 Edge Appliance Daemon
│       ├── forge-cli                        # Tier 4 Continual AI CLI Wrapper
│       ├── sentinel_lab                     # Tier 5 Academic Research Testbed
│       ├── sentinel-nexus                   # Tier 6 Central Fleet Command Hub
│       └── nexus-ctl                        # Tier 6 Operations CLI
├── etc/
│   ├── sentinel/                            # Edge Appliance Configuration
│   │   ├── sentinel.yaml
│   │   └── certs/
│   └── sentinel-nexus/                      # Central Hub Configuration
│       ├── nexus.yaml
│       └── certs/
├── var/lib/sentinel-nexus/                  # Hub Data Directories
│   ├── data/                                # State Database (nexus_state.json)
│   ├── models/                              # Staged ONNX Neural Models
│   └── forge_datasets/                      # Active Learning Curated CSVs
└── opt/sentinel-stack/
    ├── venv/                                # Isolated PEP 668 Python Environment
    └── src/                                 # Cloned or rsynced source trees
```

---

## 2. Dynamic Linker Configuration

The installer registers `/usr/local/lib` in the dynamic linker configuration:

```bash
# /etc/ld.so.conf.d/sentinel.conf
/usr/local/lib
/usr/local/lib/sentinel-plugins
```
```

---

### File: `sentinel-stack/docs/architecture/air-gapped-installation-model.md`

```markdown
# Air-Gapped Installation & Offline Source Pre-Seeding

In classified defense installations and air-gapped industrial facilities, the target server has zero internet access to GitHub repositories or public Ubuntu package mirrors.

`sentinel-stack` supports an **Air-Gapped Pre-Seeded Deployment Mode**.

---

## 1. Offline Pre-Seeding Workflow

```text
 [ INTERNET-CONNECTED STAGING MACHINE ]
  1. Clones all 6 repositories with submodules:
     git clone --recurse-submodules https://github.com/kamisaberi/<repo>
  2. Downloads offline APT package cache (.deb bundle)
  3. Pre-downloads Python binary wheels for /opt/sentinel-stack/venv
  4. Archives into single portable bundle: sentinel-stack-airgapped.tar.gz
                       │
                       ▼ Transferred via Secure Physical Media (USB / Data Diode)
 [ AIR-GAPPED ON-PREMISES TARGET SERVER ]
  1. Decompresses archive to /opt/sentinel-stack/
  2. Executes: sudo ./install.sh --offline
```

---

## 2. The `--offline` Installer Mode

When executed with `--offline`:
* **Phase 1 (Dependencies):** Bypasses `apt-get update` and installs packages directly from a local `.deb` archive directory (`/opt/sentinel-stack/debs/*.deb`) using `dpkg -i`.
* **Phase 2 (Repositories):** Bypasses `git clone` and copies pre-seeded source trees directly from `/opt/sentinel-stack/src/` via `rsync`.
* **Phase 4 (Python Venv):** Installs PyTorch and ONNX wheels using pip's `--no-index --find-links=/opt/sentinel-stack/wheels/` flags.
```

---

### File: `sentinel-stack/docs/architecture/atomic-rollback-safeguards.md`

```markdown
# Atomic Rollback Safeguards & Failure Containment

If compilation fails mid-stream (e.g., compiler OOM or missing dependency), leaving partially installed shared libraries in `/usr/local/lib` can break future builds or leave the host in an un-bootable state.

`sentinel-stack` implements **Atomic Rollback Safeguards** and state tracking.

---

## 1. Shell Trap Error Handling (`scripts/00_check_system.sh`)

Every installation phase registers an automated POSIX shell trap:

```bash
# State tracking variables
INSTALL_PHASE="INITIALIZING"
PREVIOUS_TIERS_BUILT=()

cleanup_on_error() {
    local exit_code=$?
    echo ""
    echo "================================================================================"
    echo "[-] FATAL ERROR ENCOUNTERED IN PHASE: ${INSTALL_PHASE}"
    echo "[-] Command exited with status: ${exit_code}"
    echo "================================================================================"
    
    # 1. Rollback partial tier installation
    if [ -n "${CURRENT_BUILDING_TIER:-}" ]; then
        echo "[*] Rolling back partial artifacts for tier: ${CURRENT_BUILDING_TIER}..."
        rm -f "/usr/local/lib/lib${CURRENT_BUILDING_TIER}.so"*
        rm -rf "/usr/local/include/${CURRENT_BUILDING_TIER}"
    fi

    # 2. Refresh dynamic linker cache to maintain clean system state
    ldconfig

    echo "[*] System restored to clean state. See /var/log/sentinel_install.log for details."
    exit "${exit_code}"
}

trap cleanup_on_error ERR INT TERM
```

---

## 2. Failure Containment Invariants

* **Isolated Build Trees:** All compilation executes inside segregated build subdirectories (`build/`). Partial compilation objects (`.o`) never touch `/usr/local/` until the target passes all link tests.
* **Service Safety:** If Tier 6 fails to compile, existing Tier 3 services are not restarted with mismatched library versions.
```

---

### Complete in Part 2
- `sentinel-stack/docs/architecture/meta-installer-architecture.md`
- `sentinel-stack/docs/architecture/topological-compilation-dag.md`
- `sentinel-stack/docs/architecture/dependency-graph-formalization.md`
- `sentinel-stack/docs/architecture/system-layout-and-paths.md`
- `sentinel-stack/docs/architecture/air-gapped-installation-model.md`
- `sentinel-stack/docs/architecture/atomic-rollback-safeguards.md`

All 6 Systems Engineering & DAG Design files for `sentinel-stack` are now generated.

---

### Files to be Generated in Part 3

The next phase covers **The 6-Phase Linear Pipeline** (`installation-phases/` - 7 files):

1. `installation-phases/pipeline-overview.md` (Chronological pipeline execution: Phase 0 through Phase 5)
2. `installation-phases/phase-0-system-validation.md` (`00_check_system.sh`: Probing OS, kernel, RAM, and mounting bpffs)
3. `installation-phases/phase-1-dependency-resolution.md` (`01_install_dependencies.sh`: Compilers, gRPC, and Python venv)
4. `installation-phases/phase-2-repository-synchronization.md` (`02_clone_repositories.sh`: Local rsync vs. shallow git clone)
5. `installation-phases/phase-3-topological-compilation.md` (`03_build_all_tiers.sh`: Sequential CMake/make build execution)
6. `installation-phases/phase-4-systemd-daemonization.md` (`04_setup_systemd.sh`: Unit generation, capabilities, and startup)
7. `installation-phases/phase-5-smoke-testing.md` (`05_verify_installation.sh`: Automated health check assertions)

Confirm when you are ready to proceed with Part 3.