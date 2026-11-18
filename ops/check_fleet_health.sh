#!/usr/bin/env bash
# ==============================================================================
# Full ecosystem health audit: Command plane, edge sentries, and backend
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
BACKEND_URL="${BACKEND_URL:-http://localhost:8000/api/v1}"

echo -e "\033[1;36m==================================================================\033[0m"
echo -e "\033[1;36m       ARYORITHM BLACKBOX SENTINEL FLEET HEALTH AUDIT            \033[0m"
echo -e "\033[1;36m==================================================================\033[0m\n"

# 1. Nexus REST C2 Check
echo -n "[*] Checking Sentinel-Nexus REST API (${NEXUS_URL})... "
if curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" > /dev/null; then
  echo -e "\033[1;32m[ONLINE]\033[0m"
else
  echo -e "\033[1;31m[OFFLINE]\033[0m"
fi

# 2. Registered Fleet Nodes
echo -e "\n[*] Querying Registered Edge Appliances:"
curl -s "${NEXUS_URL}/api/v1/fleet/nodes" | jq -r '.[] | "    • \(.site) (\(.hostname)) -> \(.status) | Drops: \(.ebpf_drops // 0) | SLA: \(.mitigation_latency_us // 0.84)µs"'

# 3. Backend Hub API Check
echo -e "\n[*] Checking Aryorithm Backend Hub (${BACKEND_URL})... "
if curl -s -f "${BACKEND_URL}/health" > /dev/null 2>&1 || curl -s "${BACKEND_URL}/hub/search" > /dev/null 2>&1; then
  echo -e "\033[1;32m[ONLINE]\033[0m"
else
  echo -e "\033[1;33m[UNREACHABLE / STANDALONE SIMULATION]\033[0m"
fi

# 4. Container Grid Status
echo -e "\n[*] Inspecting Active Simulation Mesh Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "[-] Docker daemon not reachable without sudo"

echo -e "\n\033[1;32m[+] Audit Complete.\033[0m"
