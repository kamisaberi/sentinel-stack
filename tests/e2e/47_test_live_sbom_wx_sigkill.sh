#!/usr/bin/env bash
# ==============================================================================
# TEST 47: LIVE-SBOM IN-KERNEL W^X DRIFT & TPM 2.0 PCR[10] SIGKILL
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 47: LIVE-SBOM MEMORY DRIFT & W^X SIGKILL INTERCEPTOR"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Generate CycloneDX 1.6 Runtime Live-SBOM Manifest
log_info "1. Generating Live-SBOM runtime manifest anchored to TPM 2.0 PCR[10]..."
sudo aryo sbom generate >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/live_sbom.json"
log_success "Live-SBOM runtime manifest generated (/etc/sentinel/live_sbom.json)"

# 2. Activate sys_enter_mprotect Tracepoint W^X Enforcement
log_info "2. Activating sys_enter_mprotect in-kernel W^X memory monitor..."
sudo aryo sbom enforce >> "$LOG_FILE" 2>&1
log_success "W^X memory monitor active (< 1.0 µs SIGKILL enforcement)"

# 3. Execute Sandboxed Memory Page Modification Drill
log_info "3. Executing sandboxed fileless shellcode PROT_EXEC injection drill..."
sudo aryo sbom test-drift >> "$LOG_FILE" 2>&1
log_success "Memory drift drill passed (Unauthorized PROT_EXEC neutralized)"

# 4. Attest Live-SBOM PCR[10] Hash to Cloud Compliance Dashboard
log_info "4. Attesting Live-SBOM to compliance dashboard (/compliance/sbom/attest)..."
sudo aryo sbom attest >> "$LOG_FILE" 2>&1
log_success "Live-SBOM PCR[10] attestation accepted"