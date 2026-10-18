#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM TECHNOLOGIES: UNIFIED UNINSTALLER & SYSTEM PURGE SCRIPT
# Reverts system modifications, stops systemd services, removes installed
# binaries, cleans shared libraries, and dismantles Docker matrix grids.
# ==============================================================================
set -euo pipefail

# Text styling
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${RED}${BOLD}"
cat << "EOF"
  ____             _   _            _     _   __   _ _           _  _ 
 / ___|  ___ _ __ | |_(_)_ __   ___| |   | | | | \ | | | ___   __| || |
 \___ \ / _ \ '_ \| __| | '_ \ / _ \ |   | | | |  \| | |/ _ \ / _` || |
  ___) |  __/ | | | |_| | | | |  __/ |   | |_| | |\  | | (_) | (_| ||_|
 |____/ \___|_| |_|\__|_|_| |_|\___|_|    \___/|_| \_|_|\___/ \__,_||_|
        Complete Ecosystem Uninstaller & System Purge Tool
EOF
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] This uninstaller must be executed as root (sudo ./uninstall.sh)${NC}"
    exit 1
fi

FORCE_YES=false
if [ "${1:-}" == "-y" ] || [ "${1:-}" == "--yes" ] || [ "${1:-}" == "-f" ] || [ "${1:-}" == "--force" ]; then
    FORCE_YES=true
fi

if [ "$FORCE_YES" = false ]; then
    echo -e "${YELLOW}[WARNING] This script will permanently remove:${NC}"
    echo "  • Systemd services (blackbox-sentinel, sentinel-nexus)"
    echo "  • Installed binaries in /usr/local/bin/ (sentinel, sentinel-ctl, sentinel-spkg, sentinel_lab, forge-cli, etc.)"
    echo "  • Shared libraries in /usr/local/lib/ (libxinfer.so, libblackbox.so)"
    echo "  • Configurations & caches in /etc/sentinel/, /var/cache/sentinel/, /opt/sentinel-stack/, /opt/sentinel-nexus/"
    echo "  • Active Docker matrix containers, volumes, and networks (10.240.0.0/24)"
    echo ""
    read -p "Are you sure you want to proceed with full system purge? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}[*] Uninstallation cancelled.${NC}"
        exit 0
    fi
fi

# ------------------------------------------------------------------------------
# PHASE 1: SYSTEMD SERVICES CLEANUP
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[PHASE 1/6] Stopping & Disabling Systemd Services...${NC}"
SERVICES=("blackbox-sentinel" "sentinel-nexus" "sentinel-agent" "sentinel-forge")
for svc in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo "  [*] Stopping systemd service: $svc..."
        systemctl stop "$svc" 2>/dev/null || true
    fi
    if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
        echo "  [*] Disabling systemd service: $svc..."
        systemctl disable "$svc" 2>/dev/null || true
    fi
    rm -f "/etc/systemd/system/${svc}.service" 2>/dev/null || true
    rm -f "/lib/systemd/system/${svc}.service" 2>/dev/null || true
done
systemctl daemon-reload 2>/dev/null || true
echo -e "${GREEN}[+] Systemd services removed.${NC}"

# ------------------------------------------------------------------------------
# PHASE 2: EBPF & XDP DRIVER DETACHMENT
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[PHASE 2/6] Detaching Active eBPF / XDP Network Drivers...${NC}"
if command -v ip &>/dev/null; then
    for iface in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}'); do
        if ip link show "$iface" 2>/dev/null | grep -q "xdp"; then
            echo "  [*] Detaching XDP filter from interface: $iface..."
            ip link set dev "$iface" xdp off 2>/dev/null || true
        fi
    done
fi
echo -e "${GREEN}[+] eBPF network hooks detached.${NC}"

# ------------------------------------------------------------------------------
# PHASE 3: DOCKER MATRIX CONTAINERS, VOLUMES & SUBNET CLEANUP
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[PHASE 3/6] Dismantling Docker Matrix Containers, Subnets & Volumes...${NC}"
if command -v docker &>/dev/null; then
    MATRIX_CONTAINERS=(
        "matrix-nexus"
        "matrix-forge"
        "matrix-edge-substation-01"
        "matrix-edge-hospital-02"
        "matrix-edge-refinery-03"
        "matrix-traffic-gen"
        "matrix-monitor"
        "matrix-adversary"
        "matrix-mock-plc"
    )
    for cnr in "${MATRIX_CONTAINERS[@]}"; do
        if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${cnr}$"; then
            echo "  [*] Removing Docker container: $cnr..."
            docker rm -f "$cnr" 2>/dev/null || true
        fi
    done

    # Remove Docker grid network
    if docker network ls --format '{{.Name}}' 2>/dev/null | grep -q "^sentinel-grid-net$"; then
        echo "  [*] Removing Docker network: sentinel-grid-net..."
        docker network rm sentinel-grid-net 2>/dev/null || true
    fi

    # Remove Docker shared volumes
    for vol in shared-models shared-datasets shared-logs; do
        if docker volume ls --format '{{.Name}}' 2>/dev/null | grep -q "^${vol}$"; then
            echo "  [*] Removing Docker volume: $vol..."
            docker volume rm "$vol" 2>/dev/null || true
        fi
    done
fi
echo -e "${GREEN}[+] Docker matrix resources dismantled.${NC}"

# ------------------------------------------------------------------------------
# PHASE 4: BINARIES & SHARED LIBRARIES PURGE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[PHASE 4/6] Removing Installed Binaries & Shared Libraries...${NC}"
BINARIES=(
    "sentinel"
    "sentinel-ctl"
    "sentinel-spkg"
    "sentinel-nexus"
    "nexus-ctl"
    "sentinel_lab"
    "mock_plc"
    "forge-cli"
    "sentinel-plugin-pack"
    "nexus-rule-broadcaster"
)
for bin in "${BINARIES[@]}"; do
    rm -f "/usr/local/bin/${bin}" 2>/dev/null || true
done

# Remove shared libraries
rm -f /usr/local/lib/libxinfer.so* 2>/dev/null || true
rm -f /usr/local/lib/libblackbox.so* 2>/dev/null || true
rm -f /usr/local/lib/sentinel_plugin_*.so 2>/dev/null || true

# Refresh dynamic linker
ldconfig 2>/dev/null || true
echo -e "${GREEN}[+] Installed system binaries and shared libraries purged.${NC}"

# ------------------------------------------------------------------------------
# PHASE 5: CONFIGURATION TREES, CACHES & VIRTUAL ENVIRONMENTS PURGE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[PHASE 5/6] Purging Configuration Trees, Caches & Virtual Environments...${NC}"
DIRS_TO_PURGE=(
    "/etc/sentinel"
    "/var/cache/sentinel"
    "/opt/sentinel-stack"
    "/opt/sentinel-nexus"
    "/var/log/sentinel"
    "/var/log/sentinel-nexus"
    "/var/log/xinfer-forge"
    "/var/lib/sentinel-nexus"
)
for dir in "${DIRS_TO_PURGE[@]}"; do
    if [ -d "$dir" ] || [ -f "$dir" ]; then
        echo "  [*] Purging directory: $dir..."
        rm -rf "$dir" 2>/dev/null || true
    fi
done
echo -e "${GREEN}[+] Configuration trees and cache directories purged.${NC}"

# ------------------------------------------------------------------------------
# PHASE 6: SYSTEM RESTORATION VERIFICATION
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[PHASE 6/6] Verifying System Restoration...${NC}"
REMAINING_BINARIES=0
for bin in "${BINARIES[@]}"; do
    if [ -f "/usr/local/bin/${bin}" ]; then
        REMAINING_BINARIES=$((REMAINING_BINARIES + 1))
    fi
done

if [ "$REMAINING_BINARIES" -eq 0 ] && [ ! -d "/etc/sentinel" ]; then
    echo -e "${GREEN}${BOLD}"
    echo "=========================================================================="
    echo "    [SUCCESS] ARYORITHM ECOSYSTEM PURGE & UNINSTALLATION COMPLETE!        "
    echo "=========================================================================="
    echo -e "${NC}"
    echo -e "  • All systemd services stopped and disabled."
    echo -e "  • All /usr/local/bin binaries and /usr/local/lib libraries removed."
    echo -e "  • All /etc/sentinel, /var/cache/sentinel, and /opt directories purged."
    echo -e "  • Docker matrix containers and networks dismantled."
    echo -e "  • Your system has been restored to a clean baseline."
    echo ""
else
    echo -e "${YELLOW}[!] Uninstallation completed with warnings. Some residual files may require manual deletion.${NC}"
fi