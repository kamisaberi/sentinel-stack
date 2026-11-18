# 1. List all 20 scripts in ops/docker
ls -la /home/kami/sentinel-stack/ops/docker/

# 2. Inspect the live sentinel-grid-net topology and MAC addresses
/home/kami/sentinel-stack/ops/docker/inspect_network_topology.sh

# 3. Check eBPF capabilities on edge-01
/home/kami/sentinel-stack/ops/docker/check_container_capabilities.sh matrix-edge-substation-01

# 4. Measure one-shot stats across all running containers
/home/kami/sentinel-stack/ops/docker/measure_container_stats.sh

# 5. Check Nexus container health
/home/kami/sentinel-stack/ops/docker/inspect_container_health.sh matrix-nexus