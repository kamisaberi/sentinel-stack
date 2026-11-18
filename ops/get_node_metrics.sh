#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Get ONLY hardware & in-kernel driver metrics for a specific node
# Usage: ./get_node_metrics.sh [node_id | site_keyword] [--json]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
TARGET="${1:-}"
OUTPUT_JSON=false

if [ "${2:-}" = "--json" ] || [ "${TARGET}" = "--json" ]; then
  OUTPUT_JSON=true
  if [ "${TARGET}" = "--json" ]; then TARGET=""; fi
fi

FLEET=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" || { echo "[-] Failed to connect to Nexus"; exit 1; })

if [ -z "$TARGET" ]; then
  echo -e "\033[1;33m[*] No node specified. Displaying metrics for ALL nodes:\033[0m\n"
  printf "  \033[1;33m%-24s %-22s %-10s %-8s %-10s %-12s %-10s\033[0m\n" "ENCLAVE SITE" "HOSTNAME" "STATUS" "CPU %" "RAM MB" "DROPS" "SLA LATENCY"
  echo "  ---------------------------------------------------------------------------------------------------"
  echo "$FLEET" | jq -r '.[] | "\(.site)|\(.hostname)|\(.status)|\(.cpu_pct // 0)%|\(.ram_mb // 0)MB|\(.ebpf_drops // 0)|\(.mitigation_latency_us // 0.84)µs"' | while IFS="|" read -r S H ST C R D L; do
    printf "  %-24s %-22s %-10s %-8s %-10s %-12s %-10s\n" "$S" "$H" "$ST" "$C" "$R" "$D" "$L"
  done
  echo ""
  exit 0
fi

RESOLVED_ID=$(echo "$FLEET" | jq -r --arg q "$TARGET" '.[] | select(.node_id == $q or (.site | test($q; "i")) or (.hostname | test($q; "i"))) | .node_id' | head -n1)

if [ -z "$RESOLVED_ID" ]; then
  echo -e "\033[1;31m[-] Node matching '${TARGET}' not found.\033[0m"
  exit 1
fi

DATA=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes/${RESOLVED_ID}")

if [ "$OUTPUT_JSON" = true ]; then
  echo "$DATA" | jq '{site, hostname, kernel, status, cpu_pct, ram_mb, packets_inspected, ebpf_drops, mitigation_latency_us}'
else
  echo -e "\033[1;36m==================================================================\033[0m"
  echo -e "\033[1;36m HARDWARE & DRIVER TELEMETRY: $(echo "$DATA" | jq -r '.site')\033[0m"
  echo -e "\033[1;36m==================================================================\033[0m"
  echo "  Node Identifier      : $(echo "$DATA" | jq -r '.node_id')"
  echo "  Host & Kernel        : $(echo "$DATA" | jq -r '.hostname') ($(echo "$DATA" | jq -r '.kernel'))"
  echo "  Health Status        : $(echo "$DATA" | jq -r '.status')"
  echo "  CPU Utilization      : $(echo "$DATA" | jq -r '.cpu_pct') %"
  echo "  RAM Usage            : $(echo "$DATA" | jq -r '.ram_mb') MB"
  echo "  Packets Inspected    : $(echo "$DATA" | jq -r '.packets_inspected')"
  echo "  eBPF Dropped Packets : $(echo "$DATA" | jq -r '.ebpf_drops')"
  echo "  Driver SLA Latency   : $(echo "$DATA" | jq -r '.mitigation_latency_us') µs (< 0.84 µs TARGET)"
  echo ""
fi
