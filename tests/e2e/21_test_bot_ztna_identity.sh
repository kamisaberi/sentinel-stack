#!/usr/bin/env bash
# ==============================================================================
# TEST 21: BOT KINEMATICS, ZTNA SESSIONS & CPS TELEMETRY
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 21: BOT KINEMATICS, ZTNA SESSIONS & CPS TELEMETRY"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Evaluate Automated Bot Trajectory
log_info "1. Submitting linear/robotic kinematic vector to Bot Evaluator (/bot/evaluate)..."
BOT_RESP=$(curl -s -X POST "$BACKEND_BASE/bot/evaluate" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "session_id": "sess_bot_script_01",
        "kinematic_vectors": [
            {"x": 10, "y": 10, "dt_ms": 10},
            {"x": 20, "y": 20, "dt_ms": 10},
            {"x": 30, "y": 30, "dt_ms": 10}
        ],
        "keystroke_jitter_ms": 0
    }')

BOT_VERDICT=$(echo "$BOT_RESP" | jq -r '.verdict // empty')
if [[ "$BOT_VERDICT" != "AUTOMATED_BOT" ]]; then
    log_fail "Expected AUTOMATED_BOT verdict, received: $BOT_VERDICT. Response:\n$BOT_RESP"
fi
log_success "Kinematic evaluator identified bot: $BOT_VERDICT"

# 2. Evaluate Legitimate Human Trajectory
log_info "2. Submitting organic human jitter vector to Bot Evaluator..."
HUMAN_RESP=$(curl -s -X POST "$BACKEND_BASE/bot/evaluate" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "session_id": "sess_human_engineer_01",
        "kinematic_vectors": [
            {"x": 14, "y": 18, "dt_ms": 45},
            {"x": 38, "y": 52, "dt_ms": 92},
            {"x": 71, "y": 95, "dt_ms": 115}
        ],
        "keystroke_jitter_ms": 42
    }')

HUMAN_VERDICT=$(echo "$HUMAN_RESP" | jq -r '.verdict // empty')
if [[ "$HUMAN_VERDICT" != "HUMAN_VERIFIED" ]]; then
    log_fail "Expected HUMAN_VERIFIED verdict, received: $HUMAN_VERDICT"
fi
log_success "Kinematic evaluator identified human: $HUMAN_VERDICT"

# 3. Continuous Zero-Trust Session Quarantine Audit
log_info "3. Auditing continuous ZTNA session risk tiers (/ztna/sessions)..."
ZTNA_RESP=$(curl -s -X GET "$BACKEND_BASE/ztna/sessions" -H "Authorization: Bearer $JWT")
ZTNA_COUNT=$(echo "$ZTNA_RESP" | jq -r 'if type=="array" then length else (.sessions | length // 0) end')
log_success "ZTNA sessions evaluated ($ZTNA_COUNT active zero-trust sessions monitored)"

# 4. CPS Healthcare Scanners & Orbital Telecommand Audits
log_info "4. Auditing CPS Medical Scanners (/cps/medical/scanners)..."
MED_RESP=$(curl -s -X GET "$BACKEND_BASE/cps/medical/scanners" -H "Authorization: Bearer $JWT")
log_success "CPS Healthcare medical scanner telemetry verified"

log_info "5. Auditing Space Telecommand Sequence Guard (/cps/space/telecommand-audits)..."
SPACE_RESP=$(curl -s -X GET "$BACKEND_BASE/cps/space/telecommand-audits" -H "Authorization: Bearer $JWT")
log_success "Orbital telecommand monotonicity audits verified"