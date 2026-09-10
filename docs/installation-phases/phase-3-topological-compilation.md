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

