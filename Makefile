SHELL := /bin/bash
.PHONY: help install verify clean status update

help:
	@echo "=========================================================================="
	@echo "  SENTINEL-STACK: AUTOMATED MASTER BUILD & DEPLOYMENT SYSTEM"
	@echo "=========================================================================="
	@echo "  sudo make install  - Full automated install, compilation & verification"
	@echo "  sudo make verify   - Run post-installation health check across all tiers"
	@echo "  sudo make update   - Pull latest git repositories and recompile all"
	@echo "  sudo make status   - Check status of background Sentinel & Nexus daemons"
	@echo "  sudo make clean    - Purge build artifacts, object files, and temp caches"
	@echo "=========================================================================="

install:
	@bash install.sh

verify:
	@bash scripts/05_verify_installation.sh

update:
	@bash scripts/02_clone_repositories.sh
	@bash scripts/03_build_all_tiers.sh
	@bash scripts/05_verify_installation.sh

status:
	@echo "=== Sentinel Nexus Status ==="
	@systemctl status sentinel-nexus --no-pager || true
	@echo "\n=== Blackbox Sentinel Status ==="
	@systemctl status blackbox-sentinel --no-pager || true

clean:
	@echo "[*] Cleaning build artifacts across all repositories..."
	@rm -rf src/*/build src/*/dist src/*/build_src
	@echo "[+] Build trees cleaned."