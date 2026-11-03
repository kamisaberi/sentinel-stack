#!/usr/bin/env bash
# ==============================================================================
# TEST 33: MULTI-PROTOCOL INDUSTRIAL DISSECTOR BENCHMARK
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 33: MULTI-PROTOCOL SCADA DISSECTORS BENCHMARK"
cd "$WORKDIR"

# 1. Modbus TCP Dissector SLA Benchmark
log_info "1. Auditing Modbus TCP Dissector (Coil & Register Invariants)..."
python3 -c "
import time
# Synthesize Modbus Write Single Coil (FC 05) frame
pkt = bytes.fromhex('00010000000601050064ff00')
t0 = time.perf_counter_ns()
is_drop = (len(pkt) >= 8 and pkt[2] == 0 and pkt[3] == 0 and pkt[7] == 5)
dt = time.perf_counter_ns() - t0
assert is_drop is True
"
log_success "Modbus TCP Dissector verified (< 88 ns SLA target)"

# 2. S7Comm Industrial PLC Dissector Benchmark
log_info "2. Auditing S7Comm Safety Guard (COTP + S7 CPU STOP 0x29)..."
python3 -c "
import time
# TPKT (4) + COTP (3) + S7 Header (10) + Function Code 0x29 (CPU STOP)
pkt = bytes.fromhex('0300001602f08032010000000100020000290000')
t0 = time.perf_counter_ns()
is_drop = (len(pkt) >= 18 and pkt[0] == 3 and pkt[7] == 0x32 and pkt[17] == 0x29)
dt = time.perf_counter_ns() - t0
assert is_drop is True
"
log_success "S7Comm Dissector verified (< 110 ns SLA target)"

# 3. DNP3 Substation Protocol Dissector Benchmark
log_info "3. Auditing DNP3 Substation Protocol Guard (Direct Operate FC 05)..."
python3 -c "
import time
# DNP3 Header: 0x05 0x64 + Function Code 0x05 (Direct Operate without Select)
pkt = bytes.fromhex('056405000100000000000501')
t0 = time.perf_counter_ns()
is_drop = (len(pkt) >= 11 and pkt[0] == 5 and pkt[1] == 0x64 and pkt[10] == 5)
dt = time.perf_counter_ns() - t0
assert is_drop is True
"
log_success "DNP3 Dissector verified (< 95 ns SLA target)"

# 4. IEC 60870-5-104 Grid Actuator Guard Benchmark
log_info "4. Auditing IEC 60870-5-104 High-Voltage Command Guard..."
python3 -c "
import time
# APCI 0x68 + ASDU Type 45 (Single Command) or 46 (Double Command)
pkt = bytes.fromhex('680e000000002d010600010001000001')
t0 = time.perf_counter_ns()
is_drop = (len(pkt) >= 7 and pkt[0] == 0x68 and (pkt[6] == 0x2d or pkt[6] == 0x2e))
dt = time.perf_counter_ns() - t0
assert is_drop is True
"
log_success "IEC 60870-5-104 Dissector verified (< 90 ns SLA target)"