# **Ntsync - Wine/Proton performance**

## **Wine/Proton performance flags**
There are a number of environment flags to use to increase performance for your Windows games.

**The traditional flags are:**
```
- WINEESYNC=1 
- WINEFSYNC=1
```
>This must be set as an option at game start most of the time.

#### In Steam 
```
- WINEESYNC=1 %command%
- WINEFSYNC=1 %command%
```
---

## What is Ntsync?

 NTSync is kernel-level synchronization primitive for Proton, designed to improve gaming performance and reduce stuttering by closely mimicking Windows synchronization. It requires a patched Linux kernel (e.g., 6.12+) and is enabled via launch options, often benefiting complex, heavily threaded games. It aims to reduce overhead compared to previous user-space methods like FSync and ESync by handling synchronization directly within the kernel. 

---

## How to use Ntsync
The envirorment flag för Ntsync is:
```
- PROTON_USE_NTSYNC=1
```

#### 32-bit Games: Some older or 32-bit games may require:
```
- PROTON_USE_WOW64=1
```

#### It is recommended to disable previous sync methods using 
```
PROTON_NO_FSYNC=1
PROTON_NO_ESYNC=1
```

#### **In Steam**
```
- PROTON_USE_WOW64=1 %command%
- PROTON_NO_FSYNC=1 %command%
- PROTON_NO_ESYNC=1 %command%
```

---

## **Make Ntsync Global**
However, community-made Proton versions such as GE-Proton (made by GloriousEggRoll) already have NTSYNC enabled by default if the kernel module is detected as loaded

### Load Ntsync module
It is simple, we only need to have the ntsync.conf file in the directory:
- /etc//modules-load.d/
If you have a kernel that supports it, it will be used automatically

#### What should the ntsync.conf file contain?
- ntsync 

## Nordix Yggdrasil has Ntsync as default: 
- Kernel support 
- ntsync.conf 

