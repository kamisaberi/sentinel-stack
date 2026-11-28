#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_scen_updown"

cleanup_aryo_scen() {
    aryo scenario down 05_drinking_water_dosing_guard >/dev/null 2>&1 || true
    cleanup_all
}
trap cleanup_aryo_scen EXIT

test_command_assert \
    "aryo scenario up && aryo scenario down" \
    "Boot and cleanly dismantle 05_drinking_water_dosing_guard end-to-end via the aryo umbrella CLI." \
    0 \
    "dismantled successfully" \
    "aryo scenario up 05_drinking_water_dosing_guard && aryo scenario down 05_drinking_water_dosing_guard"