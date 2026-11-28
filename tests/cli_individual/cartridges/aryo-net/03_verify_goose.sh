#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_goose"

ensure_scenario_loaded "01_substation_busbar_trip"

test_command_assert \
    "aryo net verify-goose" \
    "Verify Non-IP L2 IEC 61850 GOOSE (0x88B8) stNum anti-spoof gate against live 01_substation_busbar_trip twin." \
    0 \
    "GOOSE|0x88B8|stNum|PASS|REJECT|DROP" \
    "aryo net verify-goose"