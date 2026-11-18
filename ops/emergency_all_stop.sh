#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Stabilize physical plant & clear all perturbations fleet-wide
# Usage: ./emergency_all_stop.sh
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"

echo -e "\033[1;31m[!] ISSUING FLEET-WIDE EMERGENCY ALL-STOP...\033[0m"

# 1. Reset Lab simulation disturbances
curl -s -X POST "${NEXUS_URL}/api/v1/lab/inject" \
  -H "Content-Type: application/json" \
  -d '{"action":"reset"}' | jq .

# 2. Reset physical plant state to safe
curl -s -X POST "${NEXUS_URL}/api/v1/lab/inject" \
  -H "Content-Type: application/json" \
  -d '{"action":"safe"}' | jq .

echo -e "\033[1;32m[+] All physical chaos hooks purged. Fleet stabilized to nominal invariants.\033[0m"
