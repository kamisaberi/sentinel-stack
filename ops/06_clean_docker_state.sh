#!/usr/bin/env bash
# ==============================================================================
# 06_clean_docker_state.sh — Resets lingering containers, subnets, and shims
# ==============================================================================
set -euo pipefail

CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${RED}================================================================================${RESET}"
echo -e "${RED}         EMERGENCY DOCKER & CONTAINER STATE SANITIZER                           ${RESET}"
echo -e "${RED}================================================================================${RESET}"

echo -e "${YELLOW}[*] Step 1: Stopping all matrix and simulation containers...${RESET}"
docker stop $(docker ps -aq --filter "name=matrix-") 2>/dev/null || true

echo -e "${YELLOW}[*] Step 2: Removing stopped containers...${RESET}"
docker rm $(docker ps -aq --filter "name=matrix-") 2>/dev/null || true

echo -e "${YELLOW}[*] Step 3: Pruning dangling Docker bridge networks...${RESET}"
docker network prune -f

echo -e "${YELLOW}[*] Step 4: Releasing all reserved scenario ports...${RESET}"
sudo fuser -k 9443/tcp 9444/tcp 50051/tcp 15501/tcp 15502/tcp 8554/tcp 8889/tcp \
             50050/udp 50051/udp 50052/udp 18090/tcp 2368/udp 2>/dev/null || true

echo -e "${YELLOW}[*] Step 5: Auditing free IP address pools...${RESET}"
docker network inspect $(docker network ls -q) --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null | grep -E "10.240" || \
    echo -e "${GREEN}[+] Both 10.240.0.0/24 and 10.240.52.0/24 pools are 100% FREE.${RESET}"

echo -e "${GREEN}[+] Docker state completely sanitized and ready for fresh scenario launch.${RESET}"
