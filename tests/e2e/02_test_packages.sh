#!/usr/bin/env bash
# ==============================================================================
# TEST 02: EXTENSION PACKAGES (.spkg) LIFECYCLE
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 02: SENTINEL PACKAGES (.spkg)"
cd "$WORKDIR"

log_info "1. Scaffolding new LuaJIT reflex package..."
aryo package new s7_safety_guard lua >> "$LOG_FILE" 2>&1

log_info "2. Packing and signing package..."
aryo artifact pack s7_safety_guard >> "$LOG_FILE" 2>&1
PKG_FILE=$(ls "$WORKDIR"/s7_safety_guard/*.spkg | head -n 1)
assert_file_exists "$PKG_FILE"

log_info "3. Running sandbox pre-flight assertion on package..."
aryo artifact test "$PKG_FILE" >> "$LOG_FILE" 2>&1
log_success "Package packed & verified authentic ($PKG_FILE)"

log_info "4. Publishing package to Hub (http://localhost:8000)..."
aryo publish "$PKG_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
log_success "Published to Hub"

log_info "5. Querying live Hub and pulling package..."
aryo hub search s7_safety >> "$LOG_FILE" 2>&1
sudo aryo package pull s7_safety_guard >> "$LOG_FILE" 2>&1
sudo aryo appliance install "$PKG_FILE" >> "$LOG_FILE" 2>&1

assert_file_exists "/etc/sentinel/rules.d/s7_safety_guard.lua"
log_success "Package successfully pulled and installed to /etc/sentinel/rules.d/"