#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_desc"

test_command \
    "aryo-ics --plugin-desc" \
    "Emit single-line plugin metadata consumed by aryo dynamic extension discovery." \
    0 \
    "aryo-ics --plugin-desc"