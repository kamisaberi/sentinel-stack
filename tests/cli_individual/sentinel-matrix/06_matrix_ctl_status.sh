#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_ctl_status"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "matrix_ctl.sh status" \
    "Verify cyber-range controller status banner and container table while 05_drinking_water_dosing_guard is live." \
    0 \
    "SENTINEL-MATRIX DIGITAL TWIN MESH" \
    "bash /home/kami/sentinel-matrix/tools/matrix_ctl.sh status"