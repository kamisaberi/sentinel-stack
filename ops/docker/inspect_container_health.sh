#!/usr/bin/env bash
# Single Duty: Inspect container healthcheck status and logs
# Usage: ./inspect_container_health.sh [container_name]
set -euo pipefail

CONTAINER="${1:-matrix-nexus}"
echo "[*] Inspecting health status for: ${CONTAINER}..."

docker inspect "$CONTAINER" | jq '{
  Status: .[0].State.Health.Status,
  FailingStreak: .[0].State.Health.FailingStreak,
  RecentLog: .[0].State.Health.Log[-1]
}'
