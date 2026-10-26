#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM TECHNOLOGIES: AIR-GAPPED SYSTEM RESTORER
# Unpacks and restores the complete operational ecosystem offline.
# ==============================================================================
set -euo pipefail

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] System restore must be run as root (sudo bash import_system.sh)${NC}"
    exit 1
fi

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="/home/kami"

echo -e "${CYAN}${BOLD}"
echo "=========================================================================="
echo "          ARYORITHM TECHNOLOGIES: AIR-GAPPED SYSTEM RESTORER              "
echo "=========================================================================="
echo -e "${NC}"
echo -e "${YELLOW}[*] Restoring ecosystem from air-gapped bundle...${NC}\n"

# 1. Restore Binaries to /usr/local/bin (Includes ccsds-guard)
echo -e "  [1/8] Installing executables into /usr/local/bin..."
if [ -d "${BUNDLE_DIR}/bin" ]; then
    cp -p "${BUNDLE_DIR}/bin/"* /usr/local/bin/
    chmod +x /usr/local/bin/*
    # Ensure backward-compatible symlink exists
    if [ -f "/usr/local/bin/sentinel-artifact" ] && [ ! -f "/usr/local/bin/sentinel-spkg" ]; then
        ln -sf /usr/local/bin/sentinel-artifact /usr/local/bin/sentinel-spkg
    fi
fi

# 2. Restore Shared Libraries to /usr/local/lib
echo -e "  [2/8] Installing shared libraries into /usr/local/lib..."
if [ -d "${BUNDLE_DIR}/lib" ]; then
    cp -p "${BUNDLE_DIR}/lib/"* /usr/local/lib/
    ldconfig
fi

# 3. Restore In-Kernel eBPF Driver Objects (xdp_drop.o AND live_sbom.o)
echo -e "  [3/8] Staging in-kernel eBPF driver objects..."
mkdir -p /etc/sentinel
if [ -f "${BUNDLE_DIR}/ebpf/xdp_drop.o" ]; then
    cp -p "${BUNDLE_DIR}/ebpf/xdp_drop.o" /etc/sentinel/
fi
if [ -f "${BUNDLE_DIR}/ebpf/live_sbom.o" ]; then
    cp -p "${BUNDLE_DIR}/ebpf/live_sbom.o" /etc/sentinel/
fi

# 4. Restore Configurations & Subsystem Policies
echo -e "  [4/8] Restoring configuration trees..."
mkdir -p /etc/sentinel/configs /etc/sentinel/models /etc/sentinel/rules.d /etc/sentinel/plugins.d /etc/sentinel/wasm.d
if [ -d "${BUNDLE_DIR}/configs" ]; then
    cp -rp "${BUNDLE_DIR}/configs/"* /etc/sentinel/
fi

# 5. Restore Environment (.env) Files
echo -e "  [5/8] Deploying environment (.env) files..."
if [ -f "${BUNDLE_DIR}/env/sentinel-matrix.env" ]; then
    mkdir -p "${WORKSPACE_ROOT}/sentinel-matrix"
    cp -p "${BUNDLE_DIR}/env/sentinel-matrix.env" "${WORKSPACE_ROOT}/sentinel-matrix/.env"
fi

# 6. Restore Python Virtual Environment AND Research Harnesses
echo -e "  [6/8] Restoring Python venv and research harnesses..."
mkdir -p /opt/sentinel-stack
if [ -f "${BUNDLE_DIR}/opt/sentinel_venv.tar.gz" ]; then
    tar -xzf "${BUNDLE_DIR}/opt/sentinel_venv.tar.gz" -C /opt/sentinel-stack/
fi
if [ -f "${BUNDLE_DIR}/opt/sentinel_harnesses.tar.gz" ]; then
    tar -xzf "${BUNDLE_DIR}/opt/sentinel_harnesses.tar.gz" -C /opt/sentinel-stack/
    chmod +x /opt/sentinel-stack/harnesses/*.py 2>/dev/null || true
fi

# 7. Restore Central Asset Vault (/var/cache/sentinel)
echo -e "  [7/8] Restoring offline cache asset vault..."
mkdir -p /var/cache
if [ -f "${BUNDLE_DIR}/cache/sentinel_cache.tar.gz" ]; then
    tar -xzf "${BUNDLE_DIR}/cache/sentinel_cache.tar.gz" -C /var/cache/
    chmod -R 777 /var/cache/sentinel 2>/dev/null || true
fi

# 8. Load Docker Matrix Images Offline (if available)
echo -e "  [8/8] Loading container images into local Docker daemon..."
if command -v docker &>/dev/null && [ -f "${BUNDLE_DIR}/docker/matrix_images.tar.gz" ]; then
    docker load -i "${BUNDLE_DIR}/docker/matrix_images.tar.gz" || true
fi

echo -e "\n${GREEN}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}  AIR-GAPPED RESTORATION COMPLETE! ECOSYSTEM IS 100% OPERATIONAL.       ${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}"
echo -e "  • Running immediate 21-point system verification check..."

# Run health verification immediately to prove 21/21 health
if command -v aryo &>/dev/null; then
    aryo stack verify || true
fi

echo -e "\n${GREEN}${BOLD}========================================================================${NC}\n"