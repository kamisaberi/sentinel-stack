#!/usr/bin/env bash
# ==============================================================================
# TEST 05: CERTIFIED MALWARE PCAP VAULT
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 05: MALWARE PCAP VAULT"
cd "$WORKDIR"

log_info "1. Synthesizing valid microsecond PCAP binary capture..."
python3 -c '
import struct
# PCAP Global Header (24 bytes)
gh = struct.pack("<IHHiIII", 0xa1b2c3d4, 2, 4, 0, 0, 65535, 1)
# Ethernet (14) + IPv4 (20) + TCP (20) + Modbus Write Single Coil (8)
pkt = bytes.fromhex(
    "000c291a2b3c005056c000080800"
    "450000340001000040067cc20a0000010a000002"
    "c00101f600000001000000005002200000000000"
    "00010000000601050064ff00"
)
# Packet Header (16 bytes)
ph = struct.pack("<IIII", 1700000000, 12345, len(pkt), len(pkt))
with open("modbus_unauthorized_coil_write.pcap", "wb") as f:
    f.write(gh + ph + pkt)
'
PCAP_FILE="$WORKDIR/modbus_unauthorized_coil_write.pcap"
assert_file_exists "$PCAP_FILE"

log_info "2. Packing PCAP capture & generating companion manifest..."
aryo pcap pack "$PCAP_FILE" --category SCADA_ICS --protocol MODBUS_TCP --attack EXPLOIT >> "$LOG_FILE" 2>&1

log_info "3. Publishing PCAP to Hub..."
aryo publish "$PCAP_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1
log_success "PCAP published to Hub"

log_info "4. Pulling certified capture into /etc/sentinel/pcaps/..."
sudo aryo pcap pull modbus_unauthorized_coil_write >> "$LOG_FILE" 2>&1
aryo pcap list >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/pcaps/modbus_unauthorized_coil_write.pcap"
log_success "PCAP staged to /etc/sentinel/pcaps/"