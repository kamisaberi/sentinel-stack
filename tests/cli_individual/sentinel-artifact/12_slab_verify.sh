#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_slab_ver"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

printf '0.1,0.2,0.3,0.4,0\n0.9,0.8,0.7,0.6,1\n' > water_telemetry.csv
sentinel-artifact slab convert water_telemetry.csv water_telemetry.slab 4 >/dev/null

test_command_assert \
    "sentinel-artifact slab verify <file.slab>" \
    "Verify 0x534C4142 magic header, record count, and 4D tensor geometry of a binary SLAB dataset." \
    0 \
    "VERIFIED.*SLAB binary dataset is VALID" \
    "sentinel-artifact slab verify water_telemetry.slab"