#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_bench"

ensure_scenario_loaded "38_hipaa_patient_fall_eye"

test_command_assert \
    "aryo vision bench" \
    "Run 100,000-sample ShmVision frame verification benchmark (< 120 ns SLA) alongside live 38_hipaa_patient_fall_eye twin." \
    0 \
    "ns|latency|PASS|mean" \
    "aryo vision bench"