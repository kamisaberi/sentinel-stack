#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_down"

python3 /home/kami/sentinel-matrix/tools/scenario_engine.py load 05_drinking_water_dosing_guard >/dev/null 2>&1

test_command_assert \
    "scenario_engine.py down --name 05_drinking_water_dosing_guard" \
    "Dismantle active scenario containers, remove Docker networks, and purge temporary SSFS workspace." \
    0 \
    "dismantled successfully" \
    "python3 /home/kami/sentinel-matrix/tools/scenario_engine.py down --name 05_drinking_water_dosing_guard"