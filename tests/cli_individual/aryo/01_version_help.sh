#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_ver_help"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo --version && aryo --help" \
    "Verify Master CLI banner (v2.5.0), 18 core domains, and dynamic discovery of all 5 Tier-2 cartridge plugins." \
    0 \
    "Unified Active Defense & Research Master CLI" \
    "aryo --version && aryo --help"