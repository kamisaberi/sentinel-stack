#!/usr/bin/env bash
# ==============================================================================
# 03_switch_scenarios.sh — Swaps cleanly between Master Grid and Swarm Combat Grid
# ==============================================================================
set -euo pipefail

TARGET="${1:-help}"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

function purge_all() {
    echo -e "${YELLOW}[*] Tearing down running matrix containers...${RESET}"
    docker stop $(docker ps -q --filter "name=matrix-") 2>/dev/null || true
    docker rm $(docker ps -aq --filter "name=matrix-") 2>/dev/null || true
    echo -e "${YELLOW}[*] Pruning dangling Docker bridge networks...${RESET}"
    docker network prune -f >/dev/null 2>&1 || true
    echo -e "${YELLOW}[*] Releasing simulation ports (9443, 50051, 15501-2, 50050-2)...${RESET}"
    sudo fuser -k 9443/tcp 9444/tcp 50051/tcp 15501/tcp 15502/tcp 8554/tcp 8889/tcp 50050/udp 50051/udp 50052/udp 2>/dev/null || true
    echo -e "${GREEN}[+] Port allocation clean.${RESET}"
}

case "${TARGET}" in
    master|production|grid)
        echo -e "${CYAN}[+] Switching to Production Master Grid (13 Containers, 10.240.0.0/24)...${RESET}"
        purge_all
        cd /home/kami/sentinel-matrix
        python3 tools/scenario_engine.py load scenarios/production_master_grid
        echo -e "${GREEN}[+] Master Grid is LIVE at http://localhost:9443/${RESET}"
        ;;
    swarm|uav|combat)
        echo -e "${CYAN}[+] Switching to Tactical UAV Swarm Combat Grid (16 Containers, 10.240.52.0/24)...${RESET}"
        purge_all
        cd /home/kami/ccsds-guard
        aryo aerospace sim-combat-grid
        echo -e "${GREEN}[+] UAV Combat Grid is LIVE at http://localhost:9443/${RESET}"
        ;;
    down|stop|purge)
        purge_all
        echo -e "${GREEN}[+] All scenarios dismantled.${RESET}"
        ;;
    *)
        echo -e "Usage: $0 {master|swarm|down}"
        echo -e "  master : Launches 13-container production_master_grid (Substation, Hospital, Refinery)"
        echo -e "  swarm  : Launches 16-container tactical_uav_swarm_combat_grid (Alpha, Bravo, Charlie)"
        echo -e "  down   : Shuts down all containers and scrubs networks/ports"
        exit 1
        ;;
esac
