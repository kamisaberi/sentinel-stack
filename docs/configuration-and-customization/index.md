# Configuration & Customization

Customizing compilation flags, repository branches, and filesystem installation prefixes via `configs/stack.yaml`.

## Section Navigation

- [stack.yaml Specification](./stack-yaml-specification.md): Exhaustive YAML configuration manifest specification.
- [Customizing Install Paths](./customizing-install-paths.md): Relocating system installation prefixes (`/usr/local` vs `/opt/aryorithm`).
- [Git Branches & Tags](./configuring-git-branches-and-tags.md): Pinning production release tags (`v1.0.0`, `v2.4.0`) in `stack.yaml`.
- [Customizing CMake Flags](./customizing-cmake-build-flags.md): Injecting microarchitecture optimization (`-march=native`) and LTO.
