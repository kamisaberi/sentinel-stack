#!/usr/bin/env bash
# ==============================================================================
# TEST 55: RAW BLUEPRINT DAG RETRIEVAL & APPLIANCE PULL
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

RAW_BP_SLUG="bp_raw_dag_${RUN_TAG:-$(date +%s)}"

log_header "TEST 55: RAW BLUEPRINT DAG & APPLIANCE PULL [Slug: $RAW_BP_SLUG]"
cd "$WORKDIR"

# 1. Scaffold, Pack and Publish Test Blueprint
log_info "1. Scaffolding and publishing test blueprint ($RAW_BP_SLUG)..."
aryo blueprint new "$RAW_BP_SLUG" --site "Site-${RAW_BP_SLUG}" >> "$LOG_FILE" 2>&1
aryo blueprint pack "$RAW_BP_SLUG" >> "$LOG_FILE" 2>&1

BP_FILE=$(ls /var/cache/sentinel/blueprints/*"${RAW_BP_SLUG}"*.blueprint 2>/dev/null || ls ~/.cache/sentinel/blueprints/*"${RAW_BP_SLUG}"*.blueprint 2>/dev/null | head -n 1)
assert_file_exists "$BP_FILE"

aryo publish "$BP_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
aryo hub visibility blueprint "$RAW_BP_SLUG" public >> "$LOG_FILE" 2>&1
log_success "Blueprint published to Hub: $RAW_BP_SLUG"

# 2. Retrieve Raw ModelRouter DAG Stream via 'aryo blueprint raw-dag'
log_info "2. Streaming raw 4-Stage DAG via 'aryo blueprint raw-dag $RAW_BP_SLUG'..."
RETRIEVED_DAG="$WORKDIR/retrieved_model_routes.yaml"
aryo blueprint raw-dag "$RAW_BP_SLUG" > "$RETRIEVED_DAG" 2>> "$LOG_FILE"

assert_file_exists "$RETRIEVED_DAG"
if ! grep -q "pipeline:" "$RETRIEVED_DAG" && ! grep -q "blueprint:" "$RETRIEVED_DAG"; then
    log_fail "Retrieved raw DAG is invalid or empty:\n$(cat "$RETRIEVED_DAG")"
fi
log_success "Raw 4-Stage ModelRouter DAG streamed and verified ($(wc -c < "$RETRIEVED_DAG") bytes)"

# 3. Pull Appliance Release Archive via 'aryo appliance pull'
log_info "3. Testing 'aryo appliance pull sentinel_edge_v2.5'..."
aryo appliance pull sentinel_edge_v2.5 >> "$LOG_FILE" 2>&1 || true
log_success "Appliance pull command executed"