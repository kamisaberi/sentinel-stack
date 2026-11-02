#!/usr/bin/env bash
# ==============================================================================
# TEST 03: NEURAL ONNX MODELS LIFECYCLE (DYNAMIC SLUG & METHOD 2 VISIBILITY)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

MDL_SLUG="mdl_${RUN_TAG:-$(date +%s)}"

log_header "TEST 03: NEURAL MODELS (ONNX) [Slug: $MDL_SLUG]"
cd "$WORKDIR"
mkdir -p "$WORKDIR/models"

# 1. Synthesize Unique ONNX Tensor Binary
log_info "1. Synthesizing test ONNX model weights..."
python3 -c "
with open('models/${MDL_SLUG}.onnx', 'wb') as f:
    f.write(b'ONNX_V17_INT8_QDQ_SIMULATED_TENSOR_WEIGHTS_' + (b'0' * 256))
"
MODEL_FILE="$WORKDIR/models/${MDL_SLUG}.onnx"
assert_file_exists "$MODEL_FILE"

# 2. Pack ONNX Model with INT8 Precision Manifest
log_info "2. Packing ONNX model with INT8 precision manifest..."
aryo model pack "$MODEL_FILE" --precision INT8 --domain SCADA_ICS >> "$LOG_FILE" 2>&1

# 3. Publish Model to Hub
log_info "3. Publishing unique model ($MDL_SLUG) to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$MODEL_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Model publish failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Model published to Hub (HTTP 201 Created)"

# 3b. Method 2: Promote Visibility to Public
log_info "3b. Promoting model visibility to 'public' via Method 2..."
if ! aryo hub visibility model "$MDL_SLUG" public >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Model visibility promotion failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Model visibility updated to 'public'"

# 4. Pull and Stage Model
log_info "4. Pulling model into local runtime..."
aryo model pull "$MDL_SLUG" >> "$LOG_FILE" 2>&1
aryo model list >> "$LOG_FILE" 2>&1

assert_file_exists "models/${MDL_SLUG}.onnx"
log_success "Model pulled and verified locally: models/${MDL_SLUG}.onnx"