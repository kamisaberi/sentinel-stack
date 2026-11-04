#!/usr/bin/env bash
# ==============================================================================
# TEST 53: THREAT VACCINE SHARING & FEED VIA 'aryo threat vaccine-*'
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

VAC_SLUG="vaccine_grid_${RUN_TAG:-$(date +%s)}"

log_header "TEST 53: VACCINE SHARE & FEED ('aryo threat vaccine-*') [Slug: $VAC_SLUG]"
cd "$WORKDIR"

# 1. Scaffold and Pack Sealed Vaccine Package
log_info "1. Scaffolding test vaccine package ($VAC_SLUG)..."
rm -rf "$WORKDIR/$VAC_SLUG"
aryo package new "$VAC_SLUG" lua >> "$LOG_FILE" 2>&1
aryo artifact pack "$VAC_SLUG" "$DEV_KEY" >> "$LOG_FILE" 2>&1

VAC_FILE=$(ls "$WORKDIR/$VAC_SLUG"/*.spkg | head -n 1)
assert_file_exists "$VAC_FILE"

# 2. Share Vaccine via 'aryo threat vaccine-share'
log_info "2. Executing 'aryo threat vaccine-share $VAC_FILE'..."
aryo threat vaccine-share "$VAC_FILE" >> "$LOG_FILE" 2>&1
log_success "Vaccine shared to collective defense grid"

# 3. Query Active Vaccine Feed via 'aryo threat vaccine-feed'
log_info "3. Executing 'aryo threat vaccine-feed 10'..."
aryo threat vaccine-feed 10 >> "$LOG_FILE" 2>&1
log_success "Active vaccine feed queried and rendered"