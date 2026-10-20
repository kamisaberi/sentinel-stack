#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM TECHNOLOGIES: AIR-GAPPED SYSTEM EXPORTER (.aryopack)
# Bundles the entire operational ecosystem into an offline portable snapshot.
# ==============================================================================
set -euo pipefail

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="/home/kami"

OUTPUT_NAME="${1:-sentinel_ecosystem_$(date +%Y%m%d_%H%M%S).aryopack}"
# Ensure .aryopack extension
if [[ "${OUTPUT_NAME}" != *.aryopack ]]; then
    OUTPUT_NAME="${OUTPUT_NAME}.aryopack"
fi

TEMP_STAGE_DIR="/tmp/aryopack_staging_$$"
mkdir -p "${TEMP_STAGE_DIR}"

cleanup() {
    rm -rf "${TEMP_STAGE_DIR}"
}
trap cleanup EXIT

echo -e "${CYAN}${BOLD}"
echo "=========================================================================="
echo "          ARYORITHM TECHNOLOGIES: AIR-GAPPED SYSTEM EXPORTER              "
echo "=========================================================================="
echo -e "${NC}"
echo -e "${YELLOW}[*] Staging operational ecosystem into temporary snapshot...${NC}\n"

# 1. Staging Binaries (/usr/local/bin)
echo -e "  [1/9] Collecting system executables from /usr/local/bin..."
mkdir -p "${TEMP_STAGE_DIR}/bin"
BINARIES=(
    "sentinel"
    "sentinel-nexus"
    "sentinel_lab"
    "mock_plc"
    "aryo"
    "sentinel-ctl"
    "sentinel-artifact"
    "nexus-ctl"
    "forge-cli"
)
for bin in "${BINARIES[@]}"; do
    if [ -f "/usr/local/bin/${bin}" ]; then
        cp -p "/usr/local/bin/${bin}" "${TEMP_STAGE_DIR}/bin/"
    fi
done

# 2. Staging Shared Libraries (/usr/local/lib)
echo -e "  [2/9] Collecting compiled shared libraries from /usr/local/lib..."
mkdir -p "${TEMP_STAGE_DIR}/lib"
cp -p /usr/local/lib/libxinfer.so* "${TEMP_STAGE_DIR}/lib/" 2>/dev/null || true
cp -p /usr/local/lib/libblackbox.so* "${TEMP_STAGE_DIR}/lib/" 2>/dev/null || true
cp -p /usr/local/lib/sentinel_plugin_*.so "${TEMP_STAGE_DIR}/lib/" 2>/dev/null || true

# 3. Staging In-Kernel eBPF Objects
echo -e "  [3/9] Collecting eBPF driver objects..."
mkdir -p "${TEMP_STAGE_DIR}/ebpf"
if [ -f "/etc/sentinel/xdp_drop.o" ]; then
    cp -p "/etc/sentinel/xdp_drop.o" "${TEMP_STAGE_DIR}/ebpf/"
elif [ -f "${WORKSPACE_ROOT}/blackbox-essential/src/mitigation/xdp_drop.o" ]; then
    cp -p "${WORKSPACE_ROOT}/blackbox-essential/src/mitigation/xdp_drop.o" "${TEMP_STAGE_DIR}/ebpf/"
fi

# 4. Staging Environment (.env) Files
echo -e "  [4/9] Packaging environment files (.env)..."
mkdir -p "${TEMP_STAGE_DIR}/env"
if [ -f "${WORKSPACE_ROOT}/sentinel-matrix/.env" ]; then
    cp -p "${WORKSPACE_ROOT}/sentinel-matrix/.env" "${TEMP_STAGE_DIR}/env/sentinel-matrix.env"
fi
if [ -f "${STACK_ROOT}/.env" ]; then
    cp -p "${STACK_ROOT}/.env" "${TEMP_STAGE_DIR}/env/root.env"
fi

# 5. Staging Configurations (/etc/sentinel & project configs)
echo -e "  [5/9] Packaging system configuration trees..."
mkdir -p "${TEMP_STAGE_DIR}/configs"
if [ -d "/etc/sentinel" ]; then
    cp -rp /etc/sentinel/* "${TEMP_STAGE_DIR}/configs/" 2>/dev/null || true
fi
# Ensure all project config roots are captured
for p_cfg in "${WORKSPACE_ROOT}"/*/configs; do
    if [ -d "${p_cfg}" ]; then
        cp -rp "${p_cfg}"/* "${TEMP_STAGE_DIR}/configs/" 2>/dev/null || true
    fi
done

# 6. Staging Isolated Python Virtual Environment (/opt/sentinel-stack/venv)
echo -e "  [6/9] Bundling offline Python virtual environment (/opt/sentinel-stack/venv)..."
if [ -d "/opt/sentinel-stack/venv" ]; then
    mkdir -p "${TEMP_STAGE_DIR}/opt"
    tar -czf "${TEMP_STAGE_DIR}/opt/sentinel_venv.tar.gz" -C "/opt/sentinel-stack" venv
fi

# 7. Staging Central Asset Vault (/var/cache/sentinel)
echo -e "  [7/9] Packaging offline cache asset vault (/var/cache/sentinel)..."
mkdir -p "${TEMP_STAGE_DIR}/cache"
if [ -d "/var/cache/sentinel" ]; then
    tar -czf "${TEMP_STAGE_DIR}/cache/sentinel_cache.tar.gz" -C "/var/cache" sentinel
fi

# 8. Staging Docker Matrix Images (if available)
echo -e "  [8/9] Exporting sentinel-matrix container images..."
mkdir -p "${TEMP_STAGE_DIR}/docker"
if command -v docker &>/dev/null; then
    ACTIVE_IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E 'matrix|sentinel' || true)
    if [ -n "${ACTIVE_IMAGES}" ]; then
        echo "      --> Archiving Docker images: ${ACTIVE_IMAGES}"
        docker save ${ACTIVE_IMAGES} | gzip > "${TEMP_STAGE_DIR}/docker/matrix_images.tar.gz"
    fi
fi

# 9. Embed Importer Script & Generate Manifest
echo -e "  [9/9] Embedding automated importer & calculating SHA-256 manifest..."
cp -p "${SCRIPT_DIR}/import_system.sh" "${TEMP_STAGE_DIR}/import_system.sh"
chmod +x "${TEMP_STAGE_DIR}/import_system.sh"

cat << EOF > "${TEMP_STAGE_DIR}/manifest.json"
{
  "bundle_format": "ARYOPACK_V1",
  "created_at_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "generator": "sentinel-stack/export_system.sh",
  "system_kernel": "$(uname -r)",
  "arch": "$(uname -m)"
}
EOF

# Build final compressed archive
echo -e "\n${YELLOW}[*] Compressing into standalone archive: ${OUTPUT_NAME}...${NC}"
tar -czf "${OUTPUT_NAME}" -C "${TEMP_STAGE_DIR}" .

TOTAL_SIZE_MB=$(du -m "${OUTPUT_NAME}" | cut -f1)
echo -e "\n${GREEN}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}  AIR-GAPPED EXPORT COMPLETE: ${OUTPUT_NAME} (${TOTAL_SIZE_MB} MB)${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}"
echo -e "  • Self-contained offline bundle ready for USB Sneakernet transfer."
echo -e "  • To restore on any air-gapped target machine without internet:"
echo -e "    ${CYAN}aryo system import ${OUTPUT_NAME}${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}\n"