# Nordix Performance

**Part of:** [Nordix](https://github.com/jimmykallhagen/Nordix)  
**License:** GPL-3.0-or-later  
**Author:** Jimmy Källhagen


Extreme performance tuning for Linux desktop systems. No compromise, pure performance.

Part of [Yggdrasil — Nordix Desktop Environment](https://github.com/Nordix).

---

## What is this?

Nordix Performance is a curated set of kernel and system configurations designed for high-RAM desktop systems (32GB–128GB) running demanding workloads — gaming, content creation, and development. Every value is chosen deliberately, documented with reasoning, and tuned for throughput over safety margins.

This is not a "one size fits all" config. This is for enthusiasts who understand the trade-offs and want maximum performance from their hardware.

---

## Files

### `99-nordix-performance.conf`

Drop-in sysctl configuration. Place in `/etc/sysctl.d/` and it takes effect on next boot, or apply immediately:

```bash
sudo sysctl --system
```

### `limits.conf`

User resource limits for `/etc/security/limits.conf`. Configures memory locking, file descriptors, process limits, and real-time scheduling for audio, virtualization, and wheel groups.

---

## What it tunes

### Dirty Page Management

Controls how long modified data stays in RAM before being written to disk. Larger buffers mean fewer write interruptions during gaming and heavy workloads, at the cost of more data at risk during a crash.

Nordix uses `_ratio` instead of `_bytes` so the configuration scales automatically with any RAM size — no modification needed whether you have 32GB or 128GB.

| Setting | Linux Default | Nordix | Effect |
|---------|:---:|:---:|--------|
| `vm.dirty_ratio` | 20 | 6 | Max dirty pages before forced flush (% of RAM) |
| `vm.dirty_background_ratio` | 10 | 2 | Threshold where background flushing begins (% of RAM) |
| `vm.dirty_writeback_centisecs` | 500 (5s) | 2500 (25s) | Flusher thread wake interval |
| `vm.dirty_expire_centisecs` | 3000 (30s) | 6000 (60s) | Age before data is considered for writing |

**Example on a 64GB system:** Background flushing starts at ~1.3GB dirty data, hard limit at ~4GB.

### VFS Cache

```
vm.vfs_cache_pressure = 20
```

Keeps directory and file metadata cached aggressively. Lower values mean the kernel holds onto inode/dentry caches longer — critical for gaming where asset files are accessed repeatedly.

### Memory Overcommit

```
vm.overcommit_memory = 0
vm.overcommit_ratio = 98
```

Heuristic overcommit with a high ratio ceiling. On systems with 32GB+ RAM and no swap, this lets applications allocate memory freely while still having kernel sanity checks.

### Swap

```
vm.swappiness = 10
vm.page-cluster = 0
```

Nordix does not use swap as default on 32GB+ systems. Swappiness is set low as a safety net, and page-cluster is 0 for SSD/NVMe optimal single-page reads.

### Memory Fragmentation

| Setting | Linux Default | Nordix | Effect |
|---------|:---:|:---:|--------|
| `vm.extfrag_threshold` | 500 | 400 | When to trigger memory compaction |
| `vm.compaction_proactiveness` | 20 | 10 | Background compaction aggressiveness |

Reduced proactive compaction avoids random CPU spikes during gameplay.

### HugePages

```
vm.hugetlb_shm_group = 1000
```

HugePages (2MB pages vs 4KB default) are not statically reserved — instead, Nordix provides a performance launcher that enables hugepages temporarily when starting a program. The `hugetlb_shm_group` is set to allow non-root usage.

### Kernel Watchdogs

```
kernel.nmi_watchdog = 0
kernel.watchdog = 0
kernel.watchdog_thresh = 0
```

All watchdogs disabled. Saves CPU cycles and reduces latency jitter. Trade-off: system hangs will not trigger automatic reboot.

### Kernel Performance

| Setting | Linux Default | Nordix | Effect |
|---------|:---:|:---:|--------|
| `kernel.split_lock_mitigate` | 1 | 0 | Disable split lock mitigation for throughput |
| `kernel.numa_balancing` | 1 | 0 | Disable NUMA balancing (single-socket systems) |
| `kernel.sched_autogroup_enabled` | 1 | 1 | Keep autogroup for desktop responsiveness |

### Security

| Setting | Value | Reason |
|---------|:---:|--------|
| `kernel.printk` | 3 3 3 3 | Quiet console, critical errors only |
| `kernel.kptr_restrict` | 1 | Hide kernel pointers from unprivileged users |
| `kernel.kexec_load_disabled` | 1 | Prevent runtime kernel replacement |
| `kernel.unprivileged_userns_clone` | 1 | Required for Flatpak, browsers, Steam |

### Wine / Proton / Gaming

```
vm.max_map_count = 2147483642
```

Maximum memory map areas. Required by Wine, Proton, Unreal Engine titles, and some IDEs. Set to kernel maximum.

### Network

Optimized TCP/IP stack for low-latency gaming and high-throughput transfers:

| Setting | Linux Default | Nordix | Effect |
|---------|:---:|:---:|--------|
| `net.core.default_qdisc` | fq_codel | fq | Fair queuing (required for BBR) |
| `net.ipv4.tcp_congestion_control` | cubic | bbr | Google BBR — better latency and throughput |
| `net.core.netdev_max_backlog` | 1000 | 16384 | Packet queue for high-speed networks |
| `net.core.rmem_max` | 212992 | 67108864 | Socket receive buffer max (64MB) |
| `net.core.wmem_max` | 212992 | 67108864 | Socket send buffer max (64MB) |
| `net.ipv4.tcp_fastopen` | 1 | 3 | TCP Fast Open for both directions |
| `net.ipv4.tcp_slow_start_after_idle` | 1 | 0 | Maintain congestion window on idle |
| `net.ipv4.tcp_tw_reuse` | 2 | 1 | Reuse TIME_WAIT sockets globally |
| `net.ipv4.tcp_fin_timeout` | 60 | 15 | Faster socket cleanup |
| `net.ipv4.tcp_keepalive_time` | 7200 | 300 | Detect dead connections in 5 minutes |

### File System Limits

| Setting | Linux Default | Nordix | Effect |
|---------|:---:|:---:|--------|
| `fs.file-max` | ~100000 | 2097152 | System-wide file descriptor limit |
| `fs.inotify.max_user_watches` | 8192 | 1548576 | Inotify watches (IDEs, Steam, file managers) |
| `fs.inotify.max_user_instances` | 128 | 8192 | Inotify instances per user |
| `fs.aio-max-nr` | 65536 | 1048576 | Async I/O operations |

---

## Resource Limits (limits.conf)

### Memory Locking

| Scope | Soft | Hard |
|-------|------|------|
| All users | 2GB | 4GB |
| @audio | unlimited | unlimited |
| @libvirt | unlimited | unlimited |
| @kvm | unlimited | unlimited |

### File Descriptors and Processes

| Setting | Soft | Hard |
|---------|------|------|
| nofile | 524288 | 524288 |
| nproc | 65536 | 131072 |

### Real-Time Scheduling

`@audio` and `@wheel` groups get `rtprio 99` and `nice -19` — maximum scheduling priority for audio production and admin users.

---

## Installation

```bash
# Sysctl performance config
sudo cp 99-nordix-performance.conf /etc/sysctl.d/
sudo sysctl --system

# Resource limits
sudo cp limits.conf /etc/security/limits.conf
```

Log out and back in for limits.conf to take effect.

---

## Requirements

- Linux kernel 5.15+
- 32GB RAM minimum (designed for 32GB–128GB systems)
- No swap partition (recommended)
- NVMe or SSD storage

---

## Philosophy

Nordix follows the laws of performance. Every default in the Linux kernel is a compromise — balanced for servers, embedded systems, and desktops alike. Nordix Performance strips away those compromises for a single purpose: the fastest possible desktop experience.

This is not for production servers. This is not for laptops on battery. This is for the machine sitting on your desk that you built to be fast.

---

## License

GPL-3.0-or-later

Copyright (c) 2025 Jimmy Källhagen
Part of Yggdrasil — Nordix Desktop Environment
Nordix and Yggdrasil are trademarks of Jimmy Källhagen
