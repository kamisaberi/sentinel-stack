#!/usr/bin/env bash
# ==============================================================================
# TEST 02: EXTENSION PACKAGES (.spkg) LIFECYCLE
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 02: SENTINEL PACKAGES (.spkg)"
cd "$WORKDIR"

# Clean up any leftover artifacts from prior runs in this workspace
rm -rf "$WORKDIR/s7_safety_guard"

# 1. Resolve Persistent Developer Private Key
log_info "1. Locating enrolled author developer key..."
DEV_KEY=""
KEY_CANDIDATES=(
    "${HOME}/.sentinel/keys/developer_private.pem"
    "${HOME}/.sentinel/keys/ed25519_private.pem"
    "/home/kami/.sentinel/keys/developer_private.pem"
    "/home/kami/.sentinel/keys/ed25519_private.pem"
    "/etc/sentinel/keys/developer_private.pem"
    "/etc/sentinel/keys/ed25519_private.pem"
    "/home/kami/.sentinel/keys/developer_private.pem"
    "/home/kami/.sentinel/keys/ed25519_private.pem"
    "${HOME}/.sentinel/keys/developer_private.pem"
    "${HOME}/.sentinel/keys/ed25519_private.pem"
    "/etc/sentinel/keys/developer_private.pem"
)

for k in "${KEY_CANDIDATES[@]}"; do
    if [[ -f "$k" ]]; then
        DEV_KEY="$k"
        break
    fi
done

if [[ -z "$DEV_KEY" ]]; then
    # Generate persistent key once in user home directory if missing
    KEY_DIR="${HOME}/.sentinel/keys"
    mkdir -p "$KEY_DIR"
    sentinel-artifact keygen "$KEY_DIR/developer" >> "$LOG_FILE" 2>&1
    DEV_KEY="$KEY_DIR/developer_private.pem"
    log_info "Generated fresh author identity key at $DEV_KEY"
else
    log_info "Using enrolled author key: $DEV_KEY"
fi

# 2. Scaffold Package Project
log_info "2. Scaffolding new LuaJIT reflex package..."
aryo package new s7_safety_guard lua >> "$LOG_FILE" 2>&1

# 3. Pack and Sign Package with Enrolled Key
log_info "3. Packing and signing package with author key..."
aryo artifact pack s7_safety_guard "$DEV_KEY" >> "$LOG_FILE" 2>&1

PKG_FILE=$(ls "$WORKDIR"/s7_safety_guard/*.spkg 2>/dev/null | head -n 1)
assert_file_exists "$PKG_FILE"

# 4. Sandbox Pre-Flight Verification
log_info "4. Running sandbox pre-flight assertion..."
aryo artifact test "$PKG_FILE" >> "$LOG_FILE" 2>&1
log_success "Package packed & pre-flight verified authentic ($PKG_FILE)"

# 5. Publish Package to Hub
log_info "5. Publishing package to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$PKG_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] Publish failed. Recent log entries:${RESET}"
    tail -n 15 "$LOG_FILE"
    exit 1
fi
log_success "Published package to Hub"

# 6. Hub Search & Pull
log_info "6. Querying live Hub catalog..."
aryo hub search s7_safety >> "$LOG_FILE" 2>&1

log_info "7. Pulling and installing package into active runtime..."
sudo aryo package pull s7_safety_guard >> "$LOG_FILE" 2>&1

# Verify physical runtime deployment
assert_file_exists "/etc/sentinel/rules.d/s7_safety_guard.lua"
log_success "Package deployed and active in /etc/sentinel/rules.d/s7_safety_guard.lua"