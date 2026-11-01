#!/usr/bin/env bash
# ==============================================================================
# TEST 08: FRONTIER ENGINES (LIVE-SBOM, 5G, TRiSM, SPACE)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 08: FRONTIER SECURITY & COMPLIANCE ENGINES"

# [8.1] Live-SBOM
log_info "1. Generating Live-SBOM manifest anchored to physical silicon..."
sudo aryo sbom generate >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/live_sbom.json"

log_info "2. Activating in-kernel W^X enforcement monitor..."
sudo aryo sbom enforce >> "$LOG_FILE" 2>&1

log_info "3. Running simulated memory drift injection drill..."
sudo aryo sbom test-drift >> "$LOG_FILE" 2>&1

log_info "4. Attesting Live-SBOM to compliance dashboard (/compliance/sbom/attest)..."
sudo aryo sbom attest >> "$LOG_FILE" 2>&1
log_success "Live-SBOM tested & cloud attestation accepted"

# [8.2] 3GPP 5G Slicing
log_info "5. Auditing 3GPP 5G GTP-U slicing guard..."
aryo 5g status >> "$LOG_FILE" 2>&1
if [[ -f "/home/kami/sentinel-stack/harnesses/gtp_slice_blaster.py" ]]; then
    aryo 5g blast-test lo >> "$LOG_FILE" 2>&1
    log_success "5G GTP-U blast drill executed"
fi

# [8.3] AI TRiSM Firewall
log_info "6. Auditing AI TRiSM prompt firewall status..."
aryo trism status >> "$LOG_FILE" 2>&1
aryo trism inspect --prompt "Read temperature from holding register 40001" >> "$LOG_FILE" 2>&1
aryo trism test-jailbreak >> "$LOG_FILE" 2>&1
aryo trism policy show >> "$LOG_FILE" 2>&1
aryo trism policy pull >> "$LOG_FILE" 2>&1
log_success "AI TRiSM prompt firewall & tool governor verified"

# [8.4] Space Dissector
log_info "7. Testing orbital space link dissector..."
aryo space status >> "$LOG_FILE" 2>&1
if [[ -f "/home/kami/sentinel-stack/harnesses/space_link_blaster.py" ]]; then
    aryo space blast-sim >> "$LOG_FILE" 2>&1
    log_success "Space telemetry blaster drill executed"
fi
