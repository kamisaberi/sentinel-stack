# Compilation DAG Tiers

Detailed compilation mechanics, CMake flags, and target artifacts across all six runtime tiers.

## Section Navigation

- [Tier 1: xinfer-essential](./building-tier-1-xinfer.md): Building `libxinfer.so` (Universal C++20 AI runtime).
- [Tier 2: blackbox-essential](./building-tier-2-blackbox.md): Compiling `xdp_filter.o` bytecode and `libblackbox.so`.
- [Tier 3: blackbox-sentinel](./building-tier-3-sentinel.md): Building `sentinel` daemon, 26 subsystems, and 30 plugins.
- [Tier 4: xinfer-forge](./building-tier-4-forge.md): Installing `forge-cli` inside `/opt/sentinel-stack/venv`.
- [Tier 5: sentinel-lab](./building-tier-5-lab.md): Building `sentinel_lab` research testbed and SLAB protocol tools.
- [Tier 6: sentinel-nexus](./building-tier-6-nexus.md): Building `sentinel-nexus` command daemon and `nexus-ctl` CLI.
- [Dynamic Linker ldconfig](./dynamic-linker-cache-ldconfig.md): Inter-tier `ldconfig` cache refresh invariants.
- [Parallel Job Scaling & RAM](./parallel-job-scaling-ram.md): Dynamic compiler job throttling (`make -j`) based on system RAM.
