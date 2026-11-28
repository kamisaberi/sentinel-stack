#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_bp_from_scen"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/cache"
cd "$SANDBOX/work"

test_command_assert \
    "sentinel-ctl blueprint from-scenario 05_drinking_water_dosing_guard" \
    "Convert the live real-world 05_drinking_water_dosing_guard twin into a bare-metal production blueprint." \
    0 \
    "Scenario Twin successfully converted into Production Blueprint" \
    "SENTINEL_CACHE_DIR=\"$SANDBOX/cache\" sentinel-ctl blueprint from-scenario 05_drinking_water_dosing_guard --site WaterPlant-Live --interface ens160 --af-xdp ZEROCOPY && test -f bp_05_drinking_water_dosing_guard/blueprint.yaml"