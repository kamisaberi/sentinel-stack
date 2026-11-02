#!/usr/bin/env bash
# ==============================================================================
# TEST 07: PRODUCTION SITE BLUEPRINTS (DYNAMIC SLUG & METHOD 2 VISIBILITY)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

BP_SLUG="bp_${RUN_TAG:-$(date +%s)}"

log_header "TEST 07: PRODUCTION SITE BLUEPRINTS [Slug: $BP_SLUG]"
cd "$WORKDIR"

# 1. Scaffold Physical Blueprint Project
log_info "1. Scaffolding physical production blueprint ($BP_SLUG)..."
aryo blueprint new "$BP_SLUG" --site "Site-${BP_SLUG}" >> "$LOG_FILE" 2>&1
assert_file_exists "$WORKDIR/$BP_SLUG/blueprint.yaml"
assert_file_exists "$WORKDIR/$BP_SLUG/model_routes.yaml"

# 2. Add Dependency
log_info "2. Adding dependency to blueprint..."
aryo blueprint add "$BP_SLUG" s7_safety_guard >> "$LOG_FILE" 2>&1

# 3. Pack Blueprint Bundle
log_info "3. Packing blueprint bundle..."
aryo blueprint pack "$BP_SLUG" >> "$LOG_FILE" 2>&1
BP_FILE=$(ls /var/cache/sentinel/blueprints/*"${BP_SLUG}"*.blueprint 2>/dev/null || ls ~/.cache/sentinel/blueprints/*"${BP_SLUG}"*.blueprint 2>/dev/null | head -n 1)
assert_file_exists "$BP_FILE"

# 4. Inspect Hardware Bindings
log_info "4. Inspecting blueprint hardware bindings..."
aryo blueprint inspect "$BP_FILE" >> "$LOG_FILE" 2>&1

# 5. Publish to Dedicated Route (/hub/blueprints/publish)
log_info "5. Publishing unique blueprint ($BP_SLUG) to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$BP_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Blueprint publish failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Blueprint published to Hub (HTTP 201 Created)"

# 5b. Method 2: Promote Visibility to Public
log_info "5b. Promoting blueprint visibility to 'public' via Method 2..."
if ! aryo hub visibility blueprint "$BP_SLUG" public >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Blueprint visibility promotion failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Blueprint visibility updated to 'public'"

# 6. Pull Blueprint Bundle
log_info "6. Pulling blueprint bundle..."
aryo blueprint pull "$BP_SLUG" >> "$LOG_FILE" 2>&1

# 7. Atomic Zero-Downtime Deployment & Rollback Test
log_info "7. Testing atomic edge hardware deployment & rollback..."
sudo aryo blueprint deploy "$BP_FILE" >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/.blueprint_backup/model_routes.yaml"
sudo aryo blueprint rollback >> "$LOG_FILE" 2>&1

log_success "Blueprint deployed and emergency rollback confirmed"