#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_vaccine"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

printf '{"protocol":"MODBUS","client_ip":"10.240.105.99","function_code":5,"payload_hex":"00010000000601050001ff00","reason":"Unauthorized Chlorine Dosing Coil Write"}\n' > exploit_1700000005.json

test_command_assert \
    "sentinel-artifact synthesize-vaccine <exploit.json> <out_dir>" \
    "Synthesize LuaJIT reflex rule, Ed25519-sign .spkg vaccine, and pass pre-flight test from live Modbus exploit JSON." \
    0 \
    "VACCINE SYNTHESIS COMPLETE" \
    "sentinel-artifact synthesize-vaccine exploit_1700000005.json \"$SANDBOX/work/vaccines\""