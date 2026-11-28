#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_airgap"

test_command \
    "aryo ics airgap-status" \
    "Inspect real-time ICS actuator tripwire latch state." \
    0 \
    "aryo ics airgap-status"