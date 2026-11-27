#!/usr/bin/env bash
# ==============================================================================
# SUITE 02: SENTINEL-ARTIFACT (Cryptographic SDK & Publisher) — ONE-BY-ONE TESTS
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib_cli_test.sh"
init_sandbox "cli_artifact"
cd "$SANDBOX/work"

log_section "SUITE 02: SENTINEL-ARTIFACT (Tier 1 Cryptographic SDK & Sealer)"

run_cli_test "sentinel-artifact --help" \
    "Display SDK authoring, SLAB protocol, PCAP sealing, vaccine synthesis, and publish usage." \
    0 "sentinel-artifact --help"

run_cli_test "sentinel-artifact keygen" \
    "Generate an Ed25519 developer keypair (private + public PEM files)." \
    0 "sentinel-artifact keygen \"$SANDBOX/work/dev_key\" && test -f \"$SANDBOX/work/dev_key_private.pem\" && test -f \"$SANDBOX/work/dev_key_public.pem\""

run_cli_test "sentinel-artifact new <name> lua" \
    "Scaffold a Tier C LuaJIT FFI extension project with manifest.json and preflight_frame.bin." \
    0 "sentinel-artifact new demo_lua_guard lua && test -f demo_lua_guard/demo_lua_guard.lua"

run_cli_test "sentinel-artifact new <name> cpp" \
    "Scaffold a Tier A Native C++20 dissector project (CMakeLists.txt + src/plugin.cpp)." \
    0 "sentinel-artifact new demo_cpp_guard cpp && test -f demo_cpp_guard/src/plugin.cpp"

run_cli_test "sentinel-artifact new <name> rust" \
    "Scaffold a Tier B Rust Wasm3 sandbox project (Cargo.toml + src/lib.rs)." \
    0 "sentinel-artifact new demo_rust_guard rust && test -f demo_rust_guard/src/lib.rs"

run_cli_test "sentinel-artifact pack <dir> <key>" \
    "Auto-pack and 4-way SHA-256 Merkle Ed25519 sign a scaffolded Lua project into .spkg." \
    0 "sentinel-artifact pack demo_lua_guard \"$SANDBOX/work/dev_key_private.pem\" && test -f demo_lua_guard/demo_lua_guard.spkg"

run_cli_test "sentinel-artifact pack-raw" \
    "Low-level manual .spkg sealing specifying key, tier(2=Lua), manifest, payload, source, test vector, and output." \
    0 "sentinel-artifact pack-raw \"$SANDBOX/work/dev_key_private.pem\" 2 demo_lua_guard/manifest.json demo_lua_guard/demo_lua_guard.lua demo_lua_guard/demo_lua_guard.lua demo_lua_guard/tests/preflight_frame.bin raw_sealed.spkg && test -f raw_sealed.spkg"

run_cli_test "sentinel-artifact inspect <file.spkg>" \
    "Parse binary SpkgHeader (ARYOSPKG), execution tier, section sizes, and embedded JSON manifest." \
    0 "sentinel-artifact inspect demo_lua_guard/demo_lua_guard.spkg"

run_cli_test "sentinel-artifact verify <pub_key> <file.spkg>" \
    "Cryptographically verify the 4-way SHA-256 Merkle Ed25519 signature of a .spkg container." \
    0 "sentinel-artifact verify \"$SANDBOX/work/dev_key_public.pem\" demo_lua_guard/demo_lua_guard.spkg"

run_cli_test "sentinel-artifact extract-source <file.spkg> <out>" \
    "Extract embedded human-readable source code from a sealed .spkg for security audit." \
    0 "sentinel-artifact extract-source demo_lua_guard/demo_lua_guard.spkg extracted_audit.lua && test -s extracted_audit.lua"

run_cli_test "sentinel-artifact test <file.spkg>" \
    "Execute in-sandbox pre-flight threat assertion against the embedded preflight_frame.bin vector." \
    0 "sentinel-artifact test demo_lua_guard/demo_lua_guard.spkg"

# SLAB 0x534C4142 Binary Dataset Engine
cat > sample_telemetry.csv <<'CSV'
f1,f2,f3,f4,label
0.12,0.34,0.56,0.78,0
0.99,0.88,0.77,0.66,1
CSV

run_cli_test "sentinel-artifact slab convert <csv> <out.slab> <dim>" \
    "Convert CSV telemetry into Big-Endian 0x534C4142 zero-copy binary SLAB format + manifest.json." \
    0 "sentinel-artifact slab convert sample_telemetry.csv sample_telemetry.slab 4 && test -f sample_telemetry.slab"

run_cli_test "sentinel-artifact slab verify <file.slab>" \
    "Verify magic header (0x534C4142), record count, and tensor dimensionality of a .slab file." \
    0 "sentinel-artifact slab verify sample_telemetry.slab"

# Sealed PCAP (.spcap) Engine
printf '\xd4\xc3\xb2\xa1\x02\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\x00\x00\x01\x00\x00\x00' > dummy.pcap
echo '{"name":"dummy","asset_type":"pcap"}' > dummy_pcap_manifest.json

run_cli_test "sentinel-artifact pcap pack <key> <manifest> <in.pcap> <out.spcap>" \
    "Sign and seal a raw PCAP capture + manifest into a cryptographic .spcap container (SPKGPAP)." \
    0 "sentinel-artifact pcap pack \"$SANDBOX/work/dev_key_private.pem\" dummy_pcap_manifest.json dummy.pcap sealed.spcap && test -f sealed.spcap"

# Autonomous Honeynet Vaccine Synthesis
cat > exploit_1700000001.json <<'JSON'
{
  "protocol": "MODBUS",
  "client_ip": "10.240.0.99",
  "function_code": 5,
  "payload_hex": "00010000000601050001ff00",
  "reason": "Unauthorized Modbus FC05 Write Single Coil"
}
JSON

run_cli_test "sentinel-artifact synthesize-vaccine <exploit.json> <out_dir>" \
    "Auto-synthesize a LuaJIT reflex rule, pack, Ed25519-sign, and preflight-test a .spkg vaccine." \
    0 "sentinel-artifact synthesize-vaccine exploit_1700000001.json \"$SANDBOX/work/vaccines\""

run_cli_test "sentinel-artifact publish (missing file guard)" \
    "Verify publish rejects nonexistent files cleanly without attempting network upload." \
    1 "sentinel-artifact publish /tmp/__nonexistent_artifact__.spkg --token dummy"

print_suite_summary "02_sentinel_artifact"
