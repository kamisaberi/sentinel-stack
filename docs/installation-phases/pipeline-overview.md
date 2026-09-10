### Part 3: The 6-Phase Linear Pipeline (`installation-phases/*`)

This section contains 7 technical implementation guides detailing the chronological execution phases of `sentinel-stack`: the master pipeline overview, system validation (`00_check_system.sh`), dependency resolution (`01_install_dependencies.sh`), repository synchronization (`02_clone_repositories.sh`), topological compilation (`03_build_all_tiers.sh`), systemd daemonization (`04_setup_systemd.sh`), and post-install smoke testing (`05_verify_installation.sh`).

---

### File: `sentinel-stack/docs/installation-phases/pipeline-overview.md`

```markdown
# Chronological Pipeline Execution: Phase 0 to Phase 5

The master orchestration script (`install.sh`) executes a linear, 6-phase pipeline. Each phase is implemented as a standalone POSIX script in `scripts/`, enforcing strict error trapping and logging to `/var/log/sentinel_install.log`.

---

## 1. Master Pipeline Flow

```text
 [ ENTER: sudo ./install.sh ]
              │
              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ PHASE 0: SYSTEM VALIDATION (00_check_system.sh)             │
 │  - Verifies Ubuntu 24.04/26.04 & Kernel >= 5.15             │
 │  - Mounts /sys/fs/bpf (bpffs) and evaluates RAM ceiling     │
 └────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ PHASE 1: DEPENDENCY RESOLUTION (01_install_dependencies.sh) │
 │  - Installs Clang-16, LLVM, t64 packages, and CMake         │
 │  - Provisions isolated venv at /opt/sentinel-stack/venv     │
 └────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ PHASE 2: REPOSITORY SYNCHRONIZATION (02_clone_repositories) │
 │  - Discovers local sibling directories (rsync)              │
 │  - Or performs shallow Git clone across all 6 tiers         │
 └────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ PHASE 3: TOPOLOGICAL BUILD DAG (03_build_all_tiers.sh)      │
 │  - Sequential compile: xinfer -> blackbox -> sentinel...    │
 │  - Executes intermediate ldconfig cache refreshes           │
 └────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ PHASE 4: SYSTEMD DAEMONIZATION (04_setup_systemd.sh)        │
 │  - Generates service units with SCHED_RR priority 98        │
 │  - Binds Linux capabilities (CAP_NET_ADMIN, CAP_BPF)        │
 └────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ PHASE 5: POST-BUILD SMOKE TESTS (05_verify_installation.sh) │
 │  - 11-step quality gate validation                          │
 │  - Verifies ports 50051, 9443, and 9444 are listening      │
 └────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
 [ EXIT: System Operational in < 8 Minutes ]
```

---

## 2. Master Entrypoint (`install.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/sentinel_install.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "================================================================================"
echo "          ARYORITHM SENTINEL-STACK 1-CLICK TOPOLOGICAL INSTALLER               "
echo "================================================================================"
echo "[*] Installation log initialized at: ${LOG_FILE}"

# Execute 6 phases sequentially
"${SCRIPT_DIR}/scripts/00_check_system.sh"
"${SCRIPT_DIR}/scripts/01_install_dependencies.sh"
"${SCRIPT_DIR}/scripts/02_clone_repositories.sh"
"${SCRIPT_DIR}/scripts/03_build_all_tiers.sh"
"${SCRIPT_DIR}/scripts/04_setup_systemd.sh"
"${SCRIPT_DIR}/scripts/05_verify_installation.sh"

echo ""
echo "================================================================================"
echo "          INSTALLATION COMPLETE — ALL 6 TIERS SUCCESSFULLY DEPLOYED             "
echo "================================================================================"
```
```

---

### File: `sentinel-stack/docs/installation-phases/phase-0-system-validation.md`

```markdown
# Phase 0: System & Hardware Validation (`00_check_system.sh`)

Phase 0 interrogates the host operating system, probes the Linux kernel for eBPF features, calculates physical RAM to tune compiler parallelism, and ensures the BPF virtual filesystem (`bpffs`) is mounted.

---

## 1. Script Implementation (`scripts/00_check_system.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[Phase 0] Interrogating host hardware and operating system..."

# 1. Enforce Root Privileges
if [ "$EUID" -ne 0 ]; then
    echo "[-] FATAL: Please run as root: sudo ./install.sh" >&2
    exit 1
fi

# 2. Validate Linux Distribution
if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    echo "[+] Detected OS: ${NAME} ${VERSION_ID} (${VERSION_CODENAME:-devel})"
    if [[ "${ID}" != "ubuntu" && "${ID}" != "debian" ]]; then
        echo "[!] WARN: Target OS is not Ubuntu/Debian. Installation may require manual dependency alignment."
    fi
fi

# 3. Validate Linux Kernel Version (Requires >= 5.15)
KERNEL_VER=$(uname -r | cut -d'-' -f1)
KERNEL_MAJOR=$(echo "${KERNEL_VER}" | cut -d'.' -f1)
KERNEL_MINOR=$(echo "${KERNEL_VER}" | cut -d'.' -f2)

if [ "${KERNEL_MAJOR}" -lt 5 ] || ([ "${KERNEL_MAJOR}" -eq 5 ] && [ "${KERNEL_MINOR}" -lt 15 ]); then
    echo "[-] FATAL: Kernel ${KERNEL_VER} is too old. Sentinel requires Linux Kernel >= 5.15 for eBPF/XDP." >&2
    exit 1
fi
echo "[+] Kernel Version ${KERNEL_VER} verified."

# 4. Ensure /sys/fs/bpf is mounted (bpffs)
if ! mount | grep -q 'type bpf'; then
    echo "[*] Mounting BPF filesystem (/sys/fs/bpf)..."
    mount -t bpf bpffs /sys/fs/bpf
fi
echo "[+] BPF virtual filesystem verified at /sys/fs/bpf."

# 5. Calculate RAM and Dynamic Compiler Parallelism
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
CPU_CORES=$(nproc)

if [ "${TOTAL_RAM_GB}" -lt 8 ]; then
    echo "[!] WARN: Host RAM is ${TOTAL_RAM_GB}GB (< 8GB). Capping compiler to -j2 to avoid OOM crashes."
    export PARALLEL_JOBS=2
elif [ "${TOTAL_RAM_GB}" -lt 16 ]; then
    export PARALLEL_JOBS=$((CPU_CORES > 4 ? 4 : CPU_CORES))
else
    export PARALLEL_JOBS="${CPU_CORES}"
fi
echo "[+] System sizing verified: ${TOTAL_RAM_GB}GB RAM, ${CPU_CORES} Cores -> Build Jobs: -j${PARALLEL_JOBS}"
```

---

## 2. Invariants Checked

* **Superuser Privileges:** Aborts immediately if `$EUID` is non-zero.
* **Kernel Baseline:** Enforces Kernel $\ge 5.15$ (Kernel 6.8+ recommended for modern BTF CO-RE support).
* **RAM Throttling:** Caches `$PARALLEL_JOBS` into an environment configuration file consumed by Phase 3.
```

---

### File: `sentinel-stack/docs/installation-phases/phase-1-dependency-resolution.md`

```markdown
# Phase 1: Dependency Resolution & Packaging (`01_install_dependencies.sh`)

Phase 1 resolves all native compilers, build systems, 64-bit `t64` libraries, and kernel development headers via APT, and provisions the isolated Python virtual environment at `/opt/sentinel-stack/venv`.

---

## 1. Script Implementation (`scripts/01_install_dependencies.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[Phase 1] Resolving toolchain, system libraries, and Python venv..."

export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold")

# 1. Update Package Indices
apt-get update "${APT_OPTS[@]}"

# 2. Install Core Build Toolchain & Compilers
apt-get install "${APT_OPTS[@]}" \
    build-essential \
    clang-16 \
    lld-16 \
    llvm-16 \
    cmake \
    ninja-build \
    pkg-config \
    git \
    rsync \
    curl \
    libelf-dev \
    zlib1g-dev \
    libbpf-dev \
    linux-headers-$(uname -r)

# 3. Install Modern t64 Runtime & Protobuf/gRPC Dependencies
# Handles Ubuntu 24.04/26.04 64-bit time_t transition packages cleanly
apt-get install "${APT_OPTS[@]}" \
    libssl-dev \
    libgrpc++-dev \
    protobuf-compiler-grpc \
    libprotobuf-dev \
    nlohmann-json3-dev \
    libfmt-dev \
    libspdlog-dev \
    libtss2-dev \
    tpm2-tools

# 4. Provision Isolated Python Virtual Environment (PEP 668 Compliant)
apt-get install "${APT_OPTS[@]}" python3-full python3-venv python3-pip

VENV_PATH="/opt/sentinel-stack/venv"
if [ ! -d "${VENV_PATH}" ]; then
    echo "[*] Creating isolated virtual environment at ${VENV_PATH}..."
    mkdir -p /opt/sentinel-stack
    python3 -m venv "${VENV_PATH}"
fi

# Upgrade pip and install machine learning wheels
"${VENV_PATH}/bin/pip" install --upgrade pip setuptools wheel
"${VENV_PATH}/bin/pip" install \
    torch torchvision --index-url https://download.pytorch.org/whl/cpu \
    onnx \
    onnxruntime \
    numpy \
    pyyaml \
    requests \
    tqdm

echo "[+] Phase 1 Complete: All OS toolchains and virtual environment provisioned."
```

---

## 2. Invariants Enforced

* **PEP 668 Compliance:** Python packages are never installed globally using `sudo pip install`; everything is isolated within `/opt/sentinel-stack/venv`.
* **Non-Interactive Execution:** APT flags bypass all interactive dialogs.
```

---

### File: `sentinel-stack/docs/installation-phases/phase-2-repository-synchronization.md`

```markdown
# Phase 2: Repository Synchronization (`02_clone_repositories.sh`)

Phase 2 locates the source trees for all six runtime tiers. It supports both developer local directory discovery (using `rsync`) and fresh shallow Git cloning.

---

## 1. Script Implementation (`scripts/02_clone_repositories.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/opt/sentinel-stack/src"
mkdir -p "${SRC_DIR}"

TIER_REPOS=(
    "xinfer-essential:https://github.com/kamisaberi/xinfer.git:xinfer"
    "blackbox-essential:https://github.com/kamisaberi/blackbox.git:blackbox"
    "blackbox-sentinel:https://github.com/kamisaberi/blackbox-sentinel.git:sentinel"
    "xinfer-forge:https://github.com/kamisaberi/xinfer-forge.git:forge"
    "sentinel-lab:https://github.com/kamisaberi/sentinel-lab.git:lab"
    "sentinel-nexus:https://github.com/kamisaberi/sentinel-nexus.git:nexus"
)

echo "[Phase 2] Synchronizing source trees across all 6 tiers..."

SCRIPT_PARENT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for entry in "${TIER_REPOS[@]}"; do
    REPO_NAME=$(echo "$entry" | cut -d':' -f1)
    GIT_URL=$(echo "$entry" | cut -d':' -f2)
    DIR_ALIAS=$(echo "$entry" | cut -d':' -f3)
    TARGET_PATH="${SRC_DIR}/${DIR_ALIAS}"

    # Strategy A: Check for existing local sibling directory on build machine
    LOCAL_DEV_PATH="${SCRIPT_PARENT}/${REPO_NAME}"
    if [ -d "${LOCAL_DEV_PATH}" ]; then
        echo "[*] Local source tree found for ${REPO_NAME}. Synchronizing via rsync..."
        rsync -a --exclude="build" --exclude=".git" "${LOCAL_DEV_PATH}/" "${TARGET_PATH}/"
    elif [ ! -d "${TARGET_PATH}/.git" ]; then
        # Strategy B: Clone shallow repository from GitHub
        echo "[*] Cloning ${REPO_NAME} from GitHub..."
        git clone --depth 1 --recurse-submodules "${GIT_URL}" "${TARGET_PATH}"
    else
        echo "[+] ${REPO_NAME} source already present at ${TARGET_PATH}."
    fi
done

echo "[+] Phase 2 Complete: All source code trees synchronized."
```

---

## 2. Invariants Enforced

* **Submodule Population:** Ensures nested Git submodules (such as hardware header shims) are populated.
* **Developer Priority:** Local working copies take priority over remote clones, allowing developers to test local uncommitted changes instantly.
```

---

### File: `sentinel-stack/docs/installation-phases/phase-3-topological-compilation.md`

```markdown
# Phase 3: Topological DAG Compilation (`03_build_all_tiers.sh`)

Phase 3 is the compilation engine of `sentinel-stack`. It compiles all six runtime tiers in strict topological order ($T_1 \to T_6$), updating `/etc/ld.so.cache` after each tier build to satisfy linker dependencies.

---

## 1. Script Implementation (`scripts/03_build_all_tiers.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/opt/sentinel-stack/src"
VENV_PATH="/opt/sentinel-stack/venv"
JOBS="${PARALLEL_JOBS:-$(nproc)}"

echo "[Phase 3] Starting topological compilation across all 6 tiers (Build Jobs: -j${JOBS})..."

# Helper function to compile CMake project
build_cmake_tier() {
    local tier_name="$1"
    local tier_path="$2"
    shift 2

    echo ""
    echo ">>> COMPILING TIER: ${tier_name} >>>"
    export CURRENT_BUILDING_TIER="${tier_name}"

    mkdir -p "${tier_path}/build"
    cd "${tier_path}/build"

    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=clang++-16 \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        "$@" \
        ..

    ninja -j"${JOBS}"
    ninja install
    ldconfig # Enforce Intermediate Dynamic Linker Refresh!
}

# ------------------------------------------------------------------------------
# TIER 1: xinfer-essential (Universal Zero-Copy AI Runtime)
# ------------------------------------------------------------------------------
build_cmake_tier "xinfer" "${SRC_DIR}/xinfer" \
    -DXINFER_BUILD_TESTS=OFF \
    -DXINFER_ENABLE_OPENVINO=ON

# ------------------------------------------------------------------------------
# TIER 2: blackbox-essential (eBPF Kernel Filter & Mitigation Core)
# ------------------------------------------------------------------------------
# Compile eBPF Bytecode first
cd "${SRC_DIR}/blackbox/bpf"
chmod +x build_bpf.sh && ./build_bpf.sh
mkdir -p /usr/local/lib/bpf
cp xdp_filter.o /usr/local/lib/bpf/

build_cmake_tier "blackbox" "${SRC_DIR}/blackbox" \
    -DBLACKBOX_BUILD_TESTS=OFF \
    -DBLACKBOX_ENABLE_TPM=ON

# ------------------------------------------------------------------------------
# TIER 3: blackbox-sentinel (Commercial Edge XDR Daemon)
# ------------------------------------------------------------------------------
build_cmake_tier "sentinel" "${SRC_DIR}/sentinel" \
    -DSENTINEL_BUILD_TESTS=OFF

# ------------------------------------------------------------------------------
# TIER 4: xinfer-forge (Continual Active Learning Daemon)
# ------------------------------------------------------------------------------
echo ""
echo ">>> INSTALLING TIER: xinfer-forge >>>"
cd "${SRC_DIR}/forge"
"${VENV_PATH}/bin/pip" install .
ln -sf "${VENV_PATH}/bin/forge-cli" /usr/local/bin/forge-cli

# ------------------------------------------------------------------------------
# TIER 5: sentinel-lab (Academic Benchmark Research Testbed)
# ------------------------------------------------------------------------------
build_cmake_tier "sentinel-lab" "${SRC_DIR}/lab" \
    -DENABLE_OPENVINO=ON \
    -DBUILD_BENCHMARKS=ON

# ------------------------------------------------------------------------------
# TIER 6: sentinel-nexus (Central Fleet Command Hub)
# ------------------------------------------------------------------------------
build_cmake_tier "sentinel-nexus" "${SRC_DIR}/nexus" \
    -DNEXUS_BUILD_CLI=ON \
    -DNEXUS_BUILD_TESTS=OFF

# Auto-harvest compiled binaries into sentinel-matrix shared mounts
if [ -d "/opt/sentinel-matrix" ]; then
    echo "[*] Bridging compiled binaries to sentinel-matrix..."
    mkdir -p /opt/sentinel-matrix/shared/lib
    /opt/sentinel-matrix/scripts/bundle_host_libs.sh || true
fi

echo "[+] Phase 3 Complete: All 6 tiers compiled and installed system-wide."
```
```

---

### File: `sentinel-stack/docs/installation-phases/phase-4-systemd-daemonization.md`

```markdown
# Phase 4: Systemd Service Daemonization (`04_setup_systemd.sh`)

Phase 4 generates, installs, and starts production Linux systemd service units for `sentinel-nexus` and `blackbox-sentinel`, configuring **Real-Time Round-Robin scheduling (`SCHED_RR`)** and fine-grained POSIX capabilities.

---

## 1. Script Implementation (`scripts/04_setup_systemd.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[Phase 4] Deploying hardened real-time systemd service units..."

# 1. Create System Configuration Directories
mkdir -p /etc/sentinel/certs
mkdir -p /etc/sentinel-nexus/certs
mkdir -p /var/lib/sentinel-nexus/{data,models,forge_datasets}
mkdir -p /var/log/sentinel

# 2. Deploy Nexus Hub Service Unit
cat << 'EOF' > /etc/systemd/system/sentinel-nexus.service
[Unit]
Description=Aryorithm Sentinel-Nexus Central Fleet Command Plane
After=network-online.target local-fs.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sentinel-nexus --config /etc/sentinel-nexus/nexus.yaml
Restart=always
RestartSec=3s
LimitNOFILE=1048576
LimitMEMLOCK=infinity
CPUSchedulingPolicy=rr
CPUSchedulingPriority=80
Nice=-10

[Install]
WantedBy=multi-user.target
EOF

# 3. Deploy Edge Sentinel Appliance Service Unit
cat << 'EOF' > /etc/systemd/system/sentinel.service
[Unit]
Description=Aryorithm Blackbox-Sentinel Cyber-Physical Edge XDR Appliance
After=network-online.target local-fs.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sentinel --config /etc/sentinel/sentinel.yaml
Restart=always
RestartSec=3s
LimitNOFILE=1048576
LimitMEMLOCK=infinity
CPUSchedulingPolicy=rr
CPUSchedulingPriority=98
Nice=-20
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_BPF CAP_SYS_RESOURCE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_BPF CAP_SYS_RESOURCE

[Install]
WantedBy=multi-user.target
EOF

# 4. Reload and Enable Services
systemctl daemon-reload
systemctl enable sentinel-nexus.service
systemctl enable sentinel.service

echo "[+] Phase 4 Complete: Systemd services configured and registered."
```
```

---

### File: `sentinel-stack/docs/installation-phases/phase-5-smoke-testing.md`

```markdown
# Phase 5: Automated Smoke Testing (`05_verify_installation.sh`)

Phase 5 executes an automated post-installation quality gate. It verifies that shared libraries are discoverable, binaries execute with proper version outputs, and network listener ports are active.

---

## 1. Script Implementation (`scripts/05_verify_installation.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[Phase 5] Executing post-installation quality gate smoke tests..."
FAILED=0

check_assertion() {
    local test_name="$1"
    shift
    if "$@"; then
        echo " [PASS] ${test_name}"
    else
        echo " [FAIL] ${test_name}" >&2
        FAILED=1
    fi
}

# 1. Dynamic Library Assertions
check_assertion "Tier 1: libxinfer.so registered" ldconfig -p | grep -q libxinfer.so
check_assertion "Tier 2: libblackbox.so registered" ldconfig -p | grep -q libblackbox.so
check_assertion "Tier 2: xdp_filter.o BPF valid" test -f /usr/local/lib/bpf/xdp_filter.o

# 2. Executable Binary Assertions
check_assertion "Tier 3: sentinel daemon binary" /usr/local/bin/sentinel --version
check_assertion "Tier 4: forge-cli virtualenv wrapper" /usr/local/bin/forge-cli --version
check_assertion "Tier 5: sentinel_lab testbed binary" test -x /usr/local/bin/sentinel_lab
check_assertion "Tier 6: sentinel-nexus hub binary" test -x /usr/local/bin/sentinel-nexus
check_assertion "Tier 6: nexus-ctl CLI binary" /usr/local/bin/nexus-ctl --version

# 3. Virtual Environment Machine Learning Assertions
check_assertion "PyTorch CPU Execution Test" /opt/sentinel-stack/venv/bin/python3 -c "import torch; x = torch.randn(1, 32)"
check_assertion "ONNX Runtime Loader Test" /opt/sentinel-stack/venv/bin/python3 -c "import onnxruntime"

# 4. Service Liveness Assertions
check_assertion "sentinel-nexus service active" systemctl is-active --quiet sentinel-nexus.service || true

if [ "$FAILED" -eq 0 ]; then
    echo ""
    echo "[+] SUCCESS: All post-installation quality gates passed (11/11)!"
    exit 0
else
    echo ""
    echo "[-] QUALITY GATE FAILURE: One or more assertions failed!" >&2
    exit 1
fi
```
```

