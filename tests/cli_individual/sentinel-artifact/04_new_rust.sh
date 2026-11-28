#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_new_rust"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

test_command_assert \
    "sentinel-artifact new <name> rust" \
    "Scaffold a Tier B Rust Wasm3 sandbox project (< 1.5 us SLA) alongside live ICS twin." \
    0 \
    "Successfully scaffolded artifact project" \
    "sentinel-artifact new water_dosing_rust rust && test -f water_dosing_rust/Cargo.toml && test -f water_dosing_rust/src/lib.rs"