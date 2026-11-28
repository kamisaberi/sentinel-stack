#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_bp_inspect"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"
sentinel-ctl blueprint new sub_inspect_01 --site WaterPlant-Inspect >/dev/null

test_command_assert \
    "sentinel-ctl blueprint inspect <dir>" \
    "Display hardware NIC bindings, AF_XDP mode, RSS queues, and compliance manifest of a blueprint." \
    0 \
    "INSPECTING PRODUCTION BLUEPRINT" \
    "sentinel-ctl blueprint inspect sub_inspect_01"