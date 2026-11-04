#!/usr/bin/env bash
# ==============================================================================
# TEST 52: ARTIFACT YANK & DELETION VIA 'aryo hub yank'
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

YANK_SLUG="pkg_yank_${RUN_TAG:-$(date +%s)}"

log_header "TEST 52: ARTIFACT YANK & DELETION ('aryo hub yank') [Slug: $YANK_SLUG]"
cd "$WORKDIR"

# 1. Scaffold, Pack and Publish Temporary Package
log_info "1. Scaffolding temporary package for yank test..."
aryo package new "$YANK_SLUG" lua >> "$LOG_FILE" 2>&1
aryo artifact pack "$YANK_SLUG" "$DEV_KEY" >> "$LOG_FILE" 2>&1

YANK_PKG=$(ls "$WORKDIR/$YANK_SLUG"/*.spkg | head -n 1)
assert_file_exists "$YANK_PKG"

log_info "2. Publishing package to Hub..."
aryo publish "$YANK_PKG" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
aryo hub visibility package "$YANK_SLUG" public >> "$LOG_FILE" 2>&1
log_success "Package published and set to public: $YANK_SLUG"

# 3. Execute 'aryo hub yank package <slug>'
log_info "3. Executing 'aryo hub yank package $YANK_SLUG'..."
aryo hub yank package "$YANK_SLUG" >> "$LOG_FILE" 2>&1
log_success "Yank command executed successfully"

# 4. Assert Asset Is Removed / Hidden from Download Endpoint
log_info "4. Verifying asset is no longer downloadable (expecting 404)..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BACKEND_BASE/hub/assets/package/$YANK_SLUG/download")

if [[ "$HTTP_CODE" != "404" && "$HTTP_CODE" != "410" ]]; then
    log_fail "Yanked asset is still downloadable! HTTP $HTTP_CODE"
fi
log_success "Yanked asset successfully hidden/removed from catalog (HTTP $HTTP_CODE)"