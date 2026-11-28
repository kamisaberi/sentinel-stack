#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_pack"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new water_pack_rule lua >/dev/null

test_command_assert \
    "sentinel-artifact pack <dir> <key>" \
    "Auto-pack and 4-way SHA-256 Merkle Ed25519 sign a Tier C LuaJIT project into .spkg." \
    0 \
    "Successfully packed unified Sentinel Artifact" \
    "sentinel-artifact pack water_pack_rule \"$SANDBOX/work/dev_private.pem\" && test -f water_pack_rule/water_pack_rule.spkg"