#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_pcap_pack"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
printf '\xd4\xc3\xb2\xa1\x02\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\x00\x00\x01\x00\x00\x00' > water_capture.pcap
printf '{"name":"water_capture","asset_type":"pcap","protocol":"MODBUS_TCP"}\n' > water_manifest.json

test_command_assert \
    "sentinel-artifact pcap pack <key> <manifest> <in.pcap> <out.spcap>" \
    "Sign and seal a raw PCAP capture and manifest into a tamper-evident .spcap container (SPKGPAP)." \
    0 \
    "Certified and sealed PCAP capture" \
    "sentinel-artifact pcap pack \"$SANDBOX/work/dev_private.pem\" water_manifest.json water_capture.pcap water_sealed.spcap && test -f water_sealed.spcap"