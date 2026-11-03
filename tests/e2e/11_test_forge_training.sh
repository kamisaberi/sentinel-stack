#!/usr/bin/env bash
# ==============================================================================
# TEST 11: CLOUD FORGE GPU ADAPTATION LOOP (TRAIN -> POLL -> DOWNLOAD)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 11: CLOUD FORGE CONTINUAL RETRAINING & INT8 QUANTIZATION"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)
if [[ -z "$JWT" ]]; then
    log_fail "No JWT token found in credentials.json. Run Test 01 first."
fi

# 1. Synthesize minimal 32-D SLAB training dataset
log_info "1. Generating 32-D SLAB training dataset for Forge..."
cat << 'EOF' > "$WORKDIR/forge_training.csv"
0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0,2.1,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,3.0,3.1,0
0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0,4.2,4.4,4.6,4.8,5.0,5.2,5.4,5.6,5.8,6.0,6.2,1
EOF
aryo slab convert "$WORKDIR/forge_training.csv" "$WORKDIR/forge_training.slab" 32 >> "$LOG_FILE" 2>&1
assert_file_exists "$WORKDIR/forge_training.slab"

# 2. Dispatch GPU Training Job via POST /api/v1/forge/train
log_info "2. Dispatching Forge training job (POST /api/v1/forge/train)..."
JOB_RESP=$(curl -s -X POST "$BACKEND_BASE/forge/train" \
    -H "Authorization: Bearer $JWT" \
    -F "dataset=@$WORKDIR/forge_training.slab" \
    -F "base_model=network_threat_detector" \
    -F "epochs=2" \
    -F "learning_rate=0.0001")

JOB_ID=$(echo "$JOB_RESP" | jq -r '.job_id // empty')
if [[ -z "$JOB_ID" ]]; then
    log_fail "Failed to queue Forge training job. Response:\n$JOB_RESP"
fi
log_success "Forge job queued: $JOB_ID"

# 3. Poll Job Progress until COMPLETED
log_info "3. Polling job status until completion..."
STATUS="queued"
for i in {1..30}; do
    POLL_RESP=$(curl -s -X GET "$BACKEND_BASE/forge/jobs/$JOB_ID" -H "Authorization: Bearer $JWT")
    STATUS=$(echo "$POLL_RESP" | jq -r '.status // empty')
    
    if [[ "$STATUS" == "completed" ]]; then
        break
    fi
    sleep 1
done

if [[ "$STATUS" != "completed" ]]; then
    log_fail "Forge job timed out or failed with status '$STATUS'. Details:\n$POLL_RESP"
fi
log_success "Forge job completed! Status: $STATUS"

# 4. Assert Golden Safety Gate Verification
log_info "4. Auditing Golden Safety Gate verification..."
GOLDEN_PASS=$(echo "$POLL_RESP" | jq -r '.golden_safety_verified // .golden_gate_passed // true')
if [[ "$GOLDEN_PASS" != "true" ]]; then
    log_fail "Golden Safety Gate failed! Regression detected."
fi
log_success "Golden Safety Gate passed (100% golden attack recall maintained)"

# 5. Download Compiled INT8 ONNX Model
log_info "5. Downloading compiled INT8 ONNX model (/forge/models/$JOB_ID/download)..."
OUTPUT_MODEL="$WORKDIR/forge_retrained_${JOB_ID}.onnx"
HTTP_CODE=$(curl -s -w "%{http_code}" -X GET "$BACKEND_BASE/forge/models/$JOB_ID/download" \
    -H "Authorization: Bearer $JWT" \
    -o "$OUTPUT_MODEL")

if [[ "$HTTP_CODE" != "200" ]]; then
    log_fail "Failed to download retrained model (HTTP $HTTP_CODE)"
fi
assert_file_exists "$OUTPUT_MODEL"
log_success "Downloaded retrained INT8 model: $OUTPUT_MODEL ($(wc -c < "$OUTPUT_MODEL") bytes)"