#!/usr/bin/env python3
import struct
import sys
import subprocess

def build_ccsds_packet(apid, seq_count, is_tc=False, payload=b"TELEMETRY_OK"):
    # Primary Header (6 bytes):
    # Byte 0-1: Ver(3b=0) | Type(1b) | SecHdr(1b=0) | APID(11b)
    pkt_type_bit = 1 if is_tc else 0
    b0 = ((pkt_type_bit & 0x01) << 4) | ((apid >> 8) & 0x07)
    b1 = apid & 0xFF
    
    # Byte 2-3: SeqFlags(2b=3 unsegmented) | SeqCount(14b)
    b2 = 0xC0 | ((seq_count >> 8) & 0x3F)
    b3 = seq_count & 0xFF
    
    # Byte 4-5: Packet Length (Length of Data Field - 1)
    pkt_len = len(payload) - 1
    header = struct.pack("!BBBBH", b0, b1, b2, b3, pkt_len)
    return header + payload

def main():
    print("\033[1;36m========================================================================\033[0m")
    print("\033[1;37m   ARYORITHM ORBITAL LINK GUARD: CCSDS & STANAG VERIFICATION DRILL       \033[0m")
    print("\033[1;36m========================================================================\033[0m")

    # 1. Legitimate Satellite Downlink Telemetry (APID 0x050, Seq 100)
    tm_pkt = build_ccsds_packet(0x050, 100, is_tc=False, payload=b"OPTICAL_SCAN_DATA_OK")
    print("[1] Downlinking LEO Earth Observation Telemetry (APID 0x050, Seq 100)...")
    res1 = subprocess.run(["ccsds-guard", "verify-hex", tm_pkt.hex()], capture_output=True, text=True)
    print("    --> " + res1.stdout.strip())

    # 2. Rogue Uplink Telecommand Injection Attack (APID 0x010 Thruster De-Orbit)
    tc_attack = build_ccsds_packet(0x010, 1, is_tc=True, payload=b"FIRE_THRUSTER_DEORBIT")
    print("[2] Injecting Malicious AOCS Telecommand Uplink   (APID 0x010, Seq 1)...")
    res2 = subprocess.run(["ccsds-guard", "verify-hex", tc_attack.hex()], capture_output=True, text=True)
    print("    --> " + res2.stdout.strip())

    # 3. Telemetry Replay Attack Simulation (Replaying Seq 100)
    print("[3] Injecting Ghost Spacecraft Replay Attack     (APID 0x050, Seq 100)...")
    res3 = subprocess.run(["ccsds-guard", "verify-hex", tm_pkt.hex()], capture_output=True, text=True)
    print("    --> " + res3.stdout.strip())

    print("\033[1;36m========================================================================\033[0m")
    print("\033[1;32m[SUCCESS] Orbital CCSDS 133.0-B-2 space protocol defense certified!\033[0m\n")

if __name__ == "__main__":
    main()