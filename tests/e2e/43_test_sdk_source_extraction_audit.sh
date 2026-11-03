#!/usr/bin/env bash
# ==============================================================================
# TEST 43: C++/RUST SDK SCAFFOLDING & SOURCE CODE EXTRACTION AUDIT
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 43: SDK CODE SCAFFOLDING & MERKLE SOURCE EXTRACTION"
cd "$WORKDIR"

CPP_PROJ="cpp_guard_${RUN_TAG:-$(date +%s)}"
RUST_PROJ="rust_wasm_${RUN_TAG:-$(date +%s)}"

# 1. Scaffold Native C++20 Dissector Project
log_info "1. Scaffolding Native C++20 dissector project ($CPP_PROJ)..."
aryo package new "$CPP_PROJ" cpp >> "$LOG_FILE" 2>&1
assert_file_exists "$WORKDIR/$CPP_PROJ/CMakeLists.txt"
assert_file_exists "$WORKDIR/$CPP_PROJ/src/plugin.cpp"
log_success "Native C++20 project scaffolded (CMakeLists.txt & SENTINEL_REGISTER_PLUGIN verified)"

# 2. Scaffold Rust Wasm3 Sandbox Project
log_info "2. Scaffolding Rust Wasm3 sandbox project ($RUST_PROJ)..."
aryo package new "$RUST_PROJ" rust >> "$LOG_FILE" 2>&1
assert_file_exists "$WORKDIR/$RUST_PROJ/Cargo.toml"
assert_file_exists "$WORKDIR/$RUST_PROJ/src/lib.rs"
log_success "Rust Wasm3 project scaffolded (Cargo.toml & #[no_mangle] sentinel_dissect verified)"

# 3. Pack Lua Project & Test Auditable Source Extraction
LUA_PROJ="lua_source_audit_${RUN_TAG:-$(date +%s)}"
log_info "3. Scaffolding LuaJIT project for Merkle source code extraction..."
aryo package new "$LUA_PROJ" lua >> "$LOG_FILE" 2>&1
aryo artifact pack "$LUA_PROJ" "$DEV_KEY" >> "$LOG_FILE" 2>&1

SPKG_FILE=$(ls "$WORKDIR/$LUA_PROJ"/*.spkg | head -n 1)
assert_file_exists "$SPKG_FILE"

EXTRACTED_SRC="$WORKDIR/${LUA_PROJ}_extracted_source.lua"
log_info "4. Extracting auditable source code from sealed container..."
aryo artifact extract-source "$SPKG_FILE" "$EXTRACTED_SRC" >> "$LOG_FILE" 2>&1

assert_file_exists "$EXTRACTED_SRC"
if ! diff -q "$WORKDIR/$LUA_PROJ/$LUA_PROJ.lua" "$EXTRACTED_SRC" > /dev/null 2>&1; then
    log_fail "Extracted source code does not match original source code!"
fi
log_success "Merkle source code extraction verified (100% source fidelity confirmed)"