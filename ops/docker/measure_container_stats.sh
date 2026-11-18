#!/usr/bin/env bash
# Single Duty: One-shot resource usage snapshot of all active containers
set -euo pipefail

docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.PIDs}}"
