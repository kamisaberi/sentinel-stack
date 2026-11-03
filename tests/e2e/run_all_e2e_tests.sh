#!/usr/bin/env bash
# ==============================================================================
# MASTER RUNNER: Executes all 20 Real-World E2E Test Suites
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TEST_WORKDIR=$(mktemp -d /tmp/aryo_e2e_master_XXXXXX)
START_TIME=$(date +%s)

GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}================================================================================${RESET}"
echo -e "${YELLOW}       ARYORITHM MASTER E2E INTEGRATION SUITE (20 CATEGORIES)                   ${RESET}"
echo -e "${CYAN}================================================================================${RESET}"
echo -e "Target Backend Endpoint : http://localhost:8000"
echo -e "Master Workspace        : $TEST_WORKDIR\n"

SUITES=(
    "01_test_auth_tokens.sh"
    "02_test_packages.sh"
    "03_test_models.sh"
    "04_test_datasets.sh"
    "05_test_pcaps.sh"
    "06_test_scenarios.sh"
    "07_test_blueprints.sh"
    "08_test_frontier_engines.sh"
    "09_test_honeynet_vaccine.sh"
    "10_test_cache_sneakernet.sh"
    "11_test_forge_training.sh"
    "12_test_model_vault_ota.sh"
    "13_test_threat_grid_vaccines.sh"
    "14_test_telemetry_compliance.sh"
    "15_test_blueprint_compiler.sh"
    "16_test_hardware_tpm_licensing.sh"
    "17_test_plugin_supervisor_sla.sh"
    "18_test_hil_rk4_physics.sh"
    "19_test_dfir_firmware_cdr.sh"
    "20_test_system_aryopack_bundle.sh"
)

for suite in "${SUITES[@]}"; do
    bash "$SCRIPT_DIR/$suite"
done

ELAPSED=$(( $(date +%s) - START_TIME ))

rm -rf "$TEST_WORKDIR"

echo -e "\n${GREEN}================================================================================${RESET}"
echo -e "${GREEN}  ALL 20 REAL-WORLD E2E CATEGORIES COMPLETED SUCCESSFULLY in ${ELAPSED}s!       ${RESET}"
echo -e "${GREEN}================================================================================${RESET}"
echo -e "  [01] Authentication & Token Minting      : PASS"
echo -e "  [02] Extension Packages (.spkg)          : PASS"
echo -e "  [03] Neural Models (.onnx)               : PASS"
echo -e "  [04] SLAB Telemetry Datasets (0x534C4142) : PASS"
echo -e "  [05] Malware PCAP Vault                  : PASS"
echo -e "  [06] Digital Twin Scenarios (.tar.gz)    : PASS"
echo -e "  [07] Production Blueprints (.blueprint)  : PASS"
echo -e "  [08] In-Kernel, 5G, TRiSM & Space        : PASS"
echo -e "  [09] Honeynet Exploit & Vaccine Loop     : PASS"
echo -e "  [10] Cache Management & USB Sneakernet   : PASS"
echo -e "  [11] Cloud Forge GPU Adaptation Loop     : PASS"
echo -e "  [12] Model Vault & Golden Gate OTA       : PASS"
echo -e "  [13] Threat Grid & Vaccine Fleet Feed    : PASS"
echo -e "  [14] Telemetry Sync & NIS2 Compliance    : PASS"
echo -e "  [15] Visual Blueprint DAG Compiler       : PASS"
echo -e "  [16] Hardware Root & Commercial Licensing: PASS"
echo -e "  [17] 3-Tier Plugin Supervisor & SLA      : PASS"
echo -e "  [18] HIL Continuous ODE Physics (T_crit) : PASS"
echo -e "  [19] DFIR Firmware & CDR Sanitization    : PASS"
echo -e "  [20] System Portability Bundle (.aryopack): PASS"
echo -e "${GREEN}================================================================================${RESET}\n"