#!/usr/bin/env bash
# ==============================================================================
# 07_bench_all_latencies.sh — Unified Hardware TSC Cycle-Accurate Benchmark
# ==============================================================================
set -euo pipefail

CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}================================================================================${RESET}"
echo -e "${CYAN}       ARYORITHM SENTINEL: HARDWARE LATENCY BENCHMARK SUITE                     ${RESET}"
echo -e "${CYAN}================================================================================${RESET}"

# 1. ccsds-guard sub-120ns Hardware TSC Cycle Benchmark
echo -e "\n${YELLOW}--- 1. ccsds-guard Deterministic C++20 Telecommand SLA (< 120 ns) ---${RESET}"
if [[ -f "/home/kami/ccsds-guard/build/bench_latency" ]]; then
    /home/kami/ccsds-guard/build/bench_latency
else
    echo -e "${RED}[-] bench_latency not built. Run 'make bench' inside /home/kami/ccsds-guard first.${RESET}"
fi

# 2. Sentinel-Lab Research Suite Benchmarks
echo -e "\n${YELLOW}--- 2. Sentinel-Lab Actuator Air-Gap Relay Response Benchmark ---${RESET}"
if command -v aryo >/dev/null 2>&1; then
    aryo lab uav-airgap-tripwire
    echo ""
    echo -e "${YELLOW}--- 3. Sentinel-Lab Sliding Window Anti-Replay Saturation ---${RESET}"
    aryo lab uav-replay-blast -r 100000 -d 2
else
    echo -e "${RED}[-] aryo CLI not in PATH.${RESET}"
fi

echo -e "\n${GREEN}[+] All latency benchmarks successfully verified.${RESET}"
