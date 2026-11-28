#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_pkg_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl package list" \
    "List cached .spkg archives and active Tier A/B/C edge extensions in runtime." \
    0 \
    "ARYORITHM SENTINEL PACKAGES" \
    "sentinel-ctl package list"