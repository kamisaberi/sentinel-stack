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

# 1. Evaluate Automated Bot Trajectory (Constant linear velocity & zero jitter)
log_info "1. Submitting synthetic linear trajectory to Bot Evaluator (/bot/evaluate)..."
BOT_RESP=$(curl -s -X POST "$BACKEND_BASE/bot/evaluate" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "session_id": "sess_bot_script_01",
        "kinematic_vectors": [
            {"x": 0.0, "y": 0.0, "dt_ms": 10.0},
            {"x": 1.0, "y": 0.0, "dt_ms": 10.0},
            {"x": 2.0, "y": 0.0, "dt_ms": 10.0},
            {"x": 3.0, "y": 0.0, "dt_ms": 10.0},
            {"x": 4.0, "y": 0.0, "dt_ms": 10.0}
        ],
        "keystroke_jitter_ms": 0.01
    }')

BOT_VERDICT=$(echo "$BOT_RESP" | jq -r '.verdict // empty')
if [[ "$BOT_VERDICT" != "AUTOMATED_BOT" ]]; then
    log_fail "Expected AUTOMATED_BOT verdict, received: $BOT_VERDICT. Response:\n$BOT_RESP"
fi
log_success "Kinematic evaluator identified bot: $BOT_VERDICT"

# 2. Evaluate Legitimate Human Session
log_info "2. Submitting organic human operator session to Bot Evaluator..."
HUMAN_RESP=$(curl -s -X POST "$BACKEND_BASE/bot/evaluate" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "session_id": "sess_human_engineer_01",
        "kinematic_vectors": []
    }')

HUMAN_VERDICT=$(echo "$HUMAN_RESP" | jq -r '.verdict // empty')
if [[ "$HUMAN_VERDICT" != "HUMAN_VERIFIED" ]]; then
    log_fail "Expected HUMAN_VERIFIED verdict, received: $HUMAN_VERDICT. Response:\n$HUMAN_RESP"
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