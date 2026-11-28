#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_grid_status"

test_command \
    "aryo ics grid-status" \
    "Inspect running Production Master Grid digital twin containers (10.240.0.0/24)." \
    0 \
    "aryo ics grid-status"