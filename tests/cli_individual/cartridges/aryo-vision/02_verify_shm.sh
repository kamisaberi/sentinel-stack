#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_shm"

ensure_scenario_loaded "38_hipaa_patient_fall_eye"

test_command_assert \
    "aryo vision verify-shm" \
    "Verify HIPAA RAM-only zero-retention (VIS1) and frame freeze guard against live 38_hipaa_patient_fall_eye twin." \
    0 \
    "SHM|VIS1|HIPAA|FREEZE|PRIVACY|PASS|REJECT|DROP" \
    "aryo vision verify-shm"