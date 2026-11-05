# Master Unified CLI (`aryo`) Modular Architecture

The Master Unified CLI binary (**`/usr/local/bin/aryo`**) serves as the single-entrypoint operator interface across all 18 domains of the Aryorithm ecosystem (`login`, `status`, `hub`, `package`, `model`, `dataset`, `pcap`, `scenario`, `blueprint`, `5g`, `sbom`, `trism`, `space`, `forge`, `slab`, `lab`, `matrix`, `system`).

To maintain maintainability and zero-overhead performance, `/home/kami/sentinel-stack/src/aryo.cpp` is modularized into **4 clean C++20 header modules**.

---

## 1. Modular Header Structure

```text
 /home/kami/sentinel-stack/src/
 ├── common.hpp         # ANSI colors, corporate banner, forward_exec() POSIX execvp proxying
 ├── help_manuals.hpp   # Level-1 overview + 18 Level-2 dedicated contextual help manuals
 ├── domain_router.hpp  # Fast zero-overhead argument interceptor & domain dispatch router
 └── aryo.cpp           # Slim main entrypoint (< 50 lines of C++20 code)
```

---

## 2. Zero-Overhead POSIX `execvp` Proxying (`common.hpp`)

When an operator executes `aryo model pull network_threat_v2`, `aryo` intercepts help flags, then uses the POSIX `execvp()` system call via `forward_exec()` to replace the `aryo` process image directly with the target binary (`sentinel-ctl`):

```cpp
#pragma once

#include <iostream>
#include <vector>
#include <string>
#include <unistd.h>
#include <cstdlib>

inline void forward_exec(const std::string &target_bin, const std::vector<std::string> &args) {
    std::vector<char*> argv_exec;
    argv_exec.push_back(const_cast<char*>(target_bin.c_str()));

    for (const auto &arg : args) {
        argv_exec.push_back(const_cast<char*>(arg.c_str()));
    }
    argv_exec.push_back(nullptr);

    // Replaces the aryo process image with target_bin (0ms overhead, zero child forks)
    execvp(target_bin.c_str(), argv_exec.data());

    // Executed ONLY if execvp fails (e.g. target binary missing from PATH)
    std::cerr << "[-] Error: Failed to execute underlying binary '" << target_bin << "'." << std::endl;
    std::exit(1);
}
```

---

## 3. Level-1 vs. Level-2 Contextual Help Routing

1. **Level-1 Global Help (`aryo --help`):** Renders the global domain map covering all 18 command categories.
2. **Level-2 Contextual Help (`aryo <domain> --help`):** Intercepted by `domain_router.hpp` before process proxying, rendering dedicated Level-2 manuals (`print_help_5g`, `print_help_sbom`, `print_help_space`, `print_help_trism`, `print_help_scenario`, `print_help_blueprint`, etc.) with full syntax, options, and copy-paste examples.
