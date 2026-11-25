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
EOF

    # 3. Generate Lab Plugin JSON (categories & attacks)
    IFS='|' read -r ATK_SLUG ATK_ID ATK_NAME ATK_PROF ATK_ACT ATK_VAL <<< "${LAB_ATTACK_SPEC}"
    cat > "${SCENARIO_DIR}/configs/lab_plugins/${SCENARIO_SLUG}.json" <<EOF
{
  "attacks": {
    "${ATK_SLUG}": {
      "id": "${ATK_ID}",
      "name": "${ATK_NAME}",
      "multiplexer_fault": { "action": "${ATK_ACT}", "value": ${ATK_VAL} },
      "signal_profile": "${ATK_PROF}"
    }
  },
  "categories": {
    "${LAB_CAT_KEY:-industrial_cps}": {
      "plot_archetype": "${LAB_ARCHETYPE:-discrete_divergence}",
      "lab_module": "${LAB_MODULE:-fuzzer}",
      "physics_engine": "${CARTRIDGE}_engine",
      "chart_config": {
        "primary_title": "${LAB_CHART_TITLE:-Physical Telemetry Invariant}",
        "secondary_title": "${LAB_SUBTITLE:-Tier-2 ONNX Residual & Anomaly Score}",
        "unit": "${LAB_UNIT:-units}",
        "min_val": ${LAB_MIN:-0.0},
        "max_val": ${LAB_MAX:-120.0},
        "safe_low": ${LAB_SAFE_LOW:-10.0},
        "safe_high": ${LAB_SAFE_HIGH:-85.0}
      },
      "attacks": ["${ATK_SLUG}"]
    }
  }
}
EOF

    # 4. Generate scenario.yaml using pack:// URIs
    IFS=':' read -r CART_LIB CART_PLUGIN SUBSYS <<< "$(cartridge_lib_and_plugin "${CARTRIDGE}")"

    cat > "${SCENARIO_DIR}/scenario.yaml" <<EOF
version: "1.0"
scenario:
  name: "${SCENARIO_SLUG}"
  description: "${SCENARIO_DESC}"

networks:
  ${SCENARIO_SLUG}-net:
    driver: bridge
    subnet: "${SUBNET_PREFIX}.0/24"
    gateway: "${SUBNET_PREFIX}.1"
    internal: false

volumes:
  shared-datasets: { driver: local }
  shared-logs: { driver: local }
  shared-can-bus: { driver: local }

services:
  nexus:
    build: { context: ., dockerfile: docker/Dockerfile.nexus }
    container_name: matrix-nexus
    hostname: nexus.matrix.internal
    restart: unless-stopped
    privileged: true
    networks:
      ${SCENARIO_SLUG}-net: { ipv4_address: "${SUBNET_PREFIX}.10" }
    ports: ["50051:50051", "9443:9443", "9444:9444"]
    volumes:
      - ./configs:/opt/sentinel-nexus/configs:ro
      - ./models:/opt/sentinel-nexus/models
      - ./pcaps:/opt/sentinel-nexus/pcaps:ro
      - shared-datasets:/var/lib/sentinel-nexus/forge_datasets
      - shared-logs:/var/log/sentinel-nexus
      - ./shared/lib:/usr/local/lib/matrix-deps:ro
      - ./shared/bin/sentinel-nexus:/usr/local/bin/sentinel-nexus:ro
      - ./web:/opt/sentinel-nexus/web
      - pack://${CARTRIDGE}/web:/opt/sentinel-nexus/web/plugins:ro
    environment:
      - LD_LIBRARY_PATH=/usr/local/lib/matrix-deps
      - NEXUS_ENV=simulation
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9443/api/v1/fleet/nodes"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
EOF

    local IDX=1
    local FIRST_NODE_IP="${SUBNET_PREFIX}.101"
    for NODE_ROW in "${NODES_SPEC[@]}"; do
        IFS='|' read -r NID HOSTNAME BACKEND SID STYPE PORT TRANS MODEL_FILE CAT UNIT BASELINE <<< "${NODE_ROW}"
        local NODE_IP="${SUBNET_PREFIX}.$((100 + IDX))"
        local DEV_IP="${SUBNET_PREFIX}.$((140 + IDX))"
        local DEV_HOST_PORT="$((15700 + IDX))"
        local YAML_NAME="node_0${IDX}_${NID}.yaml"

        cat > "${SCENARIO_DIR}/configs/nodes/${YAML_NAME}" <<EOF
node:
  identifier: "${NID}"
  site_identifier: "${NID}"
  hardware:
    type: "DEVICE_VIRTUAL_TPM"
    primary_backend: "${BACKEND}"
    xdp_driver_mode: "SKB"

nexus:
  enabled: true
  host: "${SUBNET_PREFIX}.10"
  port: 50051
  nexus_http_port: 9443
  active_model_name: "${MODEL_FILE}"
  local_models_dir: "/etc/sentinel/models"

routes:
  - sensor_id: ${SID}
    sensor_type: ${STYPE}
    driver_mode: AF_XDP_UMEM
    match:
      port: ${PORT}
      transport: ${TRANS}
      package_id: org.aryorithm.package.${SCENARIO_SLUG}_${IDX}
      plugin_id: ${CART_PLUGIN}
      owner_subsystem: ${SUBSYS}
      execution_mode: CASCADE_SHORT_CIRCUIT
      model_id: ${MODEL_FILE}
      silicon_target: ${BACKEND}
      format: ONNX
      precision: INT8
      latency_budget_ns: 15000
      threshold_drop: 0.85
EOF

        local EXTRA_IPC=""
        local EXTRA_ENV=""
        if [[ "${TRANS}" == "shm_ring" ]]; then
            EXTRA_IPC=$'    ipc: shareable\n    shm_size: "256mb"'
            EXTRA_ENV=$'\n      - SENTINEL_SHM_RING=/sentinel_motion_ring'
        elif [[ "${TRANS}" == "can" ]]; then
            EXTRA_ENV=$'\n      - SENTINEL_CAN_UNIX_SOCK=/var/run/sentinel-bus/can.sock'
        fi

        cat >> "${SCENARIO_DIR}/scenario.yaml" <<EOF

  edge-0${IDX}:
    build: { context: ., dockerfile: docker/Dockerfile.sentinel }
    container_name: matrix-edge-0${IDX}-${SCENARIO_SLUG}
    hostname: ${HOSTNAME}
    restart: unless-stopped
    privileged: true
${EXTRA_IPC}
    cap_add: [NET_ADMIN, NET_RAW, SYS_ADMIN, BPF]
    depends_on: { nexus: { condition: service_healthy } }
    networks:
      ${SCENARIO_SLUG}-net: { ipv4_address: "${NODE_IP}" }
    volumes:
      - ./configs/nodes/${YAML_NAME}:/etc/sentinel/sentinel.yaml:ro
      - ./configs:/etc/sentinel/configs:ro
      - ./models:/etc/sentinel/models:rw
      - shared-logs:/var/log/sentinel
      - shared-can-bus:/var/run/sentinel-bus
      - ./shared/lib:/usr/local/lib/matrix-deps:ro
      - ./shared/bin/sentinel:/usr/local/bin/sentinel:ro
      - /usr/local/lib/${CART_LIB}:/usr/local/lib/${CART_LIB}:ro
      - /usr/local/lib/blackbox/${CART_PLUGIN}:/etc/sentinel/plugins.d/${CART_PLUGIN}:ro
    environment:
      - LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/matrix-deps
      - NODE_IDENTIFIER=${NID}
      - SITE_IDENTIFIER=${NID}
      - PRIMARY_BACKEND=${BACKEND}
      - NEXUS_HOST=${SUBNET_PREFIX}.10
      - NEXUS_PORT=50051${EXTRA_ENV}

  device-0${IDX}:
    image: sentinel-matrix/device-runtime:latest
    container_name: matrix-device-0${IDX}-${SCENARIO_SLUG}
    restart: unless-stopped
    networks:
      ${SCENARIO_SLUG}-net: { ipv4_address: "${DEV_IP}" }
    ports: ["${DEV_HOST_PORT}:502"]
    command: ["--archetype", "sensor", "--protocol", "modbus", "--port", "502", "--name", "${SID}"]
EOF
        IDX=$((IDX + 1))
    done

    # 5. Wire Apparatus Runtime & PCAP Container
    local FIRST_PCAP
    FIRST_PCAP="$(ls "${SCENARIO_DIR}/pcaps/"*.pcap 2>/dev/null | head -n 1 | xargs -r basename || echo "")"
    local APP_CMD_EXTRA=""
    [[ -n "${FIRST_PCAP}" ]] && APP_CMD_EXTRA="\"--nominal-pcap\", \"/app/pcaps/${FIRST_PCAP}\","

    cat >> "${SCENARIO_DIR}/scenario.yaml" <<EOF

  apparatus-01:
    image: sentinel-matrix/apparatus-runtime:latest
    container_name: matrix-apparatus-${SCENARIO_SLUG}
    restart: unless-stopped
    depends_on: { nexus: { condition: service_healthy } }
    networks:
      ${SCENARIO_SLUG}-net: { ipv4_address: "${SUBNET_PREFIX}.131" }
    ports: ["${APPARATUS_HOST_PORT:-18110}:8090"]
    volumes:
      - ./pcaps:/app/pcaps:ro
      - pack://${CARTRIDGE}/apparatus_plugins:/app/apparatus_plugins:ro
    command: ["--type", "${APPARATUS_TYPE:-synchrophasor}", "--name", "${SCENARIO_TITLE}", ${APP_CMD_EXTRA} "--target-ip", "${FIRST_NODE_IP}", "--target-port", "${PRIMARY_PROTO_PORT:-502}", "--api-port", "8090"]
EOF

    echo -e "\033[1;32m[+] Scenario '${SCENARIO_SLUG}' successfully provisioned into SSFS catalog at:\033[0m"
    echo -e "    ${SCENARIO_DIR}\n"
    echo -e "    Launch anytime with: \033[1;36maryo scenario up ${SCENARIO_SLUG}\033[0m\n"

    if [[ "$DO_UP" == "true" ]]; then
        if [[ -n "${ENGINE_BIN}" ]]; then
            python3 "${ENGINE_BIN}" load "${SCENARIO_SLUG}"
        else
            echo "[-] Error: Unable to locate scenario_engine.py for execution." >&2
            return 1
        fi
    fi
}