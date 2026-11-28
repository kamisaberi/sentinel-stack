#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_scen_pack"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/ssfs" "$SANDBOX/cache"
SENTINEL_ROOT="$SANDBOX/ssfs" sentinel-ctl scenario new water_pack_twin --sector WATER_UTILITY >/dev/null

test_command_assert \
    "sentinel-ctl scenario pack <slug>" \
    "Pack a scenario directory into a declarative Hub-optimized .tar.gz bundle inside isolated cache." \
    0 \
    "Successfully packed scenario bundle" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" SENTINEL_CACHE_DIR=\"$SANDBOX/cache\" sentinel-ctl scenario pack water_pack_twin && test -f \"$SANDBOX/cache/scenarios/scenario_water_pack_twin.tar.gz\""