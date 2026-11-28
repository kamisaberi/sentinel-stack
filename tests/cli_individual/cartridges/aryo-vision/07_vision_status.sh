#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_status"

ensure_scenario_loaded "38_hipaa_patient_fall_eye"

test_command_assert \
    "aryo vision vision-status" \
    "Inspect running edge vision simulation containers while 38_hipaa_patient_fall_eye is active." \
    0 \
    "matrix|NAMES|Up|STATUS|38_hipaa" \
    "aryo vision vision-status"