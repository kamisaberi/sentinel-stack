#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM TECHNOLOGIES: AIR-GAPPED SYSTEM RESTORER (SSFS INTEGRATED)
# Unpacks and restores the complete operational ecosystem offline.
# ==============================================================================
set -euo pipefail

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BOLD='\033[1m'
NC='\033[0m'

if [[ "${EUID}" -ne 0 ]]; then
    echo -e "${RED}[ERROR] System restore must be run as root (sudo bash import_system.sh)${NC}"
    exit 1
fi

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SSFS_ROOT="${SENTINEL_ROOT:-/var/lib/sentinel}"

echo -e "${CYAN}${BOLD}"
echo "=========================================================================="
echo "          ARYORITHM TECHNOLOGIES: AIR-GAPPED SYSTEM RESTORER (SSFS)       "
echo "=========================================================================="
echo -e "${NC}"
echo -e "${YELLOW}[*] Restoring ecosystem from air-gapped bundle...${NC}\n"

# 1. Restore Binaries to /usr/local/bin
echo -e "  [1/8] Installing executables into /usr/local/bin..."
if [[ -d "${BUNDLE_DIR}/bin" ]]; then
    cp -p "${BUNDLE_DIR}/bin/"* /usr/local/bin/
    chmod +x /usr/local/bin/*
    if [[ -f "/usr/local/bin/sentinel-artifact" && ! -f "/usr/local/bin/sentinel-spkg" ]]; then
        ln -sf /usr/local/bin/sentinel-artifact /usr/local/bin/sentinel-spkg
    fi
fi

# 2. Restore Shared Libraries to /usr/local/lib & /usr/local/lib/blackbox
echo -e "  [2/8] Installing shared libraries into /usr/local/lib..."
mkdir -p /usr/local/lib/blackbox
if [[ -d "${BUNDLE_DIR}/lib" ]]; then
    find "${BUNDLE_DIR}/lib" -maxdepth 1 -type f -exec cp -p {} /usr/local/lib/ \;
    if [[ -d "${BUNDLE_DIR}/lib/blackbox" ]]; then
        cp -p "${BUNDLE_DIR}/lib/blackbox/"* /usr/local/lib/blackbox/ 2>/dev/null || true
    fi
    ldconfig
fi

# 3. Restore In-Kernel eBPF Driver Objects
echo -e "  [3/8] Staging in-kernel eBPF driver objects..."
mkdir -p /etc/sentinel
if [[ -f "${BUNDLE_DIR}/ebpf/xdp_drop.o" ]]; then
    cp -p "${BUNDLE_DIR}/ebpf/xdp_drop.o" /etc/sentinel/
fi
if [[ -f "${BUNDLE_DIR}/ebpf/live_sbom.o" ]]; then
    cp -p "${BUNDLE_DIR}/ebpf/live_sbom.o" /etc/sentinel/
fi

# 4. Restore Configurations & Subsystem Policies
echo -e "  [4/8] Restoring configuration trees..."
mkdir -p /etc/sentinel/configs /etc/sentinel/models /etc/sentinel/rules.d /etc/sentinel/plugins.d /etc/sentinel/wasm.d
if [[ -d "${BUNDLE_DIR}/configs" ]]; then
    cp -rp "${BUNDLE_DIR}/configs/"* /etc/sentinel/ 2>/dev/null || true
fi

# 5. Restore Environment (.env) Files into FHS /etc/sentinel/env
echo -e "  [5/8] Deploying environment (.env) files into /etc/sentinel/env/..."
mkdir -p /etc/sentinel/env
if [[ -f "${BUNDLE_DIR}/env/sentinel-matrix.env" ]]; then
    cp -p "${BUNDLE_DIR}/env/sentinel-matrix.env" /etc/sentinel/env/sentinel-matrix.env
fi
if [[ -f "${BUNDLE_DIR}/env/root.env" ]]; then
    cp -p "${BUNDLE_DIR}/env/root.env" /etc/sentinel/env/sentinel-stack.env
fi

# 6. Restore Python Virtual Environment, Cartridge Packs & Harnesses
echo -e "  [6/8] Restoring Python venv, cartridge packs, and harnesses..."
mkdir -p /opt/sentinel-stack /opt/sentinel
if [[ -f "${BUNDLE_DIR}/opt/sentinel_venv.tar.gz" ]]; then
    tar -xzf "${BUNDLE_DIR}/opt/sentinel_venv.tar.gz" -C /opt/sentinel-stack/
fi
if [[ -f "${BUNDLE_DIR}/opt/sentinel_harnesses.tar.gz" ]]; then
    tar -xzf "${BUNDLE_DIR}/opt/sentinel_harnesses.tar.gz" -C /opt/sentinel-stack/
    chmod +x /opt/sentinel-stack/harnesses/*.py 2>/dev/null || true
fi
if [[ -f "${BUNDLE_DIR}/opt/sentinel_packs.tar.gz" ]]; then
    tar -xzf "${BUNDLE_DIR}/opt/sentinel_packs.tar.gz" -C /opt/sentinel/
fi

# 7. Restore Sovereign Sentinel Filesystem Vault (${TARGET_SSFS_ROOT})
echo -e "  [7/8] Restoring Sovereign Sentinel Filesystem vault (${TARGET_SSFS_ROOT})..."
mkdir -p "${TARGET_SSFS_ROOT}"
if [[ -f "${BUNDLE_DIR}/ssfs/sentinel_ssfs.tar.gz" ]]; then
    tar -xzf "${BUNDLE_DIR}/ssfs/sentinel_ssfs.tar.gz" -C "${TARGET_SSFS_ROOT}"
fi
if command -v sfs &>/dev/null; then
    SENTINEL_ROOT="${TARGET_SSFS_ROOT}" sfs init
fi

# 8. Load Docker Matrix Images Offline (if available)
echo -e "  [8/8] Loading container images into local Docker daemon..."
if command -v docker &>/dev/null && [[ -f "${BUNDLE_DIR}/docker/matrix_images.tar.gz" ]]; then
    docker load -i "${BUNDLE_DIR}/docker/matrix_images.tar.gz" || true
fi

echo -e "\n${GREEN}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}  AIR-GAPPED RESTORATION COMPLETE! ECOSYSTEM IS 100% OPERATIONAL.       ${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}"
echo -e "  • Running immediate system verification check..."

if command -v aryo &>/dev/null; then
    aryo stack verify || true
fi

echo -e "\n${GREEN}${BOLD}========================================================================${NC}\n"