#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_iec104"

test_command \
    "aryo ics verify-iec104" \
    "Validate IEC 60870-5-104 unauthorized breaker trip (COT=6) interception." \
    0 \
    "aryo ics verify-iec104"