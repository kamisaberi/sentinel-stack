#!/usr/bin/env bash
# Single Duty: List all container names with their assigned IP addresses
set -euo pipefail

printf "%-32s %-20s %s\n" "CONTAINER NAME" "IP ADDRESS" "NETWORK"
echo "----------------------------------------------------------------------"
docker ps --format '{{.Names}}' | while read -r name; do
    ip=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}} ({{$k}}) {{end}}' "$name")
    printf "%-32s %s\n" "$name" "$ip"
done
