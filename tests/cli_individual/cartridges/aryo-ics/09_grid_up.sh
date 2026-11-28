#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_grid_up"

if [[ "${1:-}" != "--live" ]]; then
    skip_command \
        "aryo ics grid-up" \
        "Deploy the Production Master Grid Docker simulation mesh." \
        "Pass --live to launch live Docker containers."
    exit 0
fi

test_command \
    "aryo ics grid-up" \
    "Deploy the Production Master Grid Docker simulation mesh." \
    0 \
    "aryo ics grid-up"