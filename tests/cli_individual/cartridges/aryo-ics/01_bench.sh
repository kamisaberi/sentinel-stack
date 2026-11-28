#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
init_sandbox "ics_bench"

test_command \
    "aryo ics bench" \
    "Execute the 100,000-sample deterministic hardware latency benchmark (< 120 ns SLA)." \
    0 \
    "aryo ics bench"