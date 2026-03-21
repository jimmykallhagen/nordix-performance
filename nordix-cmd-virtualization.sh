#!/bin/bash
##=============================================================================##
 # SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0                       #
 # Nordix license - https://polyformproject.org/licenses/noncommercial/1.0.0   #
 # Copyright (c) 2025 Jimmy Källhagen                                          #
 # Part of Nordix - https://github.com/jimmykallhagen/Nordix                   #
 # Nordix and Yggdrasil are trademarks of Jimmy Källhagen                      #
##=============================================================================##
 if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root (sudo)"
     exit 1
 fi


 echo "
   ######******************************************************#####
 ###                                                               ###
##                                                                   ##
 # * * Nordix commandline collection - CPU Flags: Virtualization * * #
##                                                                   ##
 ###                                                               ###
   ######******************************************************#####
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

CMD_FLAG=""rw boot=zfs nowatchdog mitigations=off \
amd_pstate=active amd_pstate.shared_mem=1 amd_prefcore=enable kvm.ignore_msrs=1 \
kvm.report_ignored_msrs=0 kvm_amd.nested=1 kvm_amd.npt=1 kvm_amd.avic=1 vfio_iommu_type1.allow_unsafe_interrupts=1 \
iommu=pt amd_iommu=on idle=halt processor.max_cstate=3 intel_idle.max_cstate=3 nohz=on nohz_full=${NOHZ_RANGE} numa_balancing=1 preempt=voluntary \
transparent_hugepage=madvise tsc=reliable clocksource=tsc hpet=disable split_lock_detect=off \
intel_iommu=on iommu=1 rd.driver.pre=vfio-pci loglevel=3 fastboot quiet"


echo "Reserved system cores (No - nohz_full on): ${reserved_cpus[*]}"
echo "nohz_full=${NOHZ_RANGE}"
sleep 2

zfs set org.zfsbootmenu:commandline="$CMD_FLAG" ${ROOT_DATASET}

echo "Reserved system cores (No - nohz_full on): ${reserved_cpus[*]}"
sleep 1 
echo "$CMD_FLAG"
sleep 1
echo "nohz_full=${NOHZ_RANGE}"
sleep 1
echo "New commandline flags applied"
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
