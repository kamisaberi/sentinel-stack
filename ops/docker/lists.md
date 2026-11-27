# 1. Get ONLY the attack list for Substation
/home/kami/sentinel-stack/ops/get_node_attacks.sh substation

# 2. Get ONLY the attack list for Refinery in JSON format
/home/kami/sentinel-stack/ops/get_node_attacks.sh refinery --json

# 3. Get ONLY the connected sensor channels for Hospital
/home/kami/sentinel-stack/ops/get_node_sensors.sh hospital

# 4. Get ONLY hardware & in-kernel metrics across all nodes
/home/kami/sentinel-stack/ops/get_node_metrics.sh

# 5. Get ONLY the primary physical instrument for Substation
/home/kami/sentinel-stack/ops/get_node_instrument.sh substation

# 6. Get ONLY the formal mathematical invariants for Refinery
/home/kami/sentinel-stack/ops/get_node_invariants.sh refinery

# 1. Query raw Modbus TCP holding registers from the Power Meter
/home/kami/sentinel-stack/ops/read_modbus_sensor.sh 15501 127.0.0.1

# 2. Inject an isolated fault on Substation Grid Frequency sensor
/home/kami/sentinel-stack/ops/inject_sensor_fault.sh s044_frequency 2.5

# 3. Reset the sensor fault back to baseline
/home/kami/sentinel-stack/ops/reset_sensor_fault.sh s044_frequency

# 4. Audit Live-SBOM W^X memory integrity
/home/kami/sentinel-stack/ops/check_sbom_drift.sh

# 5. Execute an AI TRiSM prompt jailbreak test drill
/home/kami/sentinel-stack/ops/test_trism_jailbreak.sh

# 6. Issue an emergency all-stop stabilization command
/home/kami/sentinel-stack/ops/emergency_all_stop.sh

# 1. List all 10 scripts in ops/docker
ls -la /home/kami/sentinel-stack/ops/docker/

# 2. Test listing container IPs
/home/kami/sentinel-stack/ops/docker/list_container_ips.sh

# 3. Test pruning unused networks
/home/kami/sentinel-stack/ops/docker/prune_networks.sh

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