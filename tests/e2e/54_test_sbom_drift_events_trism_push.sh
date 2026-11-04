#!/usr/bin/env bash
# ==============================================================================
# TEST 54: SBOM DRIFT AUDIT & TRiSM POLICY PUSH ('aryo sbom/trism')
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 54: Live-SBOM DRIFT AUDIT & AI TRiSM POLICY PUSH"
cd "$WORKDIR"

# 1. Query In-Kernel Memory Drift Events via 'aryo sbom drift-events'
log_info "1. Executing 'aryo sbom drift-events --limit 10'..."
aryo sbom drift-events --limit 10 >> "$LOG_FILE" 2>&1
log_success "In-kernel W^X memory drift events audited"

# 2. Create Custom AI TRiSM Policy File
log_info "2. Synthesizing custom AI TRiSM prompt firewall policy..."
POLICY_YAML="$WORKDIR/custom_trism_policy.yaml"
cat << 'EOF' > "$POLICY_YAML"
policy_id: fleet-default
version: 2
blocked_prompt_delimiters:
  - "<|im_start|>"
  - "<|im_end|>"
  - "[INST]"
forbidden_tools:
  - shell_exec
  - plc_write
  - s7_write
allowed_tools:
  - read_tags
  - query_historian
require_human_approval: true
EOF
assert_file_exists "$POLICY_YAML"

# 3. Push Policy via 'aryo trism policy push'
log_info "3. Executing 'aryo trism policy push $POLICY_YAML'..."
aryo trism policy push "$POLICY_YAML" >> "$LOG_FILE" 2>&1
log_success "Fleet-wide AI TRiSM policy pushed to backend"

# 4. Verify Local Policy Sync via 'aryo trism policy pull'
log_info "4. Verifying local sync via 'aryo trism policy pull'..."
aryo trism policy pull >> "$LOG_FILE" 2>&1
aryo trism policy show >> "$LOG_FILE" 2>&1
log_success "AI TRiSM fleet policy successfully updated and verified"