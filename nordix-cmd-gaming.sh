#!/bin/bash
##========================================================##
 # SPDX-License-Identifier: GPL-3.0-or-later              #
 # Copyright (c) 2025 Jimmy Källhagen                     #
 # Part of Yggdrasil - Nordix desktop environment         #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen # 
##========================================================##
 if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root (sudo)"
     exit 1
 fi


 echo "
   ######***********************************************#####
 ###                                                        ###
##                                                            ##
 # * * Nordix commandline collection - CPU Flags: Gaming * * #
##                                                            ##
 ###                                                        ###
   ######***********************************************#####
"
sleep 2
ROOT_DATASET=$(zfs list -H -o name,mountpoint | grep -E '\s/$' | cut -f1)

# --- Detect CPU topology and reserve the first two physical cores ---
# Reads core_id from /sys to find which logical threads (0,16 and 1,17 on R9 7950X)
# belong to physical core 0 and 1. These are reserved for the system (not nohz_full).

declare -A core_map
for cpu_path in /sys/devices/system/cpu/cpu[0-9]*; do
    coreid_file="$cpu_path/topology/core_id"
    [[ -f "$coreid_file" ]] || continue
    coreid=$(cat "$coreid_file")
    cpunum=${cpu_path##*/cpu}
    core_map["$coreid"]+="$cpunum "
done

# Sort core_id numerically, reserving the two lowest (physical core 0 and 1)
sorted_cores=($(echo "${!core_map[@]}" | tr ' ' '\n' | sort -n))
reserved_cpus=()
for coreid in "${sorted_cores[@]:0:2}"; do
    for cpunum in ${core_map[$coreid]}; do
        reserved_cpus+=($cpunum)
    done
done

# Build nohz_full of all logical cores EXCEPT the reserved ones 
total_cpus=$(($(nproc) - 1))
all_cpus=($(seq 0 $total_cpus))
nohz_cpus=()
for cpu in "${all_cpus[@]}"; do
    skip=false
    for r in "${reserved_cpus[@]}"; do
        [[ "$cpu" == "$r" ]] && skip=true && break
    done
    $skip || nohz_cpus+=($cpu)
done

# Compress to range notation (e.g. 2-15,18-31)
NOHZ_RANGE=""
start=${nohz_cpus[0]}
prev=${nohz_cpus[0]}
for i in "${nohz_cpus[@]:1}"; do
    if (( i == prev + 1 )); then
        prev=$i
    else
        [[ "$start" == "$prev" ]] && NOHZ_RANGE+="$start," || NOHZ_RANGE+="$start-$prev,"
        start=$i; prev=$i
    fi
done
[[ "$start" == "$prev" ]] && NOHZ_RANGE+="$start" || NOHZ_RANGE+="$start-$prev"

CMD_FLAG="rw boot=zfs nowatchdog mitigations=off amd_pstate=active \
amd_pstate.shared_mem=1 amd_prefcore=enable idle=poll processor.max_cstate=1 intel_idle.max_cstate=1 \
nohz=on nohz_full=${LAST_CPU} tsc=reliable clocksource=tsc \
hpet=disable highres=on skew_tick=1 threadirqs split_lock_detect=off preempt=full nospectre_v1 \
nospectre_v2 spec_store_bypass_disable=off tsx_async_abort=off mds=off srbds=off l1tf=off retbleed=off \
spectre_v2_user=off pti=off kpti=off mmio_stale_data=off gather_data_sampling=off \
reg_file_data_sampling=off random_trust_cpu=on random_trust_bootloader=on transparent_hugepage=madvise \
zswap.enabled=0 loglevel=0 quiet splash snd_hda_intel.power_save=0 snd_hda_intel.power_save_controller=N fastboot quiet"


zfs set org.zfsbootmenu:commandline="$CMD_FLAG" ${ROOT_DATASET}

echo "Reserved system cores (No - nohz_full on): ${reserved_cpus[*]}"
sleep 1
echo "nohz_full=${NOHZ_RANGE}"
sleep 1
echo "New commandline flags applied"
sleep 1 
echo "$CMD_FLAG"
sleep 2
echo "Searching..."
sleep 0.5
echo "Searching..."
sleep 0.5
echo "Wait..."
sleep 1
echo "Zero found [OK]"
sleep 0.5
echo "Searching..."
sleep 0.5
echo "Searching..."
sleep 0.5
echo "One found [OK]"
sleep 1
echo ""
echo "GO! GO! GO Zero and One!"
echo "Give me every bit you got!"
sleep 1
echo "Zfsbootmenu is armed and ready, do you dare to boot?"