#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_whoami"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl whoami" \
    "Inspect currently authenticated Registry Hub identity, API token prefix, and enrolled author public key." \
    0 \
    "AUTHENTICATED REGISTRY IDENTITY" \
    "sentinel-ctl whoami"