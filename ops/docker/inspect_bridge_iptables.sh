#!/usr/bin/env bash
# Single Duty: Inspect kernel iptables rules for Docker forwarding
set -euo pipefail

echo "[*] DOCKER FORWARD Rules:"
sudo iptables -S DOCKER 2>/dev/null || sudo iptables -L FORWARD -v -n
echo ""
echo "[*] DOCKER POSTROUTING / NAT Rules:"
sudo iptables -t nat -S DOCKER 2>/dev/null || sudo iptables -t nat -L POSTROUTING -v -n
