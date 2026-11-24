#!/usr/bin/env bash
# File: /home/kami/sentinel-stack/scenarios/lib/scenario_provision_lib.sh
# ==============================================================================
# ARYORITHM SENTINEL-STACK: SHARED REAL-WORLD MULTI-NODE SCENARIO PROVISIONER
# Tier 4 Orchestrator fully integrated with Tier 0 Sovereign Sentinel Filesystem
# ==============================================================================

set -euo pipefail

STACK_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve authoritative SSFS root anchor
if [[ -n "${SENTINEL_ROOT:-}" ]]; then
    SENTINEL_HOME_DIR="$(readlink -f "${SENTINEL_ROOT}")"
elif [[ "${EUID}" -eq 0 ]]; then
    SENTINEL_HOME_DIR="/var/lib/sentinel"
else
    SENTINEL_HOME_DIR="${HOME}/.sentinel"
fi

SCENARIOS_CATALOG="${SENTINEL_HOME_DIR}/scenarios/catalog"
DOWNLOAD_CACHE_DIR="${SENTINEL_HOME_DIR}/artifacts/downloads"

# Dynamically locate scenario_engine.py without hardcoded paths
locate_scenario_engine() {
    local candidates=(
        "${MATRIX_ROOT:-}/tools/scenario_engine.py"
        "${HOME}/sentinel-matrix/tools/scenario_engine.py"
        "/opt/sentinel-matrix/tools/scenario_engine.py"
        "/usr/local/bin/scenario_engine.py"
    )
    for c in "${candidates[@]}"; do
        if [[ -f "${c}" ]]; then
            echo "${c}"
            return 0
        fi
    done
    echo ""
}

resolve_python_bin() {
    if [[ -x "/opt/sentinel-stack/venv/bin/python3" ]]; then
        echo "/opt/sentinel-stack/venv/bin/python3"
    else
        echo "python3"
    fi
}

cartridge_lib_and_plugin() {
    case "$1" in
        ics-guard)    echo "libics_guard.so:ics_guard_dissector_plugin.so:18_cps_sec" ;;
        ccsds-guard)  echo "libccsds_guard.so:ccsds_guard_dissector_plugin.so:18_cps_sec" ;;
        net-guard)    echo "libnet_guard.so:net_guard_dissector_plugin.so:03_ndr" ;;
        motion-guard) echo "libmotion_guard.so:motion_guard_dissector_plugin.so:18_cps_sec" ;;
        vision-guard) echo "libvision_guard.so:vision_guard_dissector_plugin.so:17_iot_sec" ;;
        *)            echo "libics_guard.so:ics_guard_dissector_plugin.so:18_cps_sec" ;;
    esac
}

provision_and_stage_scenario() {
    local DO_UP="false"
    local DO_DOWN="false"
    for arg in "$@"; do
        case "$arg" in
            --up)   DO_UP="true" ;;
            --down) DO_DOWN="true" ;;
        esac
    done

    local SCENARIO_DIR="${SCENARIOS_CATALOG}/${SCENARIO_SLUG}"
    local ENGINE_BIN
    ENGINE_BIN="$(locate_scenario_engine)"

    if [[ "$DO_DOWN" == "true" ]]; then
        if [[ -n "${ENGINE_BIN}" ]]; then
            python3 "${ENGINE_BIN}" down --name "${SCENARIO_SLUG}"
        else
            echo "[-] Error: Unable to locate scenario_engine.py for teardown." >&2
            return 1
        fi
        return 0
    fi

    echo -e "\033[1;36m================================================================================\033[0m"
    echo -e "\033[1;37m  PROVISIONING REAL-WORLD SCENARIO: ${SCENARIO_TITLE}\033[0m"
    echo -e "\033[1;36m================================================================================\033[0m"
    echo -e "  Slug / Cartridge : ${SCENARIO_SLUG} [${CARTRIDGE}]"
    echo -e "  SSFS Catalog Path: ${SCENARIO_DIR}"
    echo -e "  Subnet           : ${SUBNET_PREFIX}.0/24\n"

    mkdir -p "${SCENARIO_DIR}"/{configs/nodes,configs/lab_plugins,models,pcaps}

    # 1. Fetch assets into SSFS CAS & link into scenario workspace
    local PY_BIN
    PY_BIN="$(resolve_python_bin)"
    local FETCH_ARGS=(
        "--scenario-dir" "${SCENARIO_DIR}"
        "--cache-dir" "${DOWNLOAD_CACHE_DIR}"
        "--domain-ae" "${DOMAIN_AE_MODEL:-domain_calibrated_ae.onnx}"
        "--ae-dim" "${DOMAIN_AE_DIM:-32}"
        "--proto-port" "${PRIMARY_PROTO_PORT:-502}"
        "--ethertype" "${PRIMARY_ETHERTYPE:-0x0800}"
    )
    for m in "${ONNX_SOURCES[@]}"; do
        [[ -n "$m" ]] && FETCH_ARGS+=("--onnx" "$m")
    done
    for p in "${PCAP_SOURCES[@]}"; do
        [[ -n "$p" ]] && FETCH_ARGS+=("--pcap" "$p")
    done

    "${PY_BIN}" "${STACK_LIB_DIR}/fetch_scenario_assets.py" "${FETCH_ARGS[@]}"

    # Copy base attack matrix catalog if available
    local SENSOR_MATRIX="${SENTINEL_HOME_DIR}/config/sensor_attack_matrix.json"
    if [[ -f "${SENSOR_MATRIX}" ]]; then
        cp -u "${SENSOR_MATRIX}" "${SCENARIO_DIR}/configs/"
    fi

    # 2. Generate manifest.json
    cat > "${SCENARIO_DIR}/manifest.json" <<EOF
{
  "name": "${SCENARIO_SLUG}",
  "slug": "${SCENARIO_SLUG}",
  "title": "${SCENARIO_TITLE}",
  "version": "1.0.0",
  "asset_type": "scenario",
  "target_sector": "${SECTOR}",
  "category": "${CATEGORY:-CYBER_PHYSICAL}",
  "cartridge": "${CARTRIDGE}",
  "description": "${SCENARIO_DESC}",
  "compliance": ["${COMPLIANCE_STD:-IEC-62443-4-2}", "EU-NIS2"]
}
