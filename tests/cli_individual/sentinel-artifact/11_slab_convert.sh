#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_slab_conv"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

printf 'flow,pressure,ph,chlorine,label\n1.20,4.50,7.10,0.80,0\n9.90,9.80,12.50,8.40,1\n' > water_telemetry.csv

test_command_assert \
    "sentinel-artifact slab convert <csv> <out.slab> <dim>" \
    "Convert CSV sensor telemetry into Big-Endian 0x534C4142 zero-copy binary SLAB format + manifest.json." \
    0 \
    "Converted 2 records into SLAB binary dataset" \
    "sentinel-artifact slab convert water_telemetry.csv water_telemetry.slab 4 && test -f water_telemetry.slab && test -f water_telemetry.slab.manifest.json"