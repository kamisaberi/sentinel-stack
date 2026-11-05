# Systemd Daemonization

Production systemd unit file configurations for running Aryorithm daemons with real-time scheduling and capability sandboxing.

## Section Navigation

- [Systemd Architecture](./systemd-architecture.md): Service dependency hierarchy and crash recovery loops.
- [sentinel-nexus.service](./sentinel-nexus-service.md): Production unit configuration for the central fleet command plane.
- [blackbox-sentinel.service](./blackbox-sentinel-service.md): Production unit configuration for the edge XDR appliance.
- [Linux Capabilities Management](./linux-capabilities-management.md): Granting `CAP_NET_ADMIN`, `CAP_BPF`, and `CAP_SYS_RESOURCE`.
- [Real-Time Process Scheduling](./real-time-process-scheduling.md): `SCHED_RR` priority 98 real-time scheduling and OOM score adjustment.
- [Daemon Logging & journalctl](./daemon-logging-and-journalctl.md): Filtering systemd logs and logrotate configurations.
