#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_trism_jb"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl trism test-jailbreak" \
    "Execute built-in 5-vector GenAI red-team prompt injection and tool-calling benchmark suite." \
    0 \
    "PASS.*All 4 GenAI prompt injection vectors neutralized" \
    "sentinel-ctl trism test-jailbreak"