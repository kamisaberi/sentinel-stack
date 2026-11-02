#!/usr/bin/env bash
# ==============================================================================
# TEST 02: EXTENSION PACKAGES (.spkg) REAL-WORLD LIFECYCLE
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 02: SENTINEL PACKAGES (.spkg)"
cd "$WORKDIR"

rm -rf "$WORKDIR/s7_safety_guard"

log_info "1. Verifying author signing key on disk..."
assert_file_exists "$DEV_KEY"
log_success "Author key verified: $DEV_KEY"

log_info "2. Scaffolding LuaJIT reflex package..."
aryo package new s7_safety_guard lua >> "$LOG_FILE" 2>&1

log_info "3. Packing and signing package with enrolled developer key..."
aryo artifact pack s7_safety_guard "$DEV_KEY" >> "$LOG_FILE" 2>&1

PKG_FILE=$(ls "$WORKDIR"/s7_safety_guard/*.spkg 2>/dev/null | head -n 1)
assert_file_exists "$PKG_FILE"

log_info "4. Running sandbox pre-flight verification..."
aryo artifact test "$PKG_FILE" >> "$LOG_FILE" 2>&1
log_success "Pre-flight test passed ($PKG_FILE)"

log_info "5. Publishing package to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$PKG_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Publish failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Package published to Hub (HTTP 201 Created)"

log_info "6. Live Hub search & verification..."
aryo hub search s7_safety >> "$LOG_FILE" 2>&1

log_info "7. Pulling and staging to runtime..."
sudo aryo package pull s7_safety_guard >> "$LOG_FILE" 2>&1

assert_file_exists "/etc/sentinel/rules.d/s7_safety_guard.lua"
log_success "Package deployed to active runtime: /etc/sentinel/rules.d/s7_safety_guard.lua"