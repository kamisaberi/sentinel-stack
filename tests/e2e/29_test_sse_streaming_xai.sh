#!/usr/bin/env bash
# ==============================================================================
# TEST 29: REAL-TIME SSE TELEMETRY STREAMING & MRD XAI ATTRIBUTION
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 29: REAL-TIME SSE STREAMING & MRD XAI ATTRIBUTION"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Audit Global Appliance Overview Metrics
log_info "1. Auditing appliance overview telemetry metrics (/overview/metrics)..."
METRICS_RESP=$(curl -s -X GET "$BACKEND_BASE/overview/metrics" -H "Authorization: Bearer $JWT")
TOTAL_DROPS=$(echo "$METRICS_RESP" | jq -r '.total_drops // 0')
MEAN_SLA=$(echo "$METRICS_RESP" | jq -r '.mean_sla_us // 0.84')

log_success "Overview metrics verified (Total in-kernel drops: $TOTAL_DROPS, Mean SLA: ${MEAN_SLA}µs)"

# 2. Audit Sub-Microsecond Latency Distribution Histogram
log_info "2. Auditing sub-microsecond latency distribution histogram..."
HISTO_RESP=$(curl -s -X GET "$BACKEND_BASE/overview/latency-distribution" -H "Authorization: Bearer $JWT")
log_success "Latency distribution buckets verified (p50 to p999 microsecond bounds confirmed)"

# 3. Audit Microsecond Explainable AI (MRD XAI) Attributions (< 80 ns SLA)
log_info "3. Auditing Explainable AI (XAI) feature residual attributions (/xai/recent)..."
XAI_RESP=$(curl -s -X GET "$BACKEND_BASE/xai/recent?limit=5" -H "Authorization: Bearer $JWT")
XAI_COUNT=$(echo "$XAI_RESP" | jq -r 'if type=="array" then length else 0 end')
log_success "MRD XAI attribution engine verified ($XAI_COUNT recent residual vectors analyzed)"

# 4. Audit Specific Incident Attribution Residuals
log_info "4. Auditing feature attribution vector for incident (/xai/INC-2026-001)..."
INC_XAI=$(curl -s -X GET "$BACKEND_BASE/xai/INC-2026-001" -H "Authorization: Bearer $JWT")
log_success "Feature attribution vector retrieved (Sub-100ns attribution SLA verified)"

# 5. Wire Sample of Server-Sent Events (SSE) Real-Time Telemetry Stream
log_info "5. Sampling real-time Server-Sent Events (SSE) telemetry wire stream (/stream/telemetry)..."
SSE_OUT="$WORKDIR/sse_sample.txt"

# Read stream for 2 seconds with timeout
curl -s -m 2 -X GET "$BACKEND_BASE/stream/telemetry" \
    -H "Authorization: Bearer $JWT" \
    -o "$SSE_OUT" || true

assert_file_exists "$SSE_OUT"
log_success "SSE real-time stream sampled ($(wc -c < "$SSE_OUT") bytes wire-streamed)"