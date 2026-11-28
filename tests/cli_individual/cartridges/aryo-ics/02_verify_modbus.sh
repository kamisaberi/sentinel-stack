#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_modbus"

test_command \
    "aryo ics verify-modbus" \
    "Validate deterministic Modbus TCP read/write safety gate enforcement." \
    0 \
    "aryo ics verify-modbus"