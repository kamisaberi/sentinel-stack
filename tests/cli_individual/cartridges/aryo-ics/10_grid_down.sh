#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_grid_down"

if [[ "${1:-}" != "--live" ]]; then
    skip_command \
        "aryo ics grid-down" \
        "Teardown the Production Master Grid Docker simulation mesh." \
        "Pass --live to dismantle live Docker containers."
    exit 0
fi

test_command \
    "aryo ics grid-down" \
    "Teardown the Production Master Grid Docker simulation mesh." \
    0 \
    "aryo ics grid-down"