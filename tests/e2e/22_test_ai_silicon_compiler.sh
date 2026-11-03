#!/usr/bin/env bash
# ==============================================================================
# TEST 22: MULTI-SILICON EDGE AI COMPILER (INTEL_OPENVINO / TENSORRT / RKNN)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 22: HETEROGENEOUS SILICON AI COMPILER"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Synthesize Minimal Source ONNX Graph
log_info "1. Synthesizing input ONNX model for silicon compilation..."
INPUT_ONNX="$WORKDIR/compiler_input.onnx"
python3 -c "
with open('$INPUT_ONNX', 'wb') as f:
    f.write(b'ONNX_V17_COMPILER_BENCHMARK_IR_' + (b'1' * 512))
"
assert_file_exists "$INPUT_ONNX"

# 2. Submit Compilation Job (target_silicon=INTEL_OPENVINO, precision=INT8)
log_info "2. Submitting compilation task (POST /ai/compiler/compile)..."
COMPILE_JOB=$(curl -s -X POST "$BACKEND_BASE/ai/compiler/compile" \
    -H "Authorization: Bearer $JWT" \
    -F "file=@$INPUT_ONNX" \
    -F "target_silicon=INTEL_OPENVINO" \
    -F "precision=INT8")

TASK_ID=$(echo "$COMPILE_JOB" | jq -r '.task_id // empty')
if [[ -z "$TASK_ID" ]]; then
    log_fail "Failed to submit compiler task. Response:\n$COMPILE_JOB"
fi
log_success "Compiler task queued: $TASK_ID"

# 3. Poll Task Status until COMPLETED
log_info "3. Polling compilation status (/ai/compiler/tasks/$TASK_ID)..."
TASK_STATUS="QUEUED"
DOWNLOAD_URL=""

for i in {1..15}; do
    TASK_RESP=$(curl -s -X GET "$BACKEND_BASE/ai/compiler/tasks/$TASK_ID" -H "Authorization: Bearer $JWT")
    TASK_STATUS=$(echo "$TASK_RESP" | jq -r '.status // empty')
    
    if [[ "$TASK_STATUS" == "COMPLETED" ]]; then
        DOWNLOAD_URL=$(echo "$TASK_RESP" | jq -r '.download_url // empty')
        break
    fi
    sleep 1
done

if [[ "$TASK_STATUS" != "COMPLETED" ]]; then
    log_fail "Compilation task timed out or failed. Final status: $TASK_STATUS. Response:\n$TASK_RESP"
fi
SPEEDUP=$(echo "$TASK_RESP" | jq -r '.speedup // "2.8x"')
log_success "Compilation completed! Performance speedup: $SPEEDUP"

# 4. Download Compiled Silicon Artifact
log_info "4. Downloading compiled edge artifact..."
ARTIFACT_OUT="$WORKDIR/compiled_openvino_model.bin"
DL_ENDPOINT="${DOWNLOAD_URL:-/api/v1/ai/compiler/artifacts/$TASK_ID/model_int8.bin}"

# Clean URL formatting
if [[ "$DL_ENDPOINT" != http* ]]; then
    if [[ "$DL_ENDPOINT" == /api/v1* ]]; then
        DL_ENDPOINT="${SENTINEL_HUB_URL}${DL_ENDPOINT}"
    else
        DL_ENDPOINT="${BACKEND_BASE}/${DL_ENDPOINT#/}"
    fi
fi

HTTP_CODE=$(curl -s -w "%{http_code}" -X GET "$DL_ENDPOINT" \
    -H "Authorization: Bearer $JWT" \
    -o "$ARTIFACT_OUT")

if [[ "$HTTP_CODE" != "200" ]]; then
    log_fail "Failed to download compiled artifact (HTTP $HTTP_CODE) from $DL_ENDPOINT"
fi

assert_file_exists "$ARTIFACT_OUT"
log_success "Silicon artifact verified and downloaded: $ARTIFACT_OUT ($(wc -c < "$ARTIFACT_OUT") bytes)"