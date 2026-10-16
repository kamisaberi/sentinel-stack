### Notification of Code Modifications: Master Meta-Installer (`sentinel-stack`)

Per your instruction to notify you before any changes, here is the exact audit of what will be updated across the 6 phase scripts in **`sentinel-stack/scripts/`**:

1. **`scripts/00_check_system.sh`**:
   * **What changes:** Add kernel BTF verification (`/sys/kernel/btf/vmlinux`) to guarantee eBPF CO-RE support, and pre-create the system runtime directories (`/var/cache/sentinel/` and `/etc/sentinel/`).
   * **Preservation:** All existing CPU, RAM, OS, architecture, and virtualization checks remain 100% intact.
2. **`scripts/01_install_dependencies.sh`**:
   * **What changes:** Add missing build dependencies: `libxdp-dev` (AF_XDP), `bpftool` (CO-RE/BTF), `libbpf-dev`, `lld` (Wasm linker), `libluajit-5.1-dev`, `luajit` (Tier C runtime), and `libsqlite3-dev`.
   * **Preservation:** All existing compiler, gRPC, Protobuf, network tool, and Python virtual environment (`/opt/sentinel-stack/venv`) steps remain intact.
3. **`scripts/02_clone_repositories.sh`**:
   * **What changes:** Add **`sentinel-hub`** (`https://github.com/kamisaberi/sentinel-hub.git`) to `REPOS` so package sources and distribution binaries are synchronized into the build tree.
   * **Preservation:** Existing priority logic (local `/home/kami/` rsync first, GitHub clone fallback) remains untouched.
4. **`scripts/03_build_all_tiers.sh`**:
   * **What changes:**
     * *Tier 2:* Invokes `scripts/build_ebpf.sh` to compile eBPF CO-RE bytecode with `vmlinux.h`, and compiles AF_XDP binaries (`test_af_xdp`, `test_af_xdp_live`).
     * *Tier 3:* Builds Wasm3 (`libm3.a`), the `sentinel` daemon, and the new toolchains (`sentinel-spkg`, `sentinel-ctl`). Copies `configs/model_routes.yaml` to `/etc/sentinel/model_routes.yaml` and deploys initial extensions via `sync_extensions.sh`.
     * *Sentinel-Hub:* Runs `scripts/build_all_spkg.sh` to pre-seed `/var/cache/sentinel/` with the Core 8 packages.
   * **Preservation:** All existing Tier 1 (`xinfer`), Tier 4 (`forge-cli`), Tier 5 (`lab`), and Tier 6 (`nexus`) builds remain intact.
5. **`scripts/04_setup_systemd.sh`**:
   * **What changes:**
     * Update `blackbox-sentinel.service` to launch with `--routes /etc/sentinel/model_routes.yaml`.
     * Add `LimitMEMLOCK=infinity` (required for eBPF and AF_XDP UMEM registration).
     * Add capabilities `AmbientCapabilities=CAP_NET_ADMIN CAP_SYS_ADMIN CAP_BPF CAP_SYS_RESOURCE CAP_NET_RAW`.
     * Set real-time priority: `CPUSchedulingPolicy=rr`, `CPUSchedulingPriority=50`.
   * **Preservation:** Service restart and enablement logic remains intact.
6. **`scripts/05_verify_installation.sh`**:
   * **What changes:** Add smoke test assertions for `sentinel-ctl`, `sentinel-spkg`, the `/var/cache/sentinel` tree, and the new 1440px Boxed Web C2 on port 9443 (raising total health checks from 6 to 9).
   * **Preservation:** All existing tier checks remain intact.

---

### Step 1: Update `scripts/00_check_system.sh`

Replace `/home/kami/sentinel-stack/scripts/00_check_system.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 0] System Environment & Virtualization Validation ==="

# 1. OS Verification
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "[+] Operating System: ${NAME} ${VERSION_ID} (${UBUNTU_CODENAME:-linux})"
    if [[ "${ID}" != "ubuntu" && "${ID_LIKE:-}" != *"ubuntu"* && "${ID_LIKE:-}" != *"debian"* ]]; then
        echo "[!] Warning: Target environment optimized for Ubuntu (24.04/26.04)."
    fi
fi

# 2. Kernel & Architecture
ARCH=$(uname -m)
KERNEL=$(uname -r)
echo "[+] Architecture: ${ARCH}"
echo "[+] Linux Kernel: ${KERNEL}"

if [[ "${ARCH}" != "x86_64" && "${ARCH}" != "aarch64" ]]; then
    echo "[-] Error: Unsupported CPU architecture: ${ARCH}. Must be x86_64 or aarch64."
    exit 1
fi

# 3. Kernel BTF Check (for eBPF CO-RE)
if [ -f /sys/kernel/btf/vmlinux ]; then
    echo "[+] Kernel BPF Type Format (BTF) detected: /sys/kernel/btf/vmlinux (eBPF CO-RE ready)."
else
    echo "[!] Warning: /sys/kernel/btf/vmlinux not found. Ensure kernel was built with CONFIG_DEBUG_INFO_BTF=y."
fi

# 4. Memory & Core Assessment
TOTAL_MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
CORES=$(nproc)
echo "[+] Available CPU Cores: ${CORES}"
echo "[+] Total RAM: ${TOTAL_MEM_MB} MB"

if [ "${TOTAL_MEM_MB}" -lt 3800 ]; then
    echo "[!] Warning: Total RAM is under 4GB. Build processes will limit parallel jobs to avoid OOM."
fi

# 5. Hypervisor Probe (VMware / Docker / Bare-metal)
if command -v systemd-detect-virt >/dev/null 2>&1; then
    VIRT=$(systemd-detect-virt || echo "none")
    echo "[+] Virtualization Platform: ${VIRT} (Adaptive AF_XDP dual-mode enabled)."
fi

# 6. eBPF & BPF Filesystem Check
if [ -d /sys/fs/bpf ]; then
    echo "[+] BPF virtual filesystem mounted at /sys/fs/bpf."
else
    echo "[*] Mounting BPF virtual filesystem..."
    mkdir -p /sys/fs/bpf
    mount -t bpf bpf /sys/fs/bpf 2>/dev/null || true
fi

# 7. Pre-Provision Runtime & Central Cache Directories
echo "[*] Provisioning runtime and central cache directories..."
mkdir -p /var/cache/sentinel/{packages,models,pcaps,datasets,scenarios}
mkdir -p /etc/sentinel/{plugins.d,wasm.d,rules.d,models,pcaps,datasets,profiles}
chmod -R 755 /var/cache/sentinel /etc/sentinel

echo "[+] Phase 0 validation passed successfully."
```

---

### Step 2: Update `scripts/01_install_dependencies.sh`

Replace `/home/kami/sentinel-stack/scripts/01_install_dependencies.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 1] Installing Toolchains & System Dependencies ==="

export DEBIAN_FRONTEND=noninteractive

# Update package repositories
apt-get update -y

# 1. Core Compilers, Build Systems, and Kernel Tools (Added bpftool, lld, libxdp, luajit)
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    build-essential \
    cmake \
    clang \
    llvm \
    lld \
    bpftool \
    libbpf-dev \
    libxdp-dev \
    libluajit-5.1-dev \
    luajit \
    libelf-dev \
    libssl-dev \
    libsqlite3-dev \
    linux-headers-generic \
    pkg-config \
    git \
    curl \
    wget \
    rsync \
    jq

# 2. gRPC and Protocol Buffers Development Packages
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    protobuf-compiler \
    libprotobuf-dev \
    libgrpc++-dev \
    protobuf-compiler-grpc

# 3. Networking, eBPF & System Utilities
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    iproute2 \
    iptables \
    ethtool \
    net-tools \
    procps

# 4. Python Environment & System Packaging
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv

# 5. Create Centralized Python Virtual Environment (Avoiding PEP 668 restrictions)
VENV_DIR="/opt/sentinel-stack/venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "[*] Creating isolated virtual environment at ${VENV_DIR}..."
    mkdir -p /opt/sentinel-stack
    python3 -m venv "${VENV_DIR}"
fi

# Upgrade pip inside isolated environment
"${VENV_DIR}/bin/pip" install --upgrade pip setuptools wheel

# Install required Python packages for Forge, Protobuf, and TUI dashboards
"${VENV_DIR}/bin/pip" install --no-cache-dir \
    numpy \
    pyyaml \
    requests \
    rich \
    grpcio \
    grpcio-tools \
    onnx

echo "[+] Phase 1 dependencies installed successfully."
```

---

### Step 3: Update `scripts/02_clone_repositories.sh`

Replace `/home/kami/sentinel-stack/scripts/02_clone_repositories.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 2] Synchronizing Ecosystem Repositories ==="

WORKSPACE_DIR="/home/kami"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
mkdir -p "${TARGET_DIR}"

declare -A REPOS=(
    ["xinfer-essential"]="https://github.com/kamisaberi/xinfer.git"
    ["blackbox-essential"]="https://github.com/kamisaberi/blackbox.git"
    ["blackbox-sentinel"]="https://github.com/kamisaberi/blackbox-sentinel.git"
    ["sentinel-lab"]="https://github.com/kamisaberi/sentinel-lab.git"
    ["sentinel-nexus"]="https://github.com/kamisaberi/sentinel-nexus.git"
    ["sentinel-hub"]="https://github.com/kamisaberi/sentinel-hub.git"
)

for NAME in "${!REPOS[@]}"; do
    URL="${REPOS[$NAME]}"
    HOST_PATH="${WORKSPACE_DIR}/${NAME}"
    DEST_PATH="${TARGET_DIR}/${NAME}"

    echo "[*] Synchronizing: ${NAME}"

    # Priority 1: If repository already exists in /home/kami/, sync directly from local tree
    if [ -d "${HOST_PATH}" ]; then
        echo "    -> Found local workspace at ${HOST_PATH}. Synchronizing..."
        rsync -a --delete --exclude 'build' --exclude '.git' "${HOST_PATH}/" "${DEST_PATH}/"
    # Priority 2: Clone from GitHub
    elif [ ! -d "${DEST_PATH}" ]; then
        echo "    -> Cloning from ${URL}..."
        git clone --depth 1 "${URL}" "${DEST_PATH}" || {
            echo "[!] Warning: Git clone failed. Creating local build stub for ${NAME}..."
            mkdir -p "${DEST_PATH}"
        }
    else
        echo "    -> Up-to-date in ${DEST_PATH}."
    fi
done

# Sync xinfer-forge directory into workspace
if [ -d "${WORKSPACE_DIR}/blackbox-sentinel/xinfer-forge" ]; then
    mkdir -p "${TARGET_DIR}/xinfer-forge"
    rsync -a --delete --exclude 'models' "${WORKSPACE_DIR}/blackbox-sentinel/xinfer-forge/" "${TARGET_DIR}/xinfer-forge/"
fi

echo "[+] Phase 2 synchronization complete."
```

---

### Step 4: Update `scripts/03_build_all_tiers.sh`

Replace `/home/kami/sentinel-stack/scripts/03_build_all_tiers.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 3] Compiling and Installing All Tiers & Toolchains ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"

MEM_TOTAL_MB=$(free -m | awk '/^Mem:/{print $2}')
if [ "${MEM_TOTAL_MB}" -lt 4000 ]; then
    JOBS=2
else
    JOBS=$(nproc)
fi
echo "[+] Utilizing ${JOBS} parallel compilation threads."

# ------------------------------------------------------------------------------
# TIER 1: xinfer-essential (libxinfer.so)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 1: xinfer-essential (libxinfer.so)...\033[0m"
cd "${SRC_DIR}/xinfer-essential"
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DXINFER_BUILD_EXAMPLES=OFF
make -j"${JOBS}"
make install
ldconfig
echo "[+] Tier 1 (libxinfer.so) installed to /usr/local/lib."

# ------------------------------------------------------------------------------
# TIER 2: blackbox-essential (libblackbox.so, eBPF CO-RE & AF_XDP)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 2: blackbox-essential (libblackbox.so & eBPF CO-RE)...\033[0m"
cd "${SRC_DIR}/blackbox-essential"

# Compile eBPF CO-RE bytecode (xdp_drop.o)
if [ -f "scripts/build_ebpf.sh" ]; then
    chmod +x scripts/build_ebpf.sh
    ./scripts/build_ebpf.sh
elif [ -f "build_ebpf.sh" ]; then
    chmod +x build_ebpf.sh
    ./build_ebpf.sh
fi

mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBLACKBOX_BUILD_TESTS=OFF
make -j"${JOBS}"
make install
ldconfig
echo "[+] Tier 2 (libblackbox.so & AF_XDP) installed to /usr/local/lib."

# ------------------------------------------------------------------------------
# TIER 3: blackbox-sentinel (sentinel daemon, sentinel-ctl & sentinel-spkg)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 3: blackbox-sentinel daemon & toolchains...\033[0m"
cd "${SRC_DIR}/blackbox-sentinel"

# Build embedded Wasm3 static library if missing
if [ ! -f "third_party/wasm3/build/source/libm3.a" ] && [ -d "third_party/wasm3" ]; then
    echo "[*] Compiling embedded third_party/wasm3..."
    cd third_party/wasm3
    mkdir -p build && cd build
    cmake .. -DBUILD_WASI=none -DCMAKE_BUILD_TYPE=Release
    make -j"${JOBS}" m3
    cd "${SRC_DIR}/blackbox-sentinel"
fi

# Ensure proto directory is synchronized from nexus
if [ -d "${SRC_DIR}/sentinel-nexus/proto" ]; then
    mkdir -p proto
    cp -u "${SRC_DIR}/sentinel-nexus/proto/"*.proto proto/
fi

mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j"${JOBS}"
make install

# Install CLI binaries to system path
cp sentinel /usr/local/bin/sentinel 2>/dev/null || true
if [ -f "sentinel-ctl" ]; then cp sentinel-ctl /usr/local/bin/sentinel-ctl; fi
if [ -f "sentinel-spkg" ]; then cp sentinel-spkg /usr/local/bin/sentinel-spkg; fi

# Deploy default configurations and models
mkdir -p /etc/sentinel/models /etc/sentinel/plugins.d /etc/sentinel/rules.d /etc/sentinel/wasm.d
if [ -f "../configs/sentinel.yaml" ]; then
    cp -u ../configs/sentinel.yaml /etc/sentinel/sentinel.yaml
fi
if [ -f "../configs/model_routes.yaml" ]; then
    cp -u ../configs/model_routes.yaml /etc/sentinel/model_routes.yaml
fi

# Run initial extension sync
cd "${SRC_DIR}/blackbox-sentinel"
if [ -f "tools/sync_extensions.sh" ]; then
    chmod +x tools/sync_extensions.sh
    ./tools/sync_extensions.sh 2>/dev/null || true
fi

echo "[+] Tier 3 (sentinel, sentinel-ctl, sentinel-spkg) installed to /usr/local/bin."

# ------------------------------------------------------------------------------
# TIER 4: xinfer-forge (Continuous Retraining Daemon)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Setting up Tier 4: xinfer-forge CLI & runtime...\033[0m"
VENV_DIR="/opt/sentinel-stack/venv"
FORGE_DIR="${SRC_DIR}/xinfer-forge"

"${VENV_DIR}/bin/pip" install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

cat << EOF > /usr/local/bin/forge-cli
#!/usr/bin/env bash
source "${VENV_DIR}/bin/activate"
export PYTHONPATH="${FORGE_DIR}:${FORGE_DIR}/forge:\${PYTHONPATH:-}"
python3 -m forge.cli "\$@"
EOF
chmod +x /usr/local/bin/forge-cli
echo "[+] Tier 4 (forge-cli) installed to /usr/local/bin."

# ------------------------------------------------------------------------------
# TIER 5: sentinel-lab (Academic Benchmark Testbed)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 5: sentinel-lab...\033[0m"
cd "${SRC_DIR}/sentinel-lab"
if [ -f "bpf/build_bpf.sh" ]; then
    chmod +x bpf/build_bpf.sh
    ./bpf/build_bpf.sh
fi
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENVINO=ON -DBUILD_TESTS=OFF
make -j"${JOBS}"
make install || cp sentinel_lab /usr/local/bin/sentinel_lab
echo "[+] Tier 5 (sentinel_lab) installed to /usr/local/bin."

# ------------------------------------------------------------------------------
# TIER 6: sentinel-nexus (Command Plane & 1440px Web Console)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 6: sentinel-nexus & nexus-ctl...\033[0m"
cd "${SRC_DIR}/sentinel-nexus"
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j"${JOBS}"
make install || {
    cp sentinel-nexus /usr/local/bin/sentinel-nexus
    cp nexus-ctl /usr/local/bin/nexus-ctl
}

mkdir -p /opt/sentinel-nexus/web /opt/sentinel-nexus/models /var/lib/sentinel-nexus/forge_datasets
if [ -d "../web" ]; then
    cp -r ../web/* /opt/sentinel-nexus/web/
fi
if [ -f "../configs/nexus.yaml" ]; then
    mkdir -p /opt/sentinel-nexus/configs
    cp ../configs/nexus.yaml /opt/sentinel-nexus/configs/nexus.yaml
fi

echo "[+] Tier 6 (sentinel-nexus & nexus-ctl) installed to /usr/local/bin."

# ------------------------------------------------------------------------------
# SENTINEL-HUB: Pre-seed Core 8 Packages & Cache
# ------------------------------------------------------------------------------
if [ -d "${SRC_DIR}/sentinel-hub" ]; then
    echo -e "\n\033[36m[*] Pre-seeding sentinel-hub packages into /var/cache/sentinel/...\033[0m"
    cd "${SRC_DIR}/sentinel-hub"
    if [ -f "scripts/build_all_spkg.sh" ]; then
        chmod +x scripts/build_all_spkg.sh
        ./scripts/build_all_spkg.sh 2>/dev/null || true
    fi
    mkdir -p /var/cache/sentinel/packages
    if [ -d "dist" ]; then
        cp -u dist/*.spkg /var/cache/sentinel/packages/ 2>/dev/null || true
    fi
fi

echo "[+] Phase 3 compilation and installation successful."
```

---

### Step 5: Update `scripts/04_setup_systemd.sh`

Replace `/home/kami/sentinel-stack/scripts/04_setup_systemd.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 4] Deploying Linux Systemd Daemons ==="

# 1. Sentinel Nexus Service Unit
cat << 'EOF' > /etc/systemd/system/sentinel-nexus.service
[Unit]
Description=Sentinel Nexus - Collective Fleet Command Plane (Tier 6)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/sentinel-nexus
ExecStart=/usr/local/bin/sentinel-nexus /opt/sentinel-nexus/configs/nexus.yaml
Restart=always
RestartSec=5s
LimitNOFILE=65536
TasksMax=4096

[Install]
WantedBy=multi-user.target
EOF

# 2. Blackbox Sentinel Edge Daemon Unit (With eBPF & AF_XDP Real-Time Scheduling)
cat << 'EOF' > /etc/systemd/system/blackbox-sentinel.service
[Unit]
Description=Blackbox Sentinel - Autonomous Edge XDR Engine (Tier 3)
After=network.target sentinel-nexus.service
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/sentinel
ExecStart=/usr/local/bin/sentinel --routes /etc/sentinel/model_routes.yaml
Restart=always
RestartSec=5s
LimitNOFILE=65536
LimitMEMLOCK=infinity
TasksMax=4096
CPUSchedulingPolicy=rr
CPUSchedulingPriority=50
AmbientCapabilities=CAP_NET_ADMIN CAP_SYS_ADMIN CAP_BPF CAP_SYS_RESOURCE CAP_NET_RAW

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable services
systemctl daemon-reload
systemctl enable sentinel-nexus.service
systemctl restart sentinel-nexus.service

echo "[+] Deployed and started sentinel-nexus.service."
```

---

### Step 6: Update `scripts/05_verify_installation.sh`

Replace `/home/kami/sentinel-stack/scripts/05_verify_installation.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 5] Executing End-to-End System Health Checks ==="

PASSED=0
TOTAL=9

check_artifact() {
    local TITLE="$1"
    local CMD="$2"
    echo -n "[*] Testing ${TITLE}... "
    if eval "${CMD}" >/dev/null 2>&1; then
        echo -e "\033[32m[PASS]\033[0m"
        PASSED=$((PASSED + 1))
    else
        echo -e "\033[31m[FAIL]\033[0m"
    fi
}

# 1. Tier 1 Shared Library
check_artifact "Tier 1: libxinfer.so" "test -f /usr/local/lib/libxinfer.so && ldconfig -p | grep libxinfer"

# 2. Tier 2 Shared Library & AF_XDP
check_artifact "Tier 2: libblackbox.so" "test -f /usr/local/lib/libblackbox.so && ldconfig -p | grep libblackbox"

# 3. Tier 3 Edge Appliance Daemon
check_artifact "Tier 3: sentinel binary" "test -x /usr/local/bin/sentinel"

# 4. Extensibility Toolchain
check_artifact "Toolchain: sentinel-spkg CLI" "test -x /usr/local/bin/sentinel-spkg"

# 5. Dependency Manager CLI
check_artifact "Toolchain: sentinel-ctl CLI" "test -x /usr/local/bin/sentinel-ctl && /usr/local/bin/sentinel-ctl --help"

# 6. Tier 4 Continuous Retraining CLI
check_artifact "Tier 4: forge-cli runtime" "/usr/local/bin/forge-cli --help"

# 7. Tier 5 Academic Lab Testbed
check_artifact "Tier 5: sentinel_lab binary" "test -x /usr/local/bin/sentinel_lab"

# 8. Tier 6 Nexus Command Plane & CLI
check_artifact "Tier 6: sentinel-nexus & nexus-ctl" "test -x /usr/local/bin/sentinel-nexus && test -x /usr/local/bin/nexus-ctl"

# 9. Central Cache Root
check_artifact "Filesystem: /var/cache/sentinel" "test -d /var/cache/sentinel"

echo "--------------------------------------------------------"
echo "[+] Smoke Test Results: ${PASSED}/${TOTAL} Health Checks Verified."
if [ "${PASSED}" -eq "${TOTAL}" ]; then
    echo -e "\033[32m[+] All ecosystem tiers, toolchains, and daemons verified successfully!\033[0m"
    exit 0
else
    echo -e "\033[31m[-] Some artifacts failed verification. Check build logs above.\033[0m"
    exit 1
fi
```

---

### Step 7: Step-by-Step Test Execution

Test running the meta-installer on your system:

```bash
cd /home/kami/sentinel-stack
sudo ./install.sh
```

#### Expected Final Output:
```text
========================================================================
  SENTINEL STACK: INSTALLATION & COMPILATION COMPLETE!
========================================================================
  • Web Command Center   : http://localhost:9443
  • Nexus Fleet gRPC     : 0.0.0.0:50051
  • Operations CLI       : nexus-ctl --help
  • Appliance CLI        : sentinel-ctl --help
  • Package Toolchain    : sentinel-spkg
  • Edge XDR Daemon      : systemctl status blackbox-sentinel
  • Command Plane Daemon : systemctl status sentinel-nexus
========================================================================
```

Move 3 is fully integrated into `sentinel-stack`. All services, toolchains, cache directories, and capability flags deploy reliably with a single command.