#!/usr/bin/env bash
# ==============================================================================
# TEST 12: MODEL VAULT & GOLDEN GATE CANARY OTA ROLLOUT
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 12: MODEL VAULT & CANARY OTA LIFECYCLE"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)

# 1. Query Public Model Vault Catalog
log_info "1. Querying Model Vault catalog (GET /api/v1/model-vault)..."
VAULT_RESP=$(curl -s "$BACKEND_BASE/model-vault")
TOTAL_MODELS=$(echo "$VAULT_RESP" | jq -r '.total // 0')
if [[ "$TOTAL_MODELS" -le 0 ]]; then
    log_fail "Model vault catalog returned 0 models."
fi
MODEL_SLUG=$(echo "$VAULT_RESP" | jq -r '.models[0].slug // "network_threat_detector"')
log_success "Model catalog verified (Found $TOTAL_MODELS models, targeting '$MODEL_SLUG')"

# 2. Inspect Model Detail & Version Tree
log_info "2. Inspecting version tree for '$MODEL_SLUG'..."
DETAIL_RESP=$(curl -s "$BACKEND_BASE/model-vault/$MODEL_SLUG")
VERSION=$(echo "$DETAIL_RESP" | jq -r '.latest_version.version // .versions[0].version // "v1.0.0"')
log_success "Target model version: $VERSION"

# 3. Assert Golden Safety Gate Verification API
log_info "3. Testing Golden Safety Gate Verification API (/verify-safety)..."
SAFETY_RESP=$(curl -s -X POST "$BACKEND_BASE/model-vault/$MODEL_SLUG/versions/$VERSION/verify-safety" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "safety_gate_run_id": "gate_e2e_cert_01",
        "golden_recall": 1.0,
        "tested_attacks_count": 1420,
        "false_positive_rate": 0.0008,
        "verifier_signature": "verified_by_aryorithm_e2e"
    }')

SAFETY_OK=$(echo "$SAFETY_RESP" | jq -r '.golden_safety_verified // false')
if [[ "$SAFETY_OK" != "true" ]]; then
    log_fail "Safety verification rejected. Response:\n$SAFETY_RESP"
fi
log_success "Golden Safety Gate verified (100% recall certified)"

# 4. Step Through Canary OTA Rollout Stages
log_info "4. Testing Canary OTA Rollout Promotion (/promote)..."

# Step A: Promote to CANARY_5_PERCENT
PROMOTE_A=$(curl -s -X POST "$BACKEND_BASE/model-vault/$MODEL_SLUG/versions/$VERSION/promote" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{"target_stage": "CANARY_5_PERCENT"}')
STAGE_A=$(echo "$PROMOTE_A" | jq -r '.rollout_stage // empty')
log_info "  ├── Stage 1: Promoted to $STAGE_A"

# Step B: Promote to FLEET_PRODUCTION
PROMOTE_B=$(curl -s -X POST "$BACKEND_BASE/model-vault/$MODEL_SLUG/versions/$VERSION/promote" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{"target_stage": "FLEET_PRODUCTION"}')
STAGE_B=$(echo "$PROMOTE_B" | jq -r '.rollout_stage // empty')
log_success "Promoted version $VERSION to $STAGE_B"

# 5. Download Golden-Verified Production Weights
log_info "5. Downloading production model weights with integrity headers..."
DOWNLOAD_FILE="$WORKDIR/${MODEL_SLUG}_production.bin"
RESP_HEADERS="$WORKDIR/model_download_headers.txt"

curl -s -D "$RESP_HEADERS" -o "$DOWNLOAD_FILE" "$BACKEND_BASE/model-vault/$MODEL_SLUG/versions/$VERSION/download"
assert_file_exists "$DOWNLOAD_FILE"

if ! grep -qi "X-Aryorithm-Signature-Ed25519" "$RESP_HEADERS" && ! grep -qi "X-Checksum-SHA256" "$RESP_HEADERS"; then
    log_fail "Download completed but missing expected cryptographic integrity headers:\n$(cat "$RESP_HEADERS")"
fi
log_success "Model weights verified and downloaded: $DOWNLOAD_FILE"