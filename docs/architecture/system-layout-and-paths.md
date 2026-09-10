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

