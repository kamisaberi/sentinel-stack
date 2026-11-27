# Installation Phases

The master orchestration script (`install.sh`) executes a linear 6-phase installation pipeline enforcing strict POSIX safety flags.

## Section Navigation

- [Pipeline Overview](./pipeline-overview.md): Master 6-phase execution flow and entrypoint script (`install.sh`).
- [Phase 0: System Validation](./phase-0-system-validation.md): OS checks, kernel BPF validation, and dynamic RAM build throttling.
- [Phase 1: Dependency Resolution](./phase-1-dependency-resolution.md): APT toolchain installation, `t64` package resolution, and Python virtualenv.
- [Phase 2: Repository Synchronization](./phase-2-repository-synchronization.md): Local sibling directory `rsync` or shallow Git cloning.
- [Phase 3: Topological Build](./phase-3-topological-compilation.md): Sequential C++ compilation across all 6 tiers and `ldconfig` refreshes.
- [Phase 4: systemd Daemonization](./phase-4-systemd-daemonization.md): Service unit deployment with real-time `SCHED_RR` scheduling.
- [Phase 5: Smoke Testing](./phase-5-smoke-testing.md): Automated quality gate executing 11 post-build assertion checks.
