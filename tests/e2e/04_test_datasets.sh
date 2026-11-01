#!/usr/bin/env bash
# ==============================================================================
# TEST 04: SLAB TELEMETRY DATASETS (0x534C4142)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 04: SLAB DATASETS (0x534C4142)"
cd "$WORKDIR"

log_info "1. Generating raw 32-D SCADA telemetry CSV..."
cat << 'EOF' > "$WORKDIR/scada_telemetry.csv"
0.11,0.22,0.33,0.44,0.55,0.66,0.77,0.88,0.99,1.11,1.22,1.33,1.44,1.55,1.66,1.77,1.88,1.99,2.11,2.22,2.33,2.44,2.55,2.66,2.77,2.88,2.99,3.11,3.22,3.33,3.44,0
0.12,0.24,0.36,0.48,0.60,0.72,0.84,0.96,1.08,1.20,1.32,1.44,1.56,1.68,1.80,1.92,2.04,2.16,2.28,2.40,2.52,2.64,2.76,2.88,3.00,3.12,3.24,3.36,3.48,3.60,3.72,1
EOF

log_info "2. Converting CSV to binary wire protocol (.slab)..."
aryo slab convert "$WORKDIR/scada_telemetry.csv" "$WORKDIR/scada_telemetry.slab" 32 >> "$LOG_FILE" 2>&1
SLAB_FILE="$WORKDIR/scada_telemetry.slab"
assert_file_exists "$SLAB_FILE"

log_info "3. Verifying binary SLAB magic (0x534C4142) & tensor dimension..."
aryo slab verify "$SLAB_FILE" >> "$LOG_FILE" 2>&1

log_info "4. Publishing dataset to Hub..."
aryo publish "$SLAB_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
log_success "SLAB dataset published to Hub"

log_info "5. Pulling dataset into active runtime..."
aryo dataset pull scada_telemetry >> "$LOG_FILE" 2>&1
aryo dataset list >> "$LOG_FILE" 2>&1

log_info "6. Testing high-speed UDP streaming blast..."
aryo slab stream "$SLAB_FILE" 19999 >> "$LOG_FILE" 2>&1
log_success "SLAB dataset lifecycle & UDP streaming passed"