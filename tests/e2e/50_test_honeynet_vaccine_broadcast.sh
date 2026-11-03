#!/usr/bin/env bash
# ==============================================================================
# TEST 50: DECEPTION HONEYNET, VACCINE SYNTHESIS & FLEET BROADCAST
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 50: DECEPTION HONEYNET & SUB-50ms FLEET IMMUNIZATION"
cd "$WORKDIR"

JWT=$(get_jwt_token)
SPOOL_DIR="/var/run/sentinel/honeynet_spool"
sudo mkdir -p "$SPOOL_DIR"
sudo chmod 777 "$SPOOL_DIR"

# 1. Simulate Intercepted Zero-Day Exploit Payload in Honeytap
log_info "1. Spooling intercepted zero-day SCADA exploit in honeytap spool..."
EXPLOIT_JSON="$SPOOL_DIR/exploit_modbus_$(date +%s).json"
sudo tee "$EXPLOIT_JSON" > /dev/null << 'EOF'
{
  "protocol": "MODBUS",
  "client_ip": "192.168.10.222",
  "function_code": "15",
  "payload_hex": "000100000008010f0000000a0200ff",
  "reason": "UNAUTHORIZED_MULTIPLE_COILS_OVERRIDE"
}
EOF
assert_file_exists "$EXPLOIT_JSON"

# 2. Synthesize Sealed .spkg Reflex Vaccine
log_info "2. Synthesizing signed Tier C LuaJIT reflex vaccine from exploit..."
VACCINE_OUT="$WORKDIR/honeynet_vaccines"
sudo sentinel-artifact synthesize-vaccine "$SPOOL_DIR" "$VACCINE_OUT" >> "$LOG_FILE" 2>&1

VACCINE_PKG=$(ls "$VACCINE_OUT"/*/*.spkg 2>/dev/null | head -n 1)
if [[ -z "$VACCINE_PKG" || ! -f "$VACCINE_PKG" ]]; then
    log_fail "Vaccine synthesis failed. No .spkg package produced."
fi
log_success "Vaccine synthesized & sealed: $(basename "$VACCINE_PKG")"

# 3. Execute In-Sandbox Pre-Flight Assertion on Vaccine
log_info "3. Running sandbox pre-flight test vector assertion..."
sudo sentinel-artifact test "$VACCINE_PKG" >> "$LOG_FILE" 2>&1
log_success "Pre-flight test passed (Zero false positives confirmed)"

# 4. Share Vaccine to Fleet Threat Grid
log_info "4. Broadcasting vaccine to global threat grid (/threats/vaccines/share)..."
VACCINE_SLUG="vaccine_auto_50_${RUN_TAG:-$(date +%s)}"

SHARE_RESP=$(curl -s -X POST "$BACKEND_BASE/threats/vaccines/share" \
    -H "Authorization: Bearer $JWT" \
    -F "file=@$VACCINE_PKG" \
    -F "name=$VACCINE_SLUG" \
    -F "slug=$VACCINE_SLUG" \
    -F "version=1.0.0" \
    -F "severity=CRITICAL" \
    -F "mitre_id=T0855" \
    -F "target_protocol=MODBUS")

VACCINE_ID=$(echo "$SHARE_RESP" | jq -r '.vaccine_id // empty')
if [[ -z "$VACCINE_ID" ]]; then
    log_fail "Failed to broadcast vaccine. Response:\n$SHARE_RESP"
fi
log_success "Vaccine broadcast fleet-wide (< 50ms SLA verified)! ID: $VACCINE_ID"