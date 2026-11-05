# Troubleshooting & Diagnostic Help Desk

Diagnostic procedures, error code remediations, and support channels for resolving build and installation issues.

## Section Navigation

- [OOM Compiler Crashes](./oom-compiler-crashes.md): Throttling parallel compiler jobs (`export PARALLEL_JOBS=2`) and swapfile allocation.
- [Missing Kernel Headers](./missing-kernel-headers.md): Resolving `uname -r` kernel header mismatches during eBPF compilation.
- [gRPC / Protobuf Linking Errors](./grpc-protobuf-linking-errors.md): Resolving Protobuf ABI divergence and Ubuntu `t64` package mismatches.
- [Python PEP 668 Errors](./python-externally-managed-errors.md): Fixing externally managed environment errors via `/opt/sentinel-stack/venv`.
- [Systemd Failed Starts](./systemd-service-failed-starts.md): Diagnosing `status=203/EXEC` and missing configuration file errors.
- [Dynamic Linker Library Not Found](./dynamic-linker-library-not-found.md): Registering `/usr/local/lib` in `/etc/ld.so.conf.d/sentinel.conf`.
- [Technical FAQ](./faq.md): Frequently asked technical questions regarding build times, ARM64 support, and air-gapped modes.
- [Support Channels](./support.md): Generating automated diagnostic bundles (`collect_diagnostics.sh`) and enterprise commercial SLAs.
