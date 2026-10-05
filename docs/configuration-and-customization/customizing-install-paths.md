---

### File: `sentinel-stack/docs/configuration-and-customization/customizing-install-paths.md`

```markdown
# Customizing System Installation Prefixes (`/usr/local` vs. `/opt`)

While `sentinel-stack` defaults to standard FHS paths (`/usr/local/bin`, `/usr/local/lib`), enterprise distributions or immutable root environments often require relocating the stack into a self-contained directory (e.g., `/opt/aryorithm/`).

---

## 1. Modifying the Installation Prefix

Edit `configs/stack.yaml`:

```yaml
global:
  install_prefix: "/opt/aryorithm"
```

---

## 2. Architectural Adjustments Executed Automatically

When `install_prefix` is modified, the installer updates several system configurations:

1. **CMake Target Flags:** Passes `-DCMAKE_INSTALL_PREFIX=/opt/aryorithm` across all six tiers.
2. **Dynamic Linker Cache:** Registers `/etc/ld.so.conf.d/aryorithm.conf` containing:
   ```text
   /opt/aryorithm/lib
   /opt/aryorithm/lib/sentinel-plugins
   ```
3. **Environment `PATH` Profile:** Installs `/etc/profile.d/aryorithm.sh` to add the custom binary path to all user and service shells:
   ```bash
   export PATH="/opt/aryorithm/bin:${PATH}"
   ```
4. **Systemd Service Paths:** Updates `ExecStart` directives to reference `/opt/aryorithm/bin/sentinel-nexus` and `/opt/aryorithm/bin/sentinel`.
```

---

### File: `sentinel-stack/docs/configuration-and-customization/configuring-git-branches-and-tags.md`

```markdown
# Pinning Production Releases: Git Branches & Semantic Tags

By default, `sentinel-stack` tracks the `main` branch across all component repositories. For regulated production deployments, pin each tier to immutable semantic release tags (e.g., `v1.0.0` or `v2.4.0`).

---

## 1. Pinning Releases in `configs/stack.yaml`

Update the `branch` field for each tier to a specific Git commit hash or signed tag:

```yaml
repositories:
  xinfer_essential:
    git_url: "https://github.com/kamisaberi/xinfer.git"
    branch: "tags/v1.0.0"

  blackbox_essential:
    git_url: "https://github.com/kamisaberi/blackbox.git"
    branch: "tags/v1.0.0"

  blackbox_sentinel:
    git_url: "https://github.com/kamisaberi/blackbox-sentinel.git"
    branch: "tags/v2.4.0"

  xinfer_forge:
    git_url: "https://github.com/kamisaberi/xinfer-forge.git"
    branch: "tags/v2.4.0"

  sentinel_lab:
    git_url: "https://github.com/kamisaberi/sentinel-lab.git"
    branch: "tags/v1.0.0"

  sentinel_nexus:
    git_url: "https://github.com/kamisaberi/sentinel-nexus.git"
    branch: "tags/v2.4.0"
```

---

## 2. Synchronization Invariant

When Phase 2 (`02_clone_repositories.sh`) runs, it detects tag specifications and checks out the exact referenced commit:

```bash
git checkout -q "${TAG_OR_BRANCH}"
```

This ensures that builds are reproducible across physical servers and virtual environments.
```

---

### File: `sentinel-stack/docs/configuration-and-customization/customizing-cmake-build-flags.md`

```markdown
# Customizing Compiler Optimization Flags (`-O3`, `-march=native`, `-flto`)

`sentinel-stack` allows performance engineers to inject custom compiler and linker flags into downstream CMake projects to maximize throughput on specific edge hardware architectures.

---

## 1. Enabling Microarchitecture Optimization (`-march=native`)

If building on dedicated, homogeneous edge appliances (e.g., an Intel Core Ultra or AMD EPYC server), enable target microarchitecture instructions (AVX-512, BMI2, FMA):

Edit `configs/stack.yaml`:

```yaml
build_options:
  enable_native_arch: true # Appends -march=native -mtune=native to CMAKE_CXX_FLAGS
```

---

## 2. Enabling Link-Time Optimization (LTO / ThinLTO)

To enable whole-program inter-procedural optimization across native shared objects:

```yaml
build_options:
  enable_lto: true # Passes -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE to CMake
```

---

## 3. Injecting Sanitizers for Debugging

To compile the entire stack with address and undefined behavior sanitizers for testbed fuzzing:

Append custom flags to `extra_cxx_flags` in `configs/stack.yaml`:

```yaml
build_options:
  build_type: "Debug"
  extra_cxx_flags: "-fsanitize=address,undefined -fno-omit-frame-pointer"
```

The installer injects these flags across all CMake configure steps automatically.
```
