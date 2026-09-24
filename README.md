# Sentinel Stack: Unified 6-Tier Ecosystem Installer

`sentinel-stack` is the master build automation and deployment repository for the **Aryorithm / Blackbox Sentinel** platform.

---

## What It Builds and Installs

| Tier | Component | Artifact | Installed Path |
| :--- | :--- | :--- | :--- |
| **Tier 1** | `xinfer-essential` | Universal AI Runtime | `/usr/local/lib/libxinfer.so` |
| **Tier 2** | `blackbox-essential` | eBPF Kernel Dropper | `/usr/local/lib/libblackbox.so` |
| **Tier 3** | `blackbox-sentinel` | Commercial Edge XDR | `/usr/local/bin/sentinel` |
| **Tier 4** | `xinfer-forge` | Continuous Learning | `/usr/local/bin/forge-cli` |
| **Tier 5** | `sentinel-lab` | Academic Research | `/usr/local/bin/sentinel_lab` |
| **Tier 6** | `sentinel-nexus` | Fleet Command Plane | `/usr/local/bin/sentinel-nexus` |
| **Admin** | `nexus-ctl` | Operations CLI | `/usr/local/bin/nexus-ctl` |

---

## 1-Click Automated Installation (Ubuntu 24.04 / 26.04)

On any fresh or existing Ubuntu machine, execute:

```bash
git clone https://github.com/kamisaberi/sentinel-stack.git
cd sentinel-stack
sudo ./install.sh