#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_grid_down"

aryo ics grid-up >/dev/null 2>&1 || true

test_command_assert \
    "aryo ics grid-down" \
    "Cleanly dismantle the Production Master Grid digital twin mesh and release all subnets." \
    0 \
    "Removed|dismantled|down|Stopped|Teardown|matrix|OK" \
    "aryo ics grid-down"