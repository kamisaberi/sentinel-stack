#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'; CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

SKIP_DEPS="false"
SKIP_SCENARIOS="false"
SCENARIOS_ONLY="false"

print_usage() {
    cat << 'USAGE'
Usage: sudo [-E] ./install.sh [OPTIONS]

Options:
  --skip-deps       Skip Phase 1 apt-get & Python virtualenv installation
  --skip-scenarios  Skip Phase 5 provisioning of the 50 real-world scenarios
  --scenarios-only  Execute Phase 5 exclusively (safe for non-root execution)
  -h, --help        Display this help message and exit

Note: Use 'sudo -E ./install.sh' to preserve custom SENTINEL_ROOT or SENTINEL_WORKSPACE variables.
USAGE
}

for arg in "$@"; do
    case "${arg}" in
        --skip-deps)      SKIP_DEPS="true" ;;
        --skip-scenarios) SKIP_SCENARIOS="true" ;;
        --scenarios-only) SCENARIOS_ONLY="true" ;;
        -h|--help)
            print_usage
            exit 0 ;;
        *)
            echo -e "${RED}[-] Error: Unknown option '${arg}'${NC}\n" >&2
            print_usage >&2
            exit 1 ;;
    esac
done

echo -e "${CYAN}${BOLD}=== ARYORITHM SENTINEL-STACK: 5-TIER SOVEREIGN INSTALLER ===${NC}\n"

if [[ "${SCENARIOS_ONLY}" == "true" ]]; then
    bash "${SCRIPT_DIR}/scripts/05_provision_scenarios.sh"
    exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo -e "${RED}[ERROR] Full installation requires root privileges: sudo ./install.sh${NC}" >&2
    exit 1
fi

chmod +x "${SCRIPT_DIR}"/*.sh "${SCRIPT_DIR}"/scripts/*.sh "${SCRIPT_DIR}"/scenarios/scripts/*.sh 2>/dev/null || true

# Phase 0: System & Kernel BTF Validation
bash "${SCRIPT_DIR}/scripts/00_check_system.sh"

# Phase 1: Toolchains & PEP 668 Virtualenv
if [[ "${SKIP_DEPS}" == "false" ]]; then
    bash "${SCRIPT_DIR}/scripts/01_install_dependencies.sh"
else
    echo -e "${YELLOW}[*] Skipping Phase 1 (--skip-deps enabled).${NC}"
fi

# Phase 2: 14-Repository Synchronization
bash "${SCRIPT_DIR}/scripts/02_clone_repositories.sh"

# Phase 3: 5-Tier Topological DAG Compilation & Pack Staging
bash "${SCRIPT_DIR}/scripts/03_build_all_tiers.sh"

# Phase 4: Systemd Daemons & SSFS Initialization
bash "${SCRIPT_DIR}/scripts/04_setup_systemd.sh"

# Phase 5: 50 Real-World Scenario Recipes (Resilient to transient single-recipe errors)
SCENARIO_WARN="false"
if [[ "${SKIP_SCENARIOS}" == "false" ]]; then
    if ! bash "${SCRIPT_DIR}/scripts/05_provision_scenarios.sh"; then
        SCENARIO_WARN="true"
        echo -e "${YELLOW}[!] Warning: One or more scenarios encountered a transient error in Phase 5.${NC}"
        echo -e "${YELLOW}    Continuing to Phase 6 verification; retry anytime via: ./install.sh --scenarios-only${NC}"
    fi
else
    echo -e "${YELLOW}[*] Skipping Phase 5 (--skip-scenarios enabled).${NC}"
fi

# Phase 6: 30-Point Sovereign Ecosystem Verification
bash "${SCRIPT_DIR}/scripts/06_verify_installation.sh"

echo -e "\n${GREEN}${BOLD}========================================================================${NC}"
echo -e "${GREEN}${BOLD}  SENTINEL STACK: 14-REPOSITORY INSTALLATION & VERIFICATION COMPLETE!   ${NC}"
echo -e "${GREEN}${BOLD}========================================================================${NC}"
echo -e "  • Tier 0 Storage : ${CYAN}sfs status${NC}"
echo -e "  • Master CLI     : ${CYAN}aryo --help${NC}"
echo -e "  • 50 Recipes     : ${CYAN}aryo scenario list-recipes${NC}"
if [[ "${SCENARIO_WARN}" == "true" ]]; then
    echo -e "  • Notice         : ${YELLOW}Re-run './install.sh --scenarios-only' to retry failed recipes.${NC}"
fi
echo -e "${GREEN}${BOLD}========================================================================${NC}\n"
