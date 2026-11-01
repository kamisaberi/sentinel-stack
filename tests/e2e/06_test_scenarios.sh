#!/usr/bin/env bash
# ==============================================================================
# TEST 06: DIGITAL TWIN SCENARIOS (.tar.gz)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 06: DIGITAL TWIN RANGE SCENARIOS"
cd "$WORKDIR"

log_info "1. Scaffolding new digital twin scenario skeleton..."
aryo scenario new water_treatment_subtier --sector WATER_TREATMENT >> "$LOG_FILE" 2>&1
assert_file_exists "water_treatment_subtier/scenario.yaml"

log_info "2. Registering dependencies in scenario manifest..."
aryo scenario add water_treatment_subtier s7_safety_guard >> "$LOG_FILE" 2>&1

log_info "3. Packing scenario into Hub-optimized bundle (~15 KB)..."
aryo scenario pack water_treatment_subtier >> "$LOG_FILE" 2>&1
SCEN_ARCHIVE=$(ls /var/cache/sentinel/scenarios/*water_treatment_subtier*.tar.gz 2>/dev/null || ls ~/.cache/sentinel/scenarios/*water_treatment_subtier*.tar.gz | head -n 1)
assert_file_exists "$SCEN_ARCHIVE"

log_info "4. Publishing scenario bundle to Hub..."
aryo publish "$SCEN_ARCHIVE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
log_success "Scenario published to Hub"

log_info "5. Pulling scenario and staging to sentinel-matrix..."
aryo scenario pull water_treatment_subtier >> "$LOG_FILE" 2>&1
aryo scenario list >> "$LOG_FILE" 2>&1
log_success "Digital twin scenario lifecycle verified"