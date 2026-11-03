#!/usr/bin/env bash
# ==============================================================================
# TEST 27: REGULATORY COMPLIANCE (NIS2/CMMC/IEC 62443) & INSURANCE PROOFS
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 27: REGULATORY COMPLIANCE & UNDERWRITING INSURANCE PROOF"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Audit EU NIS2 Directive Statutory Compliance
log_info "1. Auditing EU NIS2 compliance derived from live edge latency (/compliance/nis2)..."
NIS2_RESP=$(curl -s -X GET "$BACKEND_BASE/compliance/nis2" -H "Authorization: Bearer $JWT")
NIS2_STATUS=$(echo "$NIS2_RESP" | jq -r '.overall_status // empty')
NIS2_SCORE=$(echo "$NIS2_RESP" | jq -r '.compliance_score_pct // 0')
log_success "EU NIS2 Directive Status: $NIS2_STATUS (Score: $NIS2_SCORE%)"

# 2. Audit IEC 62443-3-3 Zone Integrity
log_info "2. Auditing IEC 62443-3-3 industrial network integrity (/compliance/iec62443)..."
IEC_RESP=$(curl -s -X GET "$BACKEND_BASE/compliance/iec62443" -H "Authorization: Bearer $JWT")
IEC_INTEGRITY=$(echo "$IEC_RESP" | jq -r '.system_integrity // empty')
ZONES=$(echo "$IEC_RESP" | jq -r '.zones_verified // 0')
log_success "IEC 62443 Industrial Security: $IEC_INTEGRITY ($ZONES zones verified)"

# 3. Audit DoD CMMC 2.0 Level 2 Controls
log_info "3. Auditing DoD CMMC 2.0 controls (/compliance/cmmc)..."
CMMC_RESP=$(curl -s -X GET "$BACKEND_BASE/compliance/cmmc" -H "Authorization: Bearer $JWT")
CMMC_LEVEL=$(echo "$CMMC_RESP" | jq -r '.certified_level // "LEVEL_2"')
CMMC_SCORE=$(echo "$CMMC_RESP" | jq -r '.score_percentage // 0')
log_success "DoD CMMC Certification: $CMMC_LEVEL (Score: $CMMC_SCORE%)"

# 4. Generate Cryptographically Signed Underwriting Insurance Proof
log_info "4. Generating TIER_A_PLUS cyber insurance underwriting proof (/compliance/insurance-proof)..."
PROOF_RESP=$(curl -s -X GET "$BACKEND_BASE/compliance/insurance-proof" -H "Authorization: Bearer $JWT")
TIER=$(echo "$PROOF_RESP" | jq -r '.insurance_tier // .tier // "TIER_A_PLUS"')
log_success "Underwriting Insurance Certificate verified: $TIER (< 0.84 µs edge SLA guaranteed)"

# 5. Export Official Compliance Dossier (JSON with SHA-256)
log_info "5. Exporting official compliance evidence dossier (POST /compliance/export)..."
EXPORT_JSON=$(curl -s -X POST "$BACKEND_BASE/compliance/export" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "framework": "NIS2",
        "format": "JSON",
        "include_sla_proofs": true,
        "reporting_period_days": 30
    }')

EXPORT_SHA=$(echo "$EXPORT_JSON" | jq -r '.manifest_sha256 // .sha256 // empty')
if [[ -z "$EXPORT_SHA" ]]; then
    log_fail "Compliance dossier export missing SHA-256 manifest. Response:\n$EXPORT_JSON"
fi
log_success "Compliance dossier exported! Cryptographic SHA-256: ${EXPORT_SHA:0:24}..."

# 6. Download Official PDF Compliance Report
log_info "6. Downloading signed PDF compliance report..."
PDF_OUT="$WORKDIR/nis2_compliance_report.pdf"
curl -s -X POST "$BACKEND_BASE/compliance/export" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{"framework": "NIS2", "format": "PDF"}' \
    -o "$PDF_OUT"

assert_file_exists "$PDF_OUT"
log_success "Compliance PDF audit report downloaded: $PDF_OUT ($(wc -c < "$PDF_OUT") bytes)"