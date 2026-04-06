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

  ######******************************************************#####
 ###                                                              ###
##                                                                  ##
 # * * Nordix commandline collection - CPU Flags: Heavy Compute * * #
##                                                                  ##
 ###                                                              ###
  ######******************************************************#####

ROOT_DATASET=$(zfs list -H -o name,mountpoint | grep -E '\s/$' | cut -f1)
CMD_FLAG="rw boot=zfs nowatchdog mitigations=off amd_pstate=active amd_pstate.shared_mem=1 amd_prefcore=enable \
idle=halt processor.max_cstate=3 intel_idle.max_cstate=3 \
nohz=on highres=on tsc=reliable clocksource=tsc hpet=disable \
split_lock_detect=off numa_balancing=1 preempt=voluntary nospectre_v1 \
nospectre_v2 spec_store_bypass_disable=off tsx_async_abort=off mds=off \
srbds=off l1tf=off retbleed=off spectre_v2_user=off pti=off kpti=off \
mmio_stale_data=off gather_data_sampling=off reg_file_data_sampling=off \
random_trust_cpu=on random_trust_bootloader=on transparent_hugepage=madvise \
zswap.enabled=0 loglevel=3 splash snd_hda_intel.power_save=0 snd_hda_intel.power_save_controller=N fastboot quiet"

zfs set org.zfsbootmenu:commandline="${CMD_FLAG}" ${ROOT_DATASET}

echo "$CMD_FLAG"

sleep 2
echo "New commandline flags applied"
sleep 1 
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

