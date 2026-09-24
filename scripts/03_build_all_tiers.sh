#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 3] Compiling and Installing All 6 Tiers ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"

# Determine safe compilation parallelism
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
# TIER 2: blackbox-essential (libblackbox.so & xdp_filter.o)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 2: blackbox-essential (libblackbox.so & eBPF)...\033[0m"
cd "${SRC_DIR}/blackbox-essential"
if [ -f "bpf/build_bpf.sh" ]; then
    chmod +x bpf/build_bpf.sh
    ./bpf/build_bpf.sh
fi
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBLACKBOX_BUILD_TESTS=OFF
make -j"${JOBS}"
make install
ldconfig
echo "[+] Tier 2 (libblackbox.so) installed to /usr/local/lib."

# ------------------------------------------------------------------------------
# TIER 3: blackbox-sentinel (sentinel daemon)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 3: blackbox-sentinel daemon...\033[0m"
cd "${SRC_DIR}/blackbox-sentinel"

# Ensure proto directory is synchronized from nexus
if [ -d "${SRC_DIR}/sentinel-nexus/proto" ]; then
    mkdir -p proto
    cp -u "${SRC_DIR}/sentinel-nexus/proto/"*.proto proto/
fi

mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j"${JOBS}"
make install || cp sentinel /usr/local/bin/sentinel
mkdir -p /etc/sentinel /etc/sentinel/models
if [ -f "../configs/sentinel.yaml" ]; then
    cp -u ../configs/sentinel.yaml /etc/sentinel/sentinel.yaml
fi
echo "[+] Tier 3 (sentinel) installed to /usr/local/bin."

# ------------------------------------------------------------------------------
# TIER 4: xinfer-forge (Continuous Retraining Daemon)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Setting up Tier 4: xinfer-forge CLI & runtime...\033[0m"
VENV_DIR="/opt/sentinel-stack/venv"
FORGE_DIR="${SRC_DIR}/xinfer-forge"

# Install PyTorch CPU into virtual environment
"${VENV_DIR}/bin/pip" install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Create global wrapper script for forge-cli
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
# TIER 6: sentinel-nexus (Command Plane & Web Console)
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

# Deploy Web Command Center assets and persistent storage
mkdir -p /opt/sentinel-nexus/web /opt/sentinel-nexus/models /var/lib/sentinel-nexus/forge_datasets
if [ -d "../web" ]; then
    cp -r ../web/* /opt/sentinel-nexus/web/
fi
if [ -f "../configs/nexus.yaml" ]; then
    mkdir -p /opt/sentinel-nexus/configs
    cp ../configs/nexus.yaml /opt/sentinel-nexus/configs/nexus.yaml
fi

echo "[+] Tier 6 (sentinel-nexus & nexus-ctl) installed to /usr/local/bin."
echo "[+] Phase 3 compilation and installation successful."