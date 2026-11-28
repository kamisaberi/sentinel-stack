#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_pcap_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl pcap list" \
    "Enumerate locally cached and staged certified malware/OT PCAP captures." \
    0 \
    "LOCAL ASSET REPOSITORY: pcaps" \
    "sentinel-ctl pcap list"