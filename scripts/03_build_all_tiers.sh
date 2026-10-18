#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 3] Compiling and Installing All Tiers & Toolchains ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"

# Multi-path repository resolver function
find_repo_dir() {
    local REPO_NAME="$1"
    for candidate in \
        "${SRC_DIR}/${REPO_NAME}" \
        "${ROOT_DIR}/../${REPO_NAME}" \
        "/home/kami/${REPO_NAME}"; do
        if [ -d "${candidate}" ]; then
            echo "${candidate}"
            return 0
        fi
    done
    return 1
}

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
TARGET_DIR=$(find_repo_dir "xinfer-essential" || true)
if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    cd "${TARGET_DIR}"
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DXINFER_BUILD_EXAMPLES=OFF
    make -j"${JOBS}"
    make install
    ldconfig
    echo "[+] Tier 1 (libxinfer.so) installed to /usr/local/lib."
else
    echo -e "\033[31m[-] Error: xinfer-essential repository directory not found.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# TIER 2: blackbox-essential (libblackbox.so, eBPF CO-RE & AF_XDP)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 2: blackbox-essential (libblackbox.so & eBPF CO-RE)...\033[0m"
TARGET_DIR=$(find_repo_dir "blackbox-essential" || true)
if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    cd "${TARGET_DIR}"

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

    mkdir -p /etc/sentinel/configs
    if [ -f "${TARGET_DIR}/src/mitigation/xdp_drop.o" ]; then
        cp -u "${TARGET_DIR}/src/mitigation/xdp_drop.o" /etc/sentinel/
    fi
    if [ -f "${TARGET_DIR}/configs/af_xdp_config.json" ]; then
        cp -u "${TARGET_DIR}/configs/af_xdp_config.json" /etc/sentinel/configs/
    fi
    echo "[+] Tier 2 (libblackbox.so, AF_XDP & xdp_drop.o) installed."
else
    echo -e "\033[31m[-] Error: blackbox-essential repository directory not found.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# TIER 3: blackbox-sentinel (sentinel daemon, sentinel-ctl & sentinel-spkg)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 3: blackbox-sentinel daemon & toolchains...\033[0m"
TARGET_DIR=$(find_repo_dir "blackbox-sentinel" || true)
NEXUS_DIR=$(find_repo_dir "sentinel-nexus" || true)

if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    cd "${TARGET_DIR}"

    # Build embedded Wasm3 static library if missing
    if [ ! -f "third_party/wasm3/build/source/libm3.a" ] && [ -d "third_party/wasm3" ]; then
        echo "[*] Compiling embedded third_party/wasm3..."
        cd third_party/wasm3
        mkdir -p build && cd build
        cmake .. -DBUILD_WASI=none -DCMAKE_BUILD_TYPE=Release
        make -j"${JOBS}" m3
        cd "${TARGET_DIR}"
    fi

    # Ensure proto directory is synchronized from nexus
    if [ -n "${NEXUS_DIR}" ] && [ -d "${NEXUS_DIR}/proto" ]; then
        mkdir -p proto
        cp -u "${NEXUS_DIR}/proto/"*.proto proto/
    fi

    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j"${JOBS}"
    make install

    # Install CLI binaries to system path
    cp sentinel /usr/local/bin/sentinel 2>/dev/null || true
    if [ -f "sentinel-ctl" ]; then cp sentinel-ctl /usr/local/bin/sentinel-ctl; fi
    if [ -f "sentinel-spkg" ]; then cp sentinel-spkg /usr/local/bin/sentinel-spkg; fi

    # Deploy default configurations, sensors, and models
    mkdir -p /etc/sentinel/models /etc/sentinel/plugins.d /etc/sentinel/rules.d /etc/sentinel/configs
    if [ -f "../configs/sentinel.yaml" ]; then cp -u ../configs/sentinel.yaml /etc/sentinel/sentinel.yaml; fi
    if [ -f "../configs/model_routes.yaml" ]; then cp -u ../configs/model_routes.yaml /etc/sentinel/model_routes.yaml; fi
    if [ -f "../configs/sensors_config.yaml" ]; then cp -u ../configs/sensors_config.yaml /etc/sentinel/configs/; fi
    if [ -f "../configs/plugin_rules.yaml" ]; then cp -u ../configs/plugin_rules.yaml /etc/sentinel/configs/; fi

    echo "[+] Tier 3 (sentinel, sentinel-ctl, sentinel-spkg) installed."
else
    echo -e "\033[31m[-] Error: blackbox-sentinel repository directory not found.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# TIER 4: xinfer-forge (Continuous Retraining Daemon)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Setting up Tier 4: xinfer-forge CLI & runtime...\033[0m"
VENV_DIR="/opt/sentinel-stack/venv"
FORGE_DIR=$(find_repo_dir "xinfer-forge" || echo "/home/kami/xinfer-forge")

"${VENV_DIR}/bin/pip" install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

cat << EOF > /usr/local/bin/forge-cli
#!/usr/bin/env bash
source "${VENV_DIR}/bin/activate"
export PYTHONPATH="${FORGE_DIR}:${FORGE_DIR}/src:${FORGE_DIR}/forge:\${PYTHONPATH:-}"
"${VENV_DIR}/bin/python3" -m forge.cli "\$@"
EOF
chmod +x /usr/local/bin/forge-cli
echo "[+] Tier 4 (forge-cli) installed to /usr/local/bin."

# ------------------------------------------------------------------------------
# TIER 5: sentinel-lab (Academic Benchmark Testbed & All 14 Research Modules)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 5: sentinel-lab (14 Research Modules)...\033[0m"
TARGET_DIR=$(find_repo_dir "sentinel-lab" || true)

if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    cd "${TARGET_DIR}"

    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENVINO=ON -DBUILD_TESTS=OFF
    make -j"${JOBS}"
    make install || cp sentinel_lab /usr/local/bin/sentinel_lab

    # Install all 14 research JSON profiles to system config path
    mkdir -p /etc/sentinel/configs /var/cache/sentinel/configs /opt/sentinel-stack/harnesses
    if [ -d "${TARGET_DIR}/configs" ]; then
        cp -u "${TARGET_DIR}/configs/"*.json /etc/sentinel/configs/ 2>/dev/null || true
        cp -u "${TARGET_DIR}/configs/"*.json /var/cache/sentinel/configs/ 2>/dev/null || true
    fi

    # Install Python research harnesses to /opt/sentinel-stack/harnesses/
    if [ -d "${TARGET_DIR}/harness" ]; then
        cp -r "${TARGET_DIR}/harness/"* /opt/sentinel-stack/harnesses/
        chmod +x /opt/sentinel-stack/harnesses/*.py 2>/dev/null || true
    fi

    echo "[+] Tier 5 (sentinel_lab & 14 Research Profiles) installed to /usr/local/bin."
else
    echo -e "\033[33m[!] Warning: sentinel-lab repository directory not found. Skipping Tier 5 build.\033[0m"
fi

# ------------------------------------------------------------------------------
# TIER 6: sentinel-nexus (Command Plane & 1440px Web Console)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 6: sentinel-nexus & nexus-ctl...\033[0m"
TARGET_DIR=$(find_repo_dir "sentinel-nexus" || true)

if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    cd "${TARGET_DIR}"
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j"${JOBS}"
    make install || {
        cp sentinel-nexus /usr/local/bin/sentinel-nexus
        cp nexus-ctl /usr/local/bin/nexus-ctl
    }

    mkdir -p /opt/sentinel-nexus/web /opt/sentinel-nexus/models /var/lib/sentinel-nexus/forge_datasets
    if [ -d "../web" ]; then cp -r ../web/* /opt/sentinel-nexus/web/; fi
    if [ -f "../configs/nexus.yaml" ]; then cp ../configs/nexus.yaml /opt/sentinel-nexus/configs/nexus.yaml 2>/dev/null || true; fi
    if [ -f "../configs/nexus_server.conf" ]; then cp ../configs/nexus_server.conf /etc/sentinel/configs/ 2>/dev/null || true; fi

    echo "[+] Tier 6 (sentinel-nexus & nexus-ctl) installed to /usr/local/bin."
else
    echo -e "\033[31m[-] Error: sentinel-nexus repository directory not found.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# TIER 7: sentinel-matrix (RK4 ODE Physics Mock PLC Twin)
# ------------------------------------------------------------------------------
echo -e "\n\033[36m[*] Building Tier 7: sentinel-matrix (mock_plc RK4 ODE Twin)...\033[0m"
TARGET_DIR=$(find_repo_dir "sentinel-matrix" || true)

if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    cd "${TARGET_DIR}"
    mkdir -p shared/bin configs
    if [ -f "mock_plc.c" ] && [ -f "src/plant_ode.c" ]; then
        gcc -O3 -pthread -Iinclude mock_plc.c src/plant_ode.c -o shared/bin/mock_plc
        cp shared/bin/mock_plc /usr/local/bin/mock_plc 2>/dev/null || true
    fi
    if [ -f "configs/plc_register_map.json" ]; then
        cp configs/plc_register_map.json /etc/sentinel/configs/ 2>/dev/null || true
    fi

    echo "[+] Tier 7 (mock_plc) installed to /usr/local/bin."
else
    echo -e "\033[33m[!] Warning: sentinel-matrix directory not found. Skipping Tier 7 build.\033[0m"
fi

# ------------------------------------------------------------------------------
# SENTINEL-HUB: Pre-seed Core 8 Packages & Cache
# ------------------------------------------------------------------------------
TARGET_DIR=$(find_repo_dir "sentinel-hub" || true)
if [ -n "${TARGET_DIR}" ] && [ -d "${TARGET_DIR}" ]; then
    echo -e "\n\033[36m[*] Pre-seeding sentinel-hub packages into /var/cache/sentinel/...\033[0m"
    cd "${TARGET_DIR}"
    if [ -f "scripts/build_all_spkg.sh" ]; then
        chmod +x scripts/build_all_spkg.sh
        ./scripts/build_all_spkg.sh 2>/dev/null || true
    fi
    mkdir -p /var/cache/sentinel/packages
    if [ -d "dist" ]; then
        cp -u dist/*.spkg /var/cache/sentinel/packages/ 2>/dev/null || true
    fi
fi

echo "[+] Phase 3 compilation and installation successful across all 8 tiers."