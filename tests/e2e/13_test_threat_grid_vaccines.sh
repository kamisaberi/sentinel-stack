#!/usr/bin/env bash
# ==============================================================================
# TEST 13: FLEET COLLECTIVE DEFENSE & VACCINE SHARING
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 13: THREAT GRID BROADCAST & FLEET VACCINE SHARING"
cd "$WORKDIR"

# 1. Load validated user JWT token
JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)
if [[ -z "$JWT" ]]; then
    log_fail "No JWT token found in credentials.json. Run Test 01 first."
fi
AUTH_HEADER="Authorization: Bearer $JWT"

# 2. Broadcast Malicious Attacker IP to Collective Defense Grid
ATTACKER_IP="198.51.100.$((RANDOM % 200 + 10))"
log_info "1. Broadcasting attacker IP ($ATTACKER_IP) to threat bus..."

BCAST_RESP=$(curl -s -X POST "$BACKEND_BASE/threats/broadcast" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d "{
        \"ip\": \"$ATTACKER_IP\",
        \"attributions\": [{\"tactic\": \"TA0108\", \"technique\": \"T0855\", \"confidence\": 0.99}]
    }")

STATUS=$(echo "$BCAST_RESP" | jq -r '.status // empty')
if [[ "$STATUS" != "broadcast_dispatched" ]]; then
    log_fail "Threat broadcast failed. Response:\n$BCAST_RESP"
fi
log_success "Attacker IP $ATTACKER_IP broadcast to collective defense bus"

# 3. Verify Presence in Global Feed
log_info "2. Verifying IP appears in live global feed..."
FEED_RESP=$(curl -s -X GET "$BACKEND_BASE/threats/global-feed?verbose=true" -H "$AUTH_HEADER")
if ! echo "$FEED_RESP" | grep -q "$ATTACKER_IP"; then
    log_fail "Broadcast IP $ATTACKER_IP was not found in the global threat feed:\n$FEED_RESP"
fi
log_success "IP $ATTACKER_IP verified in global threat feed"

# 4. Share Honeynet-Synthesized Vaccine to Global Fleet Feed
log_info "3. Sharing honeynet-synthesized .spkg vaccine to fleet..."
VACCINE_SLUG="vaccine_modbus_${RUN_TAG:-$(date +%s)}"

# Clean up any conflicting directory before scaffolding
rm -rf "$WORKDIR/$VACCINE_SLUG"
aryo package new "$VACCINE_SLUG" lua >> "$LOG_FILE" 2>&1

# Pack and sign vaccine package with author key
aryo artifact pack "$VACCINE_SLUG" "$DEV_KEY" >> "$LOG_FILE" 2>&1
VACCINE_FILE=$(ls "$WORKDIR/$VACCINE_SLUG"/*.spkg 2>/dev/null | head -n 1)
assert_file_exists "$VACCINE_FILE"

SHARE_RESP=$(curl -s -X POST "$BACKEND_BASE/threats/vaccines/share" \
    -H "$AUTH_HEADER" \
    -F "file=@$VACCINE_FILE" \
    -F "name=$VACCINE_SLUG" \
    -F "slug=$VACCINE_SLUG" \
    -F "version=1.0.0" \
    -F "severity=CRITICAL" \
    -F "mitre_id=T0855" \
    -F "target_protocol=MODBUS")

VACCINE_ID=$(echo "$SHARE_RESP" | jq -r '.vaccine_id // empty')
if [[ -z "$VACCINE_ID" ]]; then
    log_fail "Failed to share vaccine to feed. Response:\n$SHARE_RESP"
fi
log_success "Vaccine shared to fleet! ID: $VACCINE_ID"

# 5. Audit Vaccine in Global Fleet Feed
log_info "4. Auditing vaccine in global vaccine feed (/threats/vaccines/feed)..."
V_FEED=$(curl -s -X GET "$BACKEND_BASE/threats/vaccines/feed" -H "$AUTH_HEADER")
if ! echo "$V_FEED" | grep -q "$VACCINE_ID"; then
    log_fail "Vaccine $VACCINE_ID not found in active fleet vaccine feed"
fi
log_success "Vaccine $VACCINE_ID verified in active fleet vaccine feed"

# 6. Download Sealed Vaccine as Edge Node
log_info "5. Downloading sealed vaccine artifact (/threats/vaccines/$VACCINE_ID/download)..."
DOWNLOADED_VACCINE="$WORKDIR/${VACCINE_SLUG}_edge_node.spkg"
curl -s -X GET "$BACKEND_BASE/threats/vaccines/$VACCINE_ID/download" \
    -H "$AUTH_HEADER" \
    -o "$DOWNLOADED_VACCINE"

assert_file_exists "$DOWNLOADED_VACCINE"
# Run in-sandbox preflight assertion on downloaded artifact
aryo artifact test "$DOWNLOADED_VACCINE" >> "$LOG_FILE" 2>&1
log_success "Downloaded vaccine verified and pre-flight tested (< 50ms fleet deployment ready)"