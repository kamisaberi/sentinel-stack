# Verification & Smoke Tests

Phase 5 executes `scripts/05_verify_installation.sh`, an automated 11-check quality gate asserting stack health.

## Section Navigation

- [Verification Suite Overview](./verification-suite-overview.md): 11-step post-build quality gate matrix and exit codes.
- [Tier 1 Check: libxinfer](./tier-1-libxinfer-check.md): Verifying `libxinfer.so` registration and header paths.
- [Tier 2 Check: libblackbox](./tier-2-libblackbox-check.md): Verifying `libblackbox.so` and `xdp_filter.o` BPF bytecode.
- [Tier 3 Check: sentinel](./tier-3-sentinel-check.md): Verifying `sentinel` daemon binary and 30 dissector plugins.
- [Tier 4 Check: forge-cli](./tier-4-forge-cli-check.md): Verifying `forge-cli` execution in `/opt/sentinel-stack/venv`.
- [Tier 5 Check: sentinel_lab](./tier-5-sentinel-lab-check.md): Verifying `sentinel_lab` research testbed executable.
- [Tier 6 Check: nexus-ctl](./tier-6-nexus-ctl-check.md): Verifying `sentinel-nexus` service and active ports (50051, 9443, 9444).
- [Automated CI/CD Integration](./automated-ci-cd-integration.md): GitHub Actions / GitLab CI workflow integration.
