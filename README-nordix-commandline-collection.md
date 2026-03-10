# Nordix Commandline Collection

**Part of:** [Nordix](https://github.com/jimmykallhagen/Nordix)  
**License:** GPL-3.0-or-later  
**Author:** Jimmy Källhagen

## Overview

**ZFSBootMenu's Commandline Makes It Easy to Switch Profiles**

- **Nordix Standard Performance**

| Profile | Use Case | Risk Level |
|---------|----------|------------|
| `nordix-cmd-desktop` | Optimized desktop, balanced | Low |
| `nordix-cmd-laptop` | Optimized laptop, battery focused | Low |

- **Nordix Favourites**

| Profile | Use Case | Risk Level |
|---------|----------|------------|
| `nordix-cmd-gaming` | Low latency, smooth gameplay | Higher |
| `nordix-cmd-extreme` | Maximum performance, no compromises | Higher |
| `nordix-cmd-heavy-compute` | Throughput for compiling/rendering | Higher |
| `nordix-cmd-virtualization` | KVM/IOMMU optimized VM host | Higher |

> **Note:** `gaming`, `extreme` and `heavy-compute` are just names. 
> Try which one feels best for your system and workload.

## Usage

```bash
# Apply extreme profile
sudo nordix-cmd-extreme

# Apply desktop profile  
sudo nordix-cmd-desktop

# Reboot to activate
reboot
```

The scripts automatically detect your root ZFS dataset and apply the flags via:
```bash
zfs set org.zfsbootmenu:commandline="..." <root_dataset>
```

The scripts that using nohz_full have automatic cpu detection and apply so your first two physical cores remain untouched, so it doesn't disrupt your base system

---

## Complete Flag Reference

### Boot Essentials

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `rw` | Mount root filesystem read-write | — | Required for normal operation | — |
| `boot=zfs` | Use ZFS as boot filesystem | — | Required for ZFS root | — |
| `splash` | Show boot splash screen | — | Clean boot appearance | Hides boot messages |
| `loglevel=3` | Kernel log verbosity | 0-7 (0=emergency, 7=debug) | Cleaner boot, less spam | Harder to debug issues |

### Watchdog & Split Lock

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `nowatchdog` | Disable hardware watchdog | — | Reduces interrupts, saves power | No automatic reboot on kernel hang |
| `split_lock_detect=off` | Disable split lock detection | `off`, `warn`, `fatal` | Better performance for some apps | Hides potential software bugs |

### Security Mitigations

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `mitigations=off` | Disable ALL CPU vulnerability mitigations | `off`, `auto`, `auto,nosmt` | **5-30% performance boost** | Vulnerable to Spectre/Meltdown |
| `nospectre_v1` | Disable Spectre V1 mitigation | — | Performance gain | Security risk |
| `nospectre_v2` | Disable Spectre V2 mitigation | — | Performance gain | Security risk |
| `spec_store_bypass_disable=off` | Disable Spectre V4 mitigation | `off`, `on`, `auto`, `prctl`, `seccomp` | Performance gain | Security risk |
| `tsx_async_abort=off` | Disable TSX async abort mitigation | `off`, `full`, `full,nosmt` | Performance gain | Security risk (Intel) |
| `mds=off` | Disable MDS mitigation | `off`, `full`, `full,nosmt` | Performance gain | Security risk (Intel) |
| `srbds=off` | Disable SRBDS mitigation | `off`, `on` | Performance gain | Security risk (Intel) |
| `l1tf=off` | Disable L1TF mitigation | `off`, `full`, `full,force`, `flush`, `flush,nosmt`, `flush,nowarn` | Performance gain | Security risk (Intel) |
| `retbleed=off` | Disable Retbleed mitigation | `off`, `auto`, `nosmt`, `ibpb`, `unret` | Performance gain | Security risk |
| `spectre_v2_user=off` | Disable Spectre V2 user mitigation | `off`, `on`, `auto`, `prctl`, `seccomp` | Performance gain | Security risk |
| `pti=off` | Disable Page Table Isolation | `off`, `on`, `auto` | **Significant performance boost** | Meltdown vulnerability |
| `kpti=off` | Disable Kernel PTI (alias) | `off`, `on` | Same as pti=off | Same as pti=off |
| `mmio_stale_data=off` | Disable MMIO stale data mitigation | `off`, `full`, `full,nosmt` | Performance gain | Security risk (Intel) |
| `gather_data_sampling=off` | Disable GDS mitigation | `off`, `force` | Performance gain | Security risk (Intel) |
| `reg_file_data_sampling=off` | Disable RFDS mitigation | `off`, `on` | Performance gain | Security risk (Intel) |

> **WARNING:** Disabling security mitigations exposes your system to CPU vulnerabilities. Only use on private single-user systems, never on servers or shared machines.

### CPU Power Management

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `processor.max_cstate=1` | Limit CPU C-state depth | 0-9 (lower = less sleep) | Faster wake, lower latency | Higher power consumption |
| `processor.max_cstate=2` | Allow C1E state | 0-9 | Balance of latency/power | — |
| `amd_pstate=active` | AMD P-State driver mode | `active`, `passive`, `guided`, `disable` | Best AMD frequency scaling | AMD Zen 3+ only |
| `amd_pstate.shared_mem=1` | AMD P-State shared memory | 0, 1 | Required for some AMD CPUs | — |
| `amd_prefcore=enable` | AMD Preferred Core | `enable`, `disable` | Better boost on best cores | Zen 4+ only |

### CPU Power Management

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `processor.max_cstate` | Limit CPU C-state depth | 0-9 (lower = less sleep) | Lower latency | Higher power consumption |
| `amd_pstate` | AMD P-State driver mode | `active`, `passive`, `guided`, `disable` | AMD frequency scaling | AMD Zen 3+ only |
| `amd_pstate.shared_mem` | AMD P-State shared memory | 0, 1 | Required for some AMD CPUs | - |
| `amd_prefcore` | AMD Preferred Core | `enable`, `disable` | Better boost on best cores | Zen 4+ only |
| `intel_idle.max_cstate` | Intel: Limit idle states | 0-9 | Lower latency (Intel) | Higher power (Intel only) |
| `intel_pstate` | Intel P-State driver mode | `active`, `passive`, `disable`, `no_hwp` | Intel frequency scaling | Intel only |
| `idle=nomwait` | Disable MWAIT for idle | `nomwait`, `poll`, `halt` | Lower latency | Higher power |
| `idle=poll` | Never sleep, poll for work | `poll` | **Lowest latency possible** | **Maximum power consumption** |
| `idle=halt` | Use HLT instruction | `halt` | Balanced | - |

### Timer & Clock

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `clocksource=tsc` | Use TSC as clock source | `tsc`, `hpet`, `acpi_pm` | Fastest, lowest overhead | Must be reliable |
| `tsc=reliable` | Mark TSC as reliable | `reliable`, `noirqtime`, `unstable` | Allows TSC clocksource | May cause issues if TSC isn't stable |
| `hpet=disable` | Disable HPET timer | `disable`, `force` | Avoids HPET overhead | Some apps need HPET |
| `highres=on` | Enable high-resolution timers | `on`, `off` | Precise timing | Slightly more interrupts |

### Tickless Kernel (NOHZ)

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `nohz=on` | Enable tickless idle | `on`, `off` | Fewer interrupts when idle | — |
| `nohz_full=2-15,18-31` | Full tickless on specified CPUs | CPU range | **Near-zero kernel overhead** | Requires careful CPU reservation |
| `skew_tick=1` | Offset timer ticks per CPU | 0, 1 | Reduces lock contention | — |

> **Note:** `nohz_full` requires reserving at least 1-2 CPUs for kernel housekeeping. The extreme script auto-detects and reserves the first two physical cores.

### IRQ & Preemption

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `threadirqs` | Run IRQ handlers in threads | — | Better latency, schedulable IRQs | Slight overhead |
| `preempt=voluntary` | Voluntary preemption | `none`, `voluntary`, `full` | Balanced throughput/latency | — |
| `preempt=full` | Full preemption | `full` | Lowest latency | Lower throughput |
| `irqaffinity=0,1` | Pin IRQs to specific CPUs | CPU list | Keeps other CPUs undisturbed | Housekeeping CPUs get busy |

### CPU Isolation

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `isolcpus=2-15,18-31` | Isolate CPUs from scheduler | CPU range | Dedicated CPUs for RT tasks | Manual task pinning required |
| `rcu_nocbs=2-15,18-31` | Offload RCU callbacks | CPU range | Reduces jitter on isolated CPUs | — |

### Memory & Hugepages

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `transparent_hugepage=madvise` | THP mode | `always`, `madvise`, `never` | Apps opt-in to hugepages | Apps must use madvise() |
| `zswap.enabled=0` | Disable zswap | 0, 1 | No compression overhead | No compressed swap cache |

### Randomness

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `random_trust_cpu=on` | Trust CPU RNG (RDRAND) | `on`, `off` | Faster random init | Trust Intel/AMD RNG |
| `random_trust_bootloader=on` | Trust bootloader entropy | `on`, `off` | Faster random init | Trust bootloader |

### Audio

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `snd_hda_intel.power_save=0` | Disable audio power save | Seconds (0=off) | No audio pop/click on wake | Higher power |
| `snd_hda_intel.power_save_controller=N` | Disable controller power save | Y, N | No audio latency | Higher power |

### Virtualization (KVM)

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `kvm.ignore_msrs=1` | Ignore unknown MSRs | 0, 1 | Better Windows VM compat | Hides potential issues |
| `kvm.report_ignored_msrs=0` | Don't log ignored MSRs | 0, 1 | Cleaner logs | — |
| `kvm_amd.nested=1` | Enable nested virtualization | 0, 1 | VMs inside VMs | Performance overhead |
| `kvm_amd.npt=1` | AMD Nested Page Tables | 0, 1 | Better VM memory performance | — |
| `kvm_amd.avic=1` | AMD AVIC interrupt virtualization | 0, 1 | Better VM interrupt performance | Requires supported CPU |

### IOMMU & Passthrough

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `iommu=pt` | IOMMU passthrough mode | `pt`, `on`, `off` | Best performance with IOMMU | — |
| `amd_iommu=on` | Enable AMD IOMMU | `on`, `off` | Required for GPU passthrough | — |
| `intel_iommu=on` | Enable Intel IOMMU | `on`, `off` | Required for GPU passthrough | — |
| `vfio_iommu_type1.allow_unsafe_interrupts=1` | Allow unsafe VFIO interrupts | 0, 1 | Fix some passthrough issues | Security risk |
| `rd.driver.pre=vfio-pci` | Load VFIO early | — | GPU passthrough before graphics driver | — |

### NUMA

| Flag | Description | Options | Pros | Cons |
|------|-------------|---------|------|------|
| `numa_balancing=1` | Enable NUMA balancing | 0, 1 | Auto-migrate memory to local node | Overhead on non-NUMA |

---

## License

```
SPDX-License-Identifier: GPL-3.0-or-later
Copyright (c) 2025 Jimmy Källhagen
Part of Nordix - https://github.com/jimmykallhagen/Nordix
Nordix and Yggdrasil are trademarks of Jimmy Källhagen
```

---
