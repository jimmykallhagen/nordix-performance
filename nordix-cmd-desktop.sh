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
 # * * Nordix commandline collection - CPU Flags: Desktop * * #
##                                                            ##
 ###                                                        ###
   ######***********************************************#####
"
sleep 2
ROOT_DATASET=$(zfs list -H -o name,mountpoint | grep -E '\s/$' | cut -f1)

zfs set org.zfsbootmenu:commandline="rw boot=zfs nowatchdog split_lock_detect=off processor.max_cstate=3 intel_idle.max_cstate=3 \
  amd_pstate=active idle=nomwait zswap.enabled=0 transparent_hugepage=madvise clocksource=tsc \
  tsc=reliable hpet=disable nohz=on highres=on skew_tick=1 splash loglevel=3 snd_hda_intel.power_save=0 \
  snd_hda_intel.power_save_controller=N fastboot quiet" ${ROOT_DATASET} 

echo "rw boot=zfs nowatchdog split_lock_detect=off processor.max_cstate=3 intel_idle.max_cstate=3 \
  amd_pstate=active idle=nomwait zswap.enabled=0 transparent_hugepage=madvise clocksource=tsc \
  tsc=reliable hpet=disable nohz=on highres=on skew_tick=1 splash loglevel=3 snd_hda_intel.power_save=0 \
  snd_hda_intel.power_save_controller=N fastboot quiet"
echo "New commandline flags applied"

sleep 1
echo "Zfsbootmenu is ready, reboot to activate new flags"
