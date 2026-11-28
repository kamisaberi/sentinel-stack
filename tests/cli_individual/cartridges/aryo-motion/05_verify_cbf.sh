#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_cbf"

ensure_scenario_loaded "30_surgical_boundary_motion_clamp"

test_command_assert \
    "aryo motion verify-cbf" \
    "Verify Nagumo CBF forward invariance safety barrier against live 30_surgical_boundary_motion_clamp twin." \
    0 \
    "CBF|Nagumo|CLAMP|BARRIER|PASS|REJECT|SAFE" \
    "aryo motion verify-cbf"