#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'; CYAN='\033[36m'; GREEN='\033[32m'; RED='\033[31m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

SKIP_DEPS="false"
SKIP_SCENARIOS="false"
SCENARIOS_ONLY="false"

for arg in "$@"; do
    case "${arg}" in
        --skip-deps)      SKIP_DEPS="true" ;;
        --skip-scenarios) SKIP_SCENARIOS="true" ;;
        --scenarios-only) SCENARIOS_ONLY="true" ;;
        -h|--help)
            echo "Usage: sudo ./install.sh [--skip-deps] [--skip-scenarios] [--scenarios-only]"
            exit 0 ;;
    esac
done

echo -e "${CYAN}${BOLD}=== ARYORITHM SENTINEL-STACK: 5-TIER SOVEREIGN INSTALLER ===${NC}\n"

if [[ "${SCENARIOS_ONLY}" == "true" ]]; then
    bash "${SCRIPT_DIR}/scripts/05_provision_scenarios.sh"
    exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo -e "${RED}[ERROR] Full installation requires root: sudo ./install.sh${NC}"
    exit 1
fi

chmod +x "${SCRIPT_DIR}"/*.sh "${SCRIPT_DIR}"/scripts/*.sh "${SCRIPT_DIR}"/scenarios/scripts/*.sh 2>/dev/null || true

bash "${SCRIPT_DIR}/scripts/00_check_system.sh"
[[ "${SKIP_DEPS}" == "false" ]] && bash "${SCRIPT_DIR}/scripts/01_install_dependencies.sh"
bash "${SCRIPT_DIR}/scripts/02_clone_repositories.sh"
bash "${SCRIPT_DIR}/scripts/03_build_all_tiers.sh"
bash "${SCRIPT_DIR}/scripts/04_setup_systemd.sh"
[[ "${SKIP_SCENARIOS}" == "false" ]] && bash "${SCRIPT_DIR}/scripts/05_provision_scenarios.sh"
bash "${SCRIPT_DIR}/scripts/06_verify_installation.sh"

echo -e "\n${GREEN}${BOLD}[+] SENTINEL STACK INSTALLATION COMPLETE!${NC}"
echo -e "  • Tier 0 Storage : ${CYAN}sfs status${NC}"
echo -e "  • Master CLI     : ${CYAN}aryo --help${NC}"
echo -e "  • 50 Recipes     : ${CYAN}aryo scenario list-recipes${NC}"
