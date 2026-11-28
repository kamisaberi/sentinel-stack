#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_trism_pol"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
printf 'require_human_approval: true\nblocked_tools:\n  - write_single_coil\n' > "$SANDBOX/work/trism_policy.yaml"

test_command_assert \
    "sentinel-ctl trism policy show <policy.yaml>" \
    "Display active industrial AI TRiSM tool-calling governance policy from disk." \
    0 \
    "require_human_approval: true" \
    "sentinel-ctl trism policy show \"$SANDBOX/work/trism_policy.yaml\""