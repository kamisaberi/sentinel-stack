#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_desc"

ensure_scenario_loaded "38_hipaa_patient_fall_eye"

test_command_assert \
    "aryo-vision --plugin-desc" \
    "Verify dynamic plugin discovery metadata string emitted by aryo-vision alongside live HIPAA vision twin." \
    0 \
    "vision|RTSP|GigE|HIPAA|Privacy" \
    "aryo-vision --plugin-desc"