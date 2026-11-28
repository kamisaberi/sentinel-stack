#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_load"

cleanup_matrix_load() {
    if [[ "$KEEP_UP" -eq 0 ]]; then
        python3 /home/kami/sentinel-matrix/tools/scenario_engine.py down --name 05_drinking_water_dosing_guard >/dev/null 2>&1 || true
    fi
    cleanup_all
}
trap cleanup_matrix_load EXIT

test_command_assert \
    "scenario_engine.py load 05_drinking_water_dosing_guard" \
    "Compile SSFS scenario.yaml + pack:// URIs into isolated Docker Compose workspace and launch live 9-container twin." \
    0 \
    "is LIVE across custom networks" \
    "python3 /home/kami/sentinel-matrix/tools/scenario_engine.py load 05_drinking_water_dosing_guard"