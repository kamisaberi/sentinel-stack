#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_s7"

test_command \
    "aryo ics verify-s7" \
    "Validate Siemens S7Comm unauthorized CPU STOP (0x29) interception." \
    0 \
    "aryo ics verify-s7"