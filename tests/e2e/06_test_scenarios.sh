#!/usr/bin/env bash
# ==============================================================================
# TEST 06: DIGITAL TWIN RANGE SCENARIOS (DYNAMIC SLUG & METHOD 2 VISIBILITY)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

SCEN_SLUG="scen_${RUN_TAG:-$(date +%s)}"

log_header "TEST 06: DIGITAL TWIN RANGE SCENARIOS [Slug: $SCEN_SLUG]"
cd "$WORKDIR"

# Clean up any previous test scenario folders
rm -rf "$WORKDIR/$SCEN_SLUG"
rm -rf "/home/kami/sentinel-matrix/scenarios/$SCEN_SLUG"

# 1. Scaffold New Scenario Project
log_info "1. Scaffolding new digital twin scenario skeleton ($SCEN_SLUG)..."
aryo scenario new "$SCEN_SLUG" --sector WATER_TREATMENT >> "$LOG_FILE" 2>&1

SCEN_DIR="$WORKDIR/$SCEN_SLUG"
if [[ ! -d "$SCEN_DIR" && -d "/home/kami/sentinel-matrix/scenarios/$SCEN_SLUG" ]]; then
    SCEN_DIR="/home/kami/sentinel-matrix/scenarios/$SCEN_SLUG"
fi
assert_file_exists "$SCEN_DIR/scenario.yaml"
log_success "Scenario scaffolded at: $SCEN_DIR"

# 2. Register Dependency
log_info "2. Registering dependency in scenario manifest..."
aryo scenario add "$SCEN_SLUG" s7_safety_guard >> "$LOG_FILE" 2>&1

# 3. Pack Scenario into Hub-Optimized Bundle (~15 KB)
log_info "3. Packing scenario bundle..."
aryo scenario pack "$SCEN_SLUG" >> "$LOG_FILE" 2>&1
SCEN_ARCHIVE=$(ls /var/cache/sentinel/scenarios/*"${SCEN_SLUG}"*.tar.gz 2>/dev/null || ls ~/.cache/sentinel/scenarios/*"${SCEN_SLUG}"*.tar.gz 2>/dev/null || ls "$WORKDIR"/*"${SCEN_SLUG}"*.tar.gz 2>/dev/null | head -n 1)
assert_file_exists "$SCEN_ARCHIVE"

# 4. Publish Scenario Bundle to Hub
log_info "4. Publishing unique scenario ($SCEN_SLUG) to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$SCEN_ARCHIVE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Scenario publish failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Scenario published to Hub (HTTP 201 Created)"

# 4b. Method 2: Promote Visibility to Public
log_info "4b. Promoting scenario visibility to 'public' via Method 2..."
if ! aryo hub visibility scenario "$SCEN_SLUG" public >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Scenario visibility promotion failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "Scenario visibility updated to 'public'"

# 5. Pull Scenario and Stage to sentinel-matrix
log_info "5. Pulling scenario and staging to sentinel-matrix..."
aryo scenario pull "$SCEN_SLUG" >> "$LOG_FILE" 2>&1
aryo scenario list >> "$LOG_FILE" 2>&1

# 6. Teardown temporary scenario folder from matrix directory
rm -rf "/home/kami/sentinel-matrix/scenarios/$SCEN_SLUG"
log_success "Digital twin scenario lifecycle verified"