# Dependency Management

`sentinel-stack` manages system packaging, compiler toolchains, and virtual environments across modern Ubuntu releases.

## Section Navigation

- [Ubuntu Packaging Engine](./ubuntu-packaging-engine.md): Non-interactive APT wrappers and lock contention handling.
- [t64 Package Resolution](./t64-package-resolution.md): Managing Ubuntu 24.04/26.04 64-bit `time_t` package renames.
- [PEP 668 Python Virtual Env](./pep-668-python-virtual-env.md): Isolated PyTorch/ONNX virtual environment at `/opt/sentinel-stack/venv`.
- [eBPF Compiler Toolchains](./ebpf-compiler-toolchains.md): Clang-16 BPF target compilation and kernel header alignment.
- [OpenVINO / CUDA Prerequisites](./openvino-tensorrt-prerequisites.md): Hardware AI accelerator discovery and feature flags.
- [Non-Interactive Execution](./non-interactive-execution.md): Suppressing debconf prompts and `needrestart` dialogs.
