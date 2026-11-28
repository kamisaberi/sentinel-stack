#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_gige"

ensure_scenario_loaded "37_conveyor_micro_defect_sorter"

test_command_assert \
    "aryo vision verify-gige" \
    "Verify GigE Vision GVCP (:3956) unauthorized register write-lock against live 37_conveyor_micro_defect_sorter twin." \
    0 \
    "GIGE|GVCP|REGISTER|WRITE|PASS|REJECT|DROP" \
    "aryo vision verify-gige"