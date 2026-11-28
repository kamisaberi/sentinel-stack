#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "comp_forge"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "forge-cli --help" \
    "Verify xInfer Forge continual learning CLI subcommands (run, quantize, finetune)." \
    0 \
    "xInfer Forge CLI" \
    "forge-cli --help"