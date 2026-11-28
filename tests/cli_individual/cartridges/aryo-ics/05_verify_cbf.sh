#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_cbf"

test_command \
    "aryo ics verify-cbf" \
    "Verify Nagumo Control Barrier Function (CBF) thermal safety forward invariance gate." \
    0 \
    "aryo ics verify-cbf"