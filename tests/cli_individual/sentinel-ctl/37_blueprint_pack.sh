#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_bp_pack"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/cache"
cd "$SANDBOX/work"
sentinel-ctl blueprint new sub_pack_01 --site WaterPlant-Pack >/dev/null

test_command_assert \
    "sentinel-ctl blueprint pack <dir> --embed" \
    "Pack a production site blueprint directory into a standalone .blueprint archive inside isolated cache." \
    0 \
    "Successfully packed blueprint" \
    "SENTINEL_CACHE_DIR=\"$SANDBOX/cache\" sentinel-ctl blueprint pack sub_pack_01 --embed && test -f \"$SANDBOX/cache/blueprints/blueprint_sub_pack_01.blueprint\""