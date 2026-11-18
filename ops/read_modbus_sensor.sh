#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Read IEEE 754 Float32 holding register from Modbus TCP sensor
# Usage: ./read_modbus_sensor.sh [port] [host]
# Example: ./read_modbus_sensor.sh 15501 127.0.0.1
# ==============================================================================
set -euo pipefail

PORT="${1:-15501}"
HOST="${2:-127.0.0.1}"

echo -e "\033[1;36m[*] Querying Modbus TCP holding registers on ${HOST}:${PORT}...\033[0m"

python3 -c "
import socket, struct, sys

host = '${HOST}'
port = int('${PORT}')

try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2.0)
    s.connect((host, port))

    # Modbus TCP Read Holding Registers (FC03, Reg 40001, count 2 = 4 bytes float)
    req = struct.pack('>HHHBBHH', 1, 0, 6, 1, 3, 0, 2)
    s.sendall(req)
    resp = s.recv(1024)
    s.close()

    if len(resp) >= 13:
        b1, b2 = struct.unpack('>HH', resp[9:13])
        float_val = struct.unpack('>f', struct.pack('>HH', b1, b2))[0]
        print(f'\033[1;32m[+] Raw Register 40001: 0x{b1:04X} 0x{b2:04X}\033[0m')
        print(f'\033[1;36m[+] Decoded IEEE 754 Float32 Value: {float_val:.4f}\033[0m')
    else:
        print(f'[-] Invalid Modbus response length ({len(resp)} bytes)')
except Exception as e:
    print(f'[-] Modbus query failed: {e}')
"
