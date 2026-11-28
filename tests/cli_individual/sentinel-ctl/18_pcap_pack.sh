#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_pcap_pack"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"
printf '\xd4\xc3\xb2\xa1\x02\x00\x04\x00' > water_modbus_attack.pcap

test_command_assert \
    "sentinel-ctl pcap pack <file.pcap>" \
    "Generate Hub companion manifests with category, protocol, and attack metadata for a PCAP capture." \
    0 \
    "Successfully generated PCAP companion manifest" \
    "sentinel-ctl pcap pack water_modbus_attack.pcap --category SCADA_ICS --protocol MODBUS_TCP --attack EXPLOIT && test -f water_modbus_attack.pcap.manifest.json"