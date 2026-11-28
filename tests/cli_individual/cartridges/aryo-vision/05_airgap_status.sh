#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_airgap"

ensure_scenario_loaded "38_hipaa_patient_fall_eye"

test_command_assert \
    "aryo vision airgap-status" \
    "Inspect real-time HIPAA privacy air-gap latch state while 38_hipaa_patient_fall_eye is active." \
    0 \
    "AIRGAP|PRIVACY|LATCH|ARMED|Tripped|NO|STATUS|PASS" \
    "aryo vision airgap-status"