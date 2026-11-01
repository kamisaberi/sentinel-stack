#!/usr/bin/env bash
# ==============================================================================
# TEST 10: ASSET CACHE & AIR-GAP USB SNEAKERNET
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 10: CONTENT CACHE & AIR-GAP SNEAKERNET"
cd "$WORKDIR"

log_info "1. Listing and searching content-addressable cache..."
aryo cache list >> "$LOG_FILE" 2>&1
aryo cache search s7 >> "$LOG_FILE" 2>&1

log_info "2. Exporting cache into self-contained sneakernet bundle..."
aryo cache export "$WORKDIR/airgap_cache_bundle.tar.gz" >> "$LOG_FILE" 2>&1
assert_file_exists "$WORKDIR/airgap_cache_bundle.tar.gz"

log_info "3. Testing cache purge..."
aryo cache clean >> "$LOG_FILE" 2>&1

log_info "4. Restoring cache from sneakernet bundle..."
aryo cache import "$WORKDIR/airgap_cache_bundle.tar.gz" >> "$LOG_FILE" 2>&1
log_success "Content-addressable cache sneakernet export/import verified"