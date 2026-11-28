#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "comp_nexus"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "nexus-ctl report cmmc" \
    "Verify CMMC 2.0 / NIST SP 800-171 compliance audit output alongside live matrix-nexus container." \
    0 \
    "CMMC|NIST|COMPLIANT|AUDIT|PASS|STATUS" \
    "nexus-ctl report cmmc"