#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_pqc"

ensure_scenario_loaded "26_pqc_tls_accelerator"

test_command_assert \
    "aryo net verify-pqc" \
    "Verify NIST FIPS 203 TLS 1.3 ML-KEM post-quantum enforcement against live 26_pqc_tls_accelerator twin." \
    0 \
    "PQC|ML-KEM|KEM|TLS|PASS|REJECT|OK" \
    "aryo net verify-pqc"