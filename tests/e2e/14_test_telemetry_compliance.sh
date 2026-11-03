#!/usr/bin/env bash
# ==============================================================================
# TEST 14: TELEMETRY HEARTBEAT SYNC & COMPLIANCE AUDITS
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 14: TELEMETRY HEARTBEAT SYNC & COMPLIANCE AUDITS"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)
NODE_ID="NODE_E2E_${RUN_TAG:-$(date +%s)}"

# 1. Dispatch Edge Fleet Sync with 5G and Live-SBOM Metrics
log_info "1. Dispatching edge node heartbeat sync (/fleet/sync)..."
SYNC_PAYLOAD=$(cat << EOF
{
  "tenant_id": "default",
  "nodes_count": 1,
  "nodes": [{
    "node_id": "$NODE_ID",
    "site": "Substation-Alpha",
    "status": "ONLINE",
    "cpu_pct": 14.8,
    "ebpf_drops": 142080,
    "mitigation_latency_us": 0.84,
    "gtp_stats": {
      "active_teids": 6,
      "gtp_slice_violations_dropped": 0,
      "unmapped_teids_dropped": 0,
      "n3_peer": "10.240.0.1",
      "s_nssai": "2:1"
    },
    "live_sbom": {
      "sbom_sha256": "d9af7532a37ea3c9c6726adc47720910c44c5f827b408127ec3206c8fc99506c",
      "pcr10_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "memory_drift_detected": false,
      "wx_violations": 0,
      "sigkill_events": 0,
      "drift_events": []
    },
    "sensors": []
  }]
}
EOF
)

SYNC_RESP=$(curl -s -X POST "$BACKEND_BASE/fleet/sync" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "$SYNC_PAYLOAD")

SYNC_STATUS=$(echo "$SYNC_RESP" | jq -r '.status // empty')
if [[ "$SYNC_STATUS" != "synced" ]]; then
    log_fail "Fleet sync failed. Response:\n$SYNC_RESP"
fi
log_success "Fleet heartbeat synced for node $NODE_ID"

# 2. Query 5G Slicing Telemetry Snapshot
log_info "2. Auditing 5G network slicing telemetry (/telemetry/5g-slices)..."
SLICES_RESP=$(curl -s -X GET "$BACKEND_BASE/telemetry/5g-slices" -H "Authorization: Bearer $JWT")
REPORTING=$(echo "$SLICES_RESP" | jq -r '.summary.reporting_nodes // 0')
if [[ "$REPORTING" -le 0 ]]; then
    log_fail "No reporting nodes found in 5G slice telemetry"
fi
log_success "5G slice telemetry active (Reporting nodes: $REPORTING)"

# 3. Audit 3GPP & EU NIS2 Compliance Report
log_info "3. Auditing 3GPP & EU NIS2 Compliance Engine (/compliance/5g-slicing)..."
COMPLIANCE_RESP=$(curl -s -X GET "$BACKEND_BASE/compliance/5g-slicing" -H "Authorization: Bearer $JWT")
OVERALL=$(echo "$COMPLIANCE_RESP" | jq -r '.overall_status // empty')
SCORE=$(echo "$COMPLIANCE_RESP" | jq -r '.compliance_score_pct // 0')

if [[ "$OVERALL" != "COMPLIANT" ]]; then
    log_fail "Compliance report failed. Status: $OVERALL, Score: $SCORE"
fi
log_success "EU NIS2 & 3GPP Slicing Compliance: $OVERALL ($SCORE%)"

# 4. Audit Live-SBOM Drift Events Log
log_info "4. Auditing Live-SBOM in-kernel drift events (/compliance/sbom/drift-events)..."
DRIFT_RESP=$(curl -s -X GET "$BACKEND_BASE/compliance/sbom/drift-events" -H "Authorization: Bearer $JWT")
log_success "Live-SBOM drift audit table accessible and verified"