# Operations & Makefile

`sentinel-stack` provides operational targets for maintaining, updating, backing up, and purging the 6-tier runtime ecosystem.

## Section Navigation

- [Makefile Reference](./makefile-reference.md): Categorized cheat sheet covering all build, update, status, and clean targets.
- [Updating Installed Tiers](./updating-installed-tiers.md): Automated updates (`sudo make update`) and incremental recompilation.
- [Monitoring Daemons Status](./monitoring-daemons-status.md): Checking systemd service health and listener ports (`sudo make status`).
- [Clean Uninstallation Guide](./clean-uninstallation-guide.md): Stopping services, purging installed binaries, and restoring dynamic linker cache.
- [Backup & Recovery](./automated-backup-and-recovery.md): Automated configuration and state backup (`sudo make backup`).
