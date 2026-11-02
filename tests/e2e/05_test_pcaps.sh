#!/usr/bin/env bash
# ==============================================================================
# TEST 05: CERTIFIED MALWARE PCAP VAULT (DYNAMIC SLUG & METHOD 2 VISIBILITY)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

PCAP_SLUG="pcap_${RUN_TAG:-$(date +%s)}"

log_header "TEST 05: MALWARE PCAP VAULT [Slug: $PCAP_SLUG]"
cd "$WORKDIR"

# 1. Synthesize Microsecond PCAP Binary Capture
log_info "1. Synthesizing valid microsecond PCAP binary capture..."
python3 -c "
import struct
# PCAP Global Header (24 bytes)
gh = struct.pack('<IHHiIII', 0xa1b2c3d4, 2, 4, 0, 0, 65535, 1)
# Ethernet (14) + IPv4 (20) + TCP (20) + Modbus Write Single Coil (8)
pkt = bytes.fromhex(
    '000c291a2b3c005056c000080800'
    '450000340001000040067cc20a0000010a000002'
    'c00101f600000001000000005002200000000000'
    '00010000000601050064ff00'
)
# Packet Header (16 bytes)
ph = struct.pack('<IIII', 1700000000, 12345, len(pkt), len(pkt))
with open('${PCAP_SLUG}.pcap', 'wb') as f:
    f.write(gh + ph + pkt)
"
PCAP_FILE="$WORKDIR/${PCAP_SLUG}.pcap"
assert_file_exists "$PCAP_FILE"

# 2. Pack PCAP Capture & Generate Companion Manifest
log_info "2. Packing PCAP capture & generating companion manifest..."
aryo pcap pack "$PCAP_FILE" --category SCADA_ICS --protocol MODBUS_TCP --attack EXPLOIT >> "$LOG_FILE" 2>&1

# 3. Publish PCAP to Hub
log_info "3. Publishing unique PCAP ($PCAP_SLUG) to Hub ($SENTINEL_HUB_URL)..."
if ! aryo publish "$PCAP_FILE" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] PCAP publish failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "PCAP published to Hub (HTTP 201 Created)"

# 3b. Method 2: Promote Visibility to Public
log_info "3b. Promoting PCAP visibility to 'public' via Method 2..."
if ! aryo hub visibility pcap "$PCAP_SLUG" public >> "$LOG_FILE" 2>&1; then
    echo -e "${RED}[ERROR] PCAP visibility promotion failed. Recent log output:${RESET}"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
log_success "PCAP visibility updated to 'public'"

# 4. Pull and Stage PCAP into /etc/sentinel/pcaps/
log_info "4. Pulling certified capture into /etc/sentinel/pcaps/..."
aryo pcap pull "$PCAP_SLUG" >> "$LOG_FILE" 2>&1
aryo pcap list >> "$LOG_FILE" 2>&1

assert_file_exists "/etc/sentinel/pcaps/${PCAP_SLUG}.pcap"
log_success "PCAP staged to /etc/sentinel/pcaps/${PCAP_SLUG}.pcap"