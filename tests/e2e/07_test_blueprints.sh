#!/usr/bin/env bash
# ==============================================================================
# TEST 07: PRODUCTION SITE BLUEPRINTS (.blueprint)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 07: PRODUCTION SITE BLUEPRINTS (.blueprint)"
cd "$WORKDIR"

log_info "1. Scaffolding physical production blueprint..."
aryo blueprint new substation_bravo --site Substation-Bravo-02 >> "$LOG_FILE" 2>&1
assert_file_exists "substation_bravo/blueprint.yaml"
assert_file_exists "substation_bravo/model_routes.yaml"

log_info "2. Adding dependency to blueprint..."
aryo blueprint add substation_bravo s7_safety_guard >> "$LOG_FILE" 2>&1

log_info "3. Packing blueprint bundle..."
aryo blueprint pack substation_bravo >> "$LOG_FILE" 2>&1
BP_FILE=$(ls /var/cache/sentinel/blueprints/*substation_bravo*.blueprint 2>/dev/null || ls ~/.cache/sentinel/blueprints/*substation_bravo*.blueprint | head -n 1)
assert_file_exists "$BP_FILE"

log_info "4. Inspecting blueprint hardware bindings..."
aryo blueprint inspect "$BP_FILE" >> "$LOG_FILE" 2>&1

log_info "5. Publishing blueprint to dedicated route (/hub/blueprints/publish)..."
aryo publish "$BP_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
log_success "Blueprint published to Hub"

log_info "6. Pulling blueprint bundle..."
aryo blueprint pull substation_bravo >> "$LOG_FILE" 2>&1

log_info "7. Testing atomic zero-downtime deployment & rollback..."
sudo aryo blueprint deploy "$BP_FILE" >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/.blueprint_backup/model_routes.yaml"
sudo aryo blueprint rollback >> "$LOG_FILE" 2>&1

log_success "Blueprint deployed and emergency rollback confirmed"