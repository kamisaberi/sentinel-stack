#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_slab_stream"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"
printf '0.1,0.2,0.3,0.4,0\n0.5,0.6,0.7,0.8,1\n' > stream_sample.csv
sentinel-artifact slab convert stream_sample.csv stream_sample.slab 4 >/dev/null

test_command_assert \
    "sentinel-ctl slab stream <file.slab> <port>" \
    "Stream zero-copy binary SLAB records over UDP loopback alongside live ICS twin." \
    0 \
    "Streamed .* records" \
    "sentinel-ctl slab stream stream_sample.slab 19999"