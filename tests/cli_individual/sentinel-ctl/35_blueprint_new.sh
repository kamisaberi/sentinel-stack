#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_bp_new"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

test_command_assert \
    "sentinel-ctl blueprint new <name> --site <s>" \
    "Scaffold a physical edge hardware blueprint (blueprint.yaml, model_routes.yaml, deploy.sh) inside sandbox." \
    0 \
    "Successfully scaffolded production blueprint" \
    "sentinel-ctl blueprint new sub_water_01 --site WaterPlant-North-01 && test -f sub_water_01/blueprint.yaml && test -f sub_water_01/model_routes.yaml"