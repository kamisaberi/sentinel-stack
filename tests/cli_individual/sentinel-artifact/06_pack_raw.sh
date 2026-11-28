#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_pack_raw"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new raw_rule lua >/dev/null

test_command_assert \
    "sentinel-artifact pack-raw" \
    "Manually seal a .spkg container via low-level pack-raw specifying tier(2=Lua) and all 4 Merkle sections." \
    0 \
    "Successfully packed unified Sentinel Artifact" \
    "sentinel-artifact pack-raw \"$SANDBOX/work/dev_private.pem\" 2 raw_rule/manifest.json raw_rule/raw_rule.lua raw_rule/raw_rule.lua raw_rule/tests/preflight_frame.bin raw_sealed.spkg && test -f raw_sealed.spkg"