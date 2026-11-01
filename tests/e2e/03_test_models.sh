#!/usr/bin/env bash
# ==============================================================================
# TEST 03: NEURAL ONNX MODELS LIFECYCLE
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 03: NEURAL MODELS (ONNX)"
cd "$WORKDIR"
mkdir -p "$WORKDIR/models"

log_info "1. Synthesizing test ONNX model weights..."
python3 -c '
# Write binary ONNX envelope header
with open("models/powergrid_anomaly_int8.onnx", "wb") as f:
    f.write(b"ONNX_V17_INT8_QDQ_SIMULATED_TENSOR_WEIGHTS_" + (b"0" * 256))
'
MODEL_FILE="$WORKDIR/models/powergrid_anomaly_int8.onnx"
assert_file_exists "$MODEL_FILE"

log_info "2. Packing ONNX model with INT8 precision manifest..."
aryo model pack "$MODEL_FILE" --precision INT8 --domain SCADA_ICS >> "$LOG_FILE" 2>&1

log_info "3. Publishing model to Hub..."
aryo publish "$MODEL_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
log_success "Model published to Hub"

log_info "4. Pulling model into local runtime..."
aryo model pull powergrid_anomaly_int8 >> "$LOG_FILE" 2>&1
aryo model list >> "$LOG_FILE" 2>&1

assert_file_exists "models/powergrid_anomaly_int8.onnx"
log_success "Model pulled and verified locally"