#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_bp_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl blueprint list" \
    "List cached .blueprint archives and active /etc/sentinel/model_routes.yaml runtime status." \
    0 \
    "PRODUCTION SITE BLUEPRINTS" \
    "sentinel-ctl blueprint list"