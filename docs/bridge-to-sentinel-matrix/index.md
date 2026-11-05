# Bridge to Sentinel-Matrix

`sentinel-stack` automates harvesting compiled binaries and dependencies into `sentinel-matrix` for zero-friction digital twin execution.

## Section Navigation

- [Matrix Bridge Architecture](./matrix-bridge-architecture.md): Handover pipeline architecture and GLIBC 2.43 forward compatibility.
- [Harvesting Host Binaries](./harvesting-host-binaries.md): `harvest_binaries.sh` script copying executables to `shared/bin/`.
- [Dynamic Library Extraction (ldd)](./dynamic-library-extraction-ldd.md): `extract_libraries.sh` resolving dynamic dependencies (`libabsl`, `libgrpc++`).
- [Proto & Web Asset Handover](./proto-and-web-asset-handover.md): Synchronizing `.proto` files and Web SPA assets to `shared/web/`.
- [VMware / Docker Handshake](./vmware-docker-mesh-handshake.md): One-touch transition from host compilation to `make up` mesh launch.
