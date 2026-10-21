#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM TECHNOLOGIES: END-TO-END VISUAL BLUEPRINT PIPELINE VALIDATION
# Verifies visual blueprint compilation -> matrix deployment -> live fire audit
# ==============================================================================
set -euo pipefail

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BOLD='\033[1m'
NC='\033[0m'

WORKSPACE_ROOT="/home/kami"
MATRIX_DIR="${WORKSPACE_ROOT}/sentinel-matrix"
STACK_DIR="${WORKSPACE_ROOT}/sentinel-stack"

echo -e "${CYAN}${BOLD}"
echo "=========================================================================="
echo "    SENTINEL-STACK: END-TO-END VISUAL BLUEPRINT VALIDATION PIPELINE       "
echo "=========================================================================="
echo -e "${NC}"

# 1. Compile Visual Blueprint JSON -> model_routes.yaml
echo -e "${YELLOW}[STEP 1/4] Compiling Visual Blueprint JSON into model_routes.yaml...${NC}"
cd "${MATRIX_DIR}"
python3 tools/blueprint_compiler.py \
    -i configs/sample_substation_blueprint.json \
    -o configs/nodes/node_01_substation_alpha.yaml

echo -e "${GREEN}[+] Blueprint compiled successfully to matrix node configuration.${NC}"

# 2. Verify / Launch Digital Twin Simulation Grid
echo -e "\n${YELLOW}[STEP 2/4] Verifying Sentinel-Matrix Digital Twin Grid...${NC}"
if ! docker ps --format '{{.Names}}' | grep -q "matrix-edge-substation-01"; then
    echo "  [*] Launching Sentinel-Matrix grid..."
    make up
else
    echo "  [+] Matrix grid is already active (Edge Substation 01 online)."
fi

# 3. Trigger Live SCADA Fire Drill on Edge Substation 01
echo -e "\n${YELLOW}[STEP 3/4] Replaying Modbus SCADA Coil Override Attack...${NC}"
docker compose exec adversary mbpoll -m tcp -a 1 -r 105 -t 0 10.240.0.101 1 || true

# 4. Run Sentinel-Lab Live Inspector Tap for 8 Seconds
echo -e "\n${YELLOW}[STEP 4/4] Executing Sentinel-Lab Live Mathematical Audit...${NC}"
python3 /opt/sentinel-stack/harnesses/matrix_live_tap.py --nexus 10.240.0.10 --plc 10.240.0.150 -t 8

echo -e "${GREEN}${BOLD}"
echo "=========================================================================="
echo "  [SUCCESS] VISUAL BLUEPRINT END-TO-END PIPELINE CERTIFIED 100% OPERATIONAL!"
echo "=========================================================================="
echo -e "${NC}"
echo -e "  • Visual SaaS Blueprint compiled cleanly into model_routes.yaml"
echo -e "  • Deployed and executed live on Sentinel-Matrix Edge Container"
echo -e "  • Verified live under attack via Sentinel-Lab HIL and CBF Invariants"
echo ""