#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_install_spkg"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/ssfs"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new edge_water_rule lua >/dev/null
sentinel-artifact pack edge_water_rule "$SANDBOX/work/dev_private.pem" >/dev/null

test_command_assert \
    "sentinel-ctl install <file.spkg>" \
    "Verify 4-way SHA-256 Merkle Ed25519 signature and deploy Tier C LuaJIT payload into isolated SSFS runtime." \
    0 \
    "Ed25519 Merkle Signature VERIFIED AUTHENTIC" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" sentinel-ctl install edge_water_rule/edge_water_rule.spkg && find \"$SANDBOX/ssfs\" -name 'edge_water_rule.lua' | grep -q edge_water_rule.lua"