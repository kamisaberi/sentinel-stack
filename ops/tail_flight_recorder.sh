#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Continuously stream Sentinel-Lab scientific flight recorder
# Usage: ./tail_flight_recorder.sh [poll_interval_sec]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
INTERVAL="${1:-1.0}"
LAST_LOG=""

echo -e "\033[1;36m[*] Streaming Sentinel-Lab Flight Recorder (Ctrl+C to stop)...\033[0m\n"

while true; do
  LOGS=$(curl -s "${NEXUS_URL}/api/v1/lab/logs" | jq -r '.logs // empty' 2>/dev/null || true)
  if [ -n "$LOGS" ] && [ "$LOGS" != "$LAST_LOG" ]; then
    clear
    echo -e "\033[1;36m=== SCIENTIFIC FLIGHT RECORDER (UPDATED $(date +%T)) ===\033[0m"
    echo "$LOGS"
    LAST_LOG="$LOGS"
  fi
  sleep "$INTERVAL"
done
