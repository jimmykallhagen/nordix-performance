#!/bin/bash
##============================================================================##
# SPDX-License-Identifier: GPL-3.0-or-later                                  #
# Nordix license - https://www.gnu.org/licenses/gpl-3.0.html                 #
# Copyright (c) 2025- The Nordix Authors                                     #
# Part of Nordix - https://github.com/jimmykallhagen/Nordix                  #
#                                                                            #
# This program is free software: you can redistribute it and/or modify       #
# it under the terms of the GNU General Public License as published by       #
# the Free Software Foundation, either version 3 of the License, or          #
# (at your option) any later version. See <https://www.gnu.org/licenses/>.   #
##============================================================================##

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)"
    exit 1
fi

echo "
   ######***********************************************#####
 ###                                                        ###
##                                                            ##
 # * * Nordix commandline collection - CPU Flags: Laptop * *  #
##                                                            ##
 ###                                                        ###
   ######***********************************************#####
"
sleep 2

ROOT_DATASET=$(zfs list -H -o name,mountpoint | grep -E '\s/$' | cut -f1)

CMD_FLAG="rw boot=zfs nowatchdog split_lock_detect=off amd_pstate=guided intel_pstate=passive \
processor.max_cstate=9 intel_idle.max_cstate=9 idle=halt \
nohz=on highres=on tsc=reliable clocksource=tsc \
transparent_hugepage=madvise zswap.enabled=1 \
snd_hda_intel.power_save=1 snd_hda_intel.power_save_controller=Y \
pcie_aspm=force pcie_aspm.policy=powersupersave \
nvme.noacpi=0 \
loglevel=3 splash fastboot quiet"

zfs set org.zfsbootmenu:commandline="${CMD_FLAG}" ${ROOT_DATASET}

echo "$CMD_FLAG"
echo ""
echo "New commandline flags applied"
sleep 1
echo "Zfsbootmenu is ready, reboot to activate new flags"
echo ""
echo "Battery life optimized - performance will be lower but your laptop will last longer"
