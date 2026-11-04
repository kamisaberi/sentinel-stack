#!/usr/bin/env bash
# ==============================================================================
# TEST 51: AUTHOR KEY ROTATION VIA 'aryo auth update-key'
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 51: AUTHOR KEY ROTATION ('aryo auth update-key')"
cd "$WORKDIR"

# 1. Acquire and refresh active JWT in credentials.json on disk
JWT=$(get_jwt_token)
if [[ -z "$JWT" ]]; then
    log_fail "Failed to acquire valid JWT token."
fi

# 2. Generate Temporary Keypair for Key Rotation Test
log_info "1. Generating temporary keypair for rotation test..."
TEMP_KEY_PREFIX="$WORKDIR/keys/temp_rotation"
mkdir -p "$WORKDIR/keys"
sentinel-artifact keygen "$TEMP_KEY_PREFIX" >> "$LOG_FILE" 2>&1
TEMP_PRIV_KEY="${TEMP_KEY_PREFIX}_private.pem"
assert_file_exists "$TEMP_PRIV_KEY"

# Extract raw public key hex from temp key
TEMP_PUB_HEX=$(openssl pkey -in "$TEMP_PRIV_KEY" -pubout -outform DER | tail -c 32 | xxd -p -c 32)
log_info "  ├── Temporary Test Public Key: ${TEMP_PUB_HEX:0:16}..."

# 3. Execute 'aryo auth update-key' to Rotate Key on Backend
log_info "2. Rotating author key on backend ('aryo auth update-key')..."
if ! aryo auth update-key "$TEMP_PRIV_KEY" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Key rotation failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi

# 4. Verify Updated Key in credentials.json
log_info "3. Verifying updated author_public_key in credentials.json..."
SAVED_KEY=$(jq -r '.author_public_key // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.author_public_key // empty' /root/.sentinel/credentials.json)

if [[ "$SAVED_KEY" != "$TEMP_PUB_HEX" ]]; then
    log_fail "Key rotation failed. Expected $TEMP_PUB_HEX, found: $SAVED_KEY"
fi
log_success "Author key rotated on backend and saved to credentials.json"

# 5. Rotate Back to Master Enrolled Key ($DEV_KEY) for Suite Consistency
log_info "4. Restoring master enrolled developer key ($DEV_KEY)..."
aryo auth update-key "$DEV_KEY" >> "$LOG_FILE" 2>&1

MASTER_PUB_HEX=$(openssl pkey -in "$DEV_KEY" -pubout -outform DER | tail -c 32 | xxd -p -c 32)
RESTORED_KEY=$(jq -r '.author_public_key // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.author_public_key // empty' /root/.sentinel/credentials.json)

if [[ "$RESTORED_KEY" != "$MASTER_PUB_HEX" ]]; then
    log_fail "Failed to restore master developer key. Expected $MASTER_PUB_HEX, found: $RESTORED_KEY"
fi
log_success "Master developer key restored and verified: ${MASTER_PUB_HEX:0:16}..."