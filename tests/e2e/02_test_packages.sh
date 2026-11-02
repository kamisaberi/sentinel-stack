#!/usr/bin/env bash
# ==============================================================================
# TEST 02: EXTENSION PACKAGES (.spkg) REAL-WORLD LIFECYCLE (DYNAMIC SLUG)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

# Dynamic unique package name to prevent HTTP 409 Conflict
PKG_SLUG="pkg_${RUN_TAG:-$(date +%s)}"

log_header "TEST 02: SENTINEL PACKAGES (.spkg) [Slug: $PKG_SLUG]"
cd "$WORKDIR"

rm -rf "$WORKDIR/$PKG_SLUG"

log_info "1. Verifying author signing key on disk..."
assert_file_exists "$DEV_KEY"
log_success "Author key verified: $DEV_KEY"

log_info "2. Scaffolding LuaJIT reflex package ($PKG_SLUG)..."
aryo package new "$PKG_SLUG" lua >> "$LOG_FILE" 2>&1

log_info "3. Packing and signing package with enrolled developer key..."
aryo artifact pack "$PKG_SLUG" "$DEV_KEY" >> "$LOG_FILE" 2>&1

PKG_FILE=$(ls "$WORKDIR/$PKG_SLUG"/*.spkg 2>/dev/null | head -n 1)
assert_file_exists "$PKG_FILE"

log_info "4. Running sandbox pre-flight verification..."
aryo artifact test "$PKG_FILE" >> "$LOG_FILE" 2>&1
log_success "Pre-flight test passed ($PKG_FILE)"

log_info "5. Publishing unique package ($PKG_SLUG) to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$PKG_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Publish failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Package published to Hub (HTTP 201 Created)"

log_info "6. Live Hub search & verification..."
aryo hub search "$PKG_SLUG" >> "$LOG_FILE" 2>&1

log_info "7. Pulling and staging to runtime..."
sudo aryo package pull "$PKG_SLUG" >> "$LOG_FILE" 2>&1

assert_file_exists "/etc/sentinel/rules.d/${PKG_SLUG}.lua"
log_success "Package deployed to active runtime: /etc/sentinel/rules.d/${PKG_SLUG}.lua"