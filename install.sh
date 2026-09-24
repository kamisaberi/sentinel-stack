#!/usr/bin/env bash
set -euo pipefail

# Text styling
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ____             _   _            _     ____  _             _    
 / ___|  ___ _ __ | |_(_)_ __   ___| |   / ___|| |_ __ _  ___| | __
 \___ \ / _ \ '_ \| __| | '_ \ / _ \ |   \___ \| __/ _` |/ __| |/ /
  ___) |  __/ | | | |_| | | | |  __/ |    ___) | || (_| | (__|   < 
 |____/ \___|_| |_|\__|_|_| |_|\___|_|   |____/ \__\__,_|\___|_|\_\
        Autonomous Cyber-Physical Defense Ecosystem Installer
EOF
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] This installer must be executed as root (sudo ./install.sh)${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Starting automated 6-tier installation pipeline...${NC}\n"

# Phase 0: System Validation
bash "${SCRIPT_DIR}/scripts/00_check_system.sh"

# Phase 1: Package Dependencies
bash "${SCRIPT_DIR}/scripts/01_install_dependencies.sh"

# Phase 2: Repository Synchronization
bash "${SCRIPT_DIR}/scripts/02_clone_repositories.sh"

# Phase 3: Topological Compilation & System Installation
bash "${SCRIPT_DIR}/scripts/03_build_all_tiers.sh"

# Phase 4: Service Deployment
bash "${SCRIPT_DIR}/scripts/04_setup_systemd.sh"

# Phase 5: Verification & Smoke Tests
bash "${SCRIPT_DIR}/scripts/05_verify_installation.sh"

echo -e "\n${GREEN}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}  SENTINEL STACK: INSTALLATION & COMPILATION COMPLETE!${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}"
echo -e "  • Web Command Center   : ${CYAN}http://localhost:9443${NC}"
echo -e "  • Nexus Fleet gRPC     : ${CYAN}0.0.0.0:50051${NC}"
echo -e "  • Operations CLI       : ${CYAN}nexus-ctl --help${NC}"
echo -e "  • Edge XDR Daemon      : ${CYAN}systemctl status blackbox-sentinel${NC}"
echo -e "  • Command Plane Daemon : ${CYAN}systemctl status sentinel-nexus${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}\n"