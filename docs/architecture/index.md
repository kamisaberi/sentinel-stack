# Architecture & Low-Level Design

`sentinel-stack` operates as a topological meta-installer designed to provision the entire 6-tier runtime ecosystem on bare-metal systems and virtual appliances.

## Section Navigation

- [Meta-Installer Architecture](./meta-installer-architecture.md): 6-phase pipeline design and error trapping traps.
- [Master CLI (aryo) Architecture](./master-cli-aryo-architecture.md): Modular C++20 design of `/usr/local/bin/aryo` (`common.hpp`, `help_manuals.hpp`, `domain_router.hpp`).
- [Topological Compilation DAG](./topological-compilation-dag.md): Mathematical dependency graph ($T_1 \to T_6$) and linear ordering.
- [Dependency Graph Formalization](./dependency-graph-formalization.md): Symbol resolution table and intermediate `ldconfig` cache refreshes.
- [System Layout & Paths](./system-layout-and-paths.md): Filesystem layout (`/usr/local/bin`, `/usr/local/lib`, `/opt/sentinel-stack/venv`).
- [Air-Gapped Installation Model](./air-gapped-installation-model.md): Pre-seeded offline deployment mode (`./install.sh --offline`).
- [Atomic Rollback Safeguards](./atomic-rollback-safeguards.md): Shell error traps and failure containment.
