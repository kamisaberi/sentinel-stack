#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_new_lua"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

test_command_assert \
    "sentinel-artifact new <name> lua" \
    "Scaffold a Tier C LuaJIT FFI reflex rule project for the live water dosing scenario." \
    0 \
    "Successfully scaffolded artifact project" \
    "sentinel-artifact new water_dosing_lua lua && test -f water_dosing_lua/water_dosing_lua.lua && test -f water_dosing_lua/manifest.json"