# LinuxIA — Snapshot VM100 (auto)

## Horodatage

2026-02-08T17:30:05-05:00


## Host / OS

 Static hostname: vm100-factory
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 4ad1faaf6d0e447c9cd18801cce5ead4
         Boot ID: cbb9f18cd86248429d83dca55ea49014
  Virtualization: kvm
Operating System: openSUSE Leap 16.0
     CPE OS Name: cpe:/o:opensuse:leap:16.0
          Kernel: Linux 6.12.0-160000.9-default
    Architecture: x86-64
 Hardware Vendor: QEMU
  Hardware Model: Standard PC _Q35 + ICH9, 2009_
Firmware Version: 3.20230228-4
   Firmware Date: Tue 2023-06-06
    Firmware Age: 2y 8month 4d

NAME="openSUSE Leap"
VERSION="16.0"
ID="opensuse-leap"
ID_LIKE="suse opensuse"
VERSION_ID="16.0"
PRETTY_NAME="openSUSE Leap 16.0"
ANSI_COLOR="0;32"
CPE_NAME="cpe:/o:opensuse:leap:16.0"
BUG_REPORT_URL="https://bugs.opensuse.org"
HOME_URL="https://www.opensuse.org/"
DOCUMENTATION_URL="https://en.opensuse.org/Portal:Leap"
LOGO="distributor-logo-Leap"


## Kernel

Linux vm100-factory 6.12.0-160000.9-default #1 SMP PREEMPT_DYNAMIC Fri Jan 16 09:29:05 UTC 2026 (9badd3c) x86_64 x86_64 x86_64 GNU/Linux


## Disques / Partitions

NAME     SIZE FSTYPE      TYPE MOUNTPOINTS                   MODEL            SERIAL
sda       64G             disk                               QEMU HARDDISK    drive-scsi0
├─sda1   512M vfat        part /boot/efi                                      
├─sda2  61,5G btrfs       part /var                                           
│                              /usr/local                                     
│                              /root                                          
│                              /srv                                           
│                              /opt                                           
│                              /home                                          
│                              /boot/grub2/x86_64-efi                         
│                              /boot/grub2/i386-pc                            
│                              /.snapshots                                    
│                              /                                              
└─sda3     2G swap        part [SWAP]                                         
sdb    931,5G             disk                               QEMU HARDDISK    DATA_1TB_A
├─sdb1   7,8G ext4        part                                                
├─sdb2  39,1G ntfs        part                                                
├─sdb3  97,7G ntfs        part                                                
├─sdb4   100M vfat        part                                                
├─sdb5    16M LVM2_member part                                                
├─sdb6 769,8G             part /opt/linuxia/data/shareA                       
│                              /srv/linuxia-share/DATA_1TB_A                  
│                              /mnt/linuxia/DATA_1TB_A                        
├─sdb7   495M ntfs        part                                                
└─sdb8  16,6G ntfs        part                                                
sdc    931,5G             disk                               QEMU HARDDISK    DATA_1TB_B
├─sdc1   100M vfat        part                                                
├─sdc2    16M             part                                                
├─sdc3 465,1G ntfs        part /opt/linuxia/data/shareB                       
│                              /srv/linuxia-share/DATA_1TB_B                  
│                              /mnt/linuxia/DATA_1TB_B                        
└─sdc4   518M ntfs        part                                                
sdd     14,4G             disk                               DataTraveler 3.0 60A44C413DF8F280799ADD30
└─sdd1  14,4G vfat        part /run/media/gaby/LINUXUDF                       
zram0    7,7G             disk [SWAP]                                         


## Montages

TARGET                                        SOURCE                              FSTYPE          OPTIONS
/                                             /dev/sda2[/@/.snapshots/1/snapshot] btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=266,subvol=/@/.snapshots/1/snapshot
|-/mnt/linuxia/DATA_1TB_A                     /dev/sdb6                           fuseblk         rw,nosuid,nodev,relatime,context=system_u:object_r:samba_share_t:s0,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096
|-/dev                                        devtmpfs                            devtmpfs        rw,nosuid,seclabel,size=4096k,nr_inodes=1006610,mode=755,inode64
| |-/dev/mqueue                               mqueue                              mqueue          rw,nosuid,nodev,noexec,relatime,seclabel
| |-/dev/hugepages                            hugetlbfs                           hugetlbfs       rw,nosuid,nodev,relatime,seclabel,pagesize=2M
| |-/dev/shm                                  tmpfs                               tmpfs           rw,nosuid,nodev,seclabel,inode64
| `-/dev/pts                                  devpts                              devpts          rw,nosuid,noexec,relatime,seclabel,gid=5,mode=620,ptmxmode=000
|-/sys                                        sysfs                               sysfs           rw,nosuid,nodev,noexec,relatime,seclabel
| |-/sys/fs/selinux                           selinuxfs                           selinuxfs       rw,nosuid,noexec,relatime
| |-/sys/kernel/tracing                       tracefs                             tracefs         rw,nosuid,nodev,noexec,relatime,seclabel
| |-/sys/kernel/debug                         debugfs                             debugfs         rw,nosuid,nodev,noexec,relatime,seclabel
| | `-/sys/kernel/debug/tracing               tracefs                             tracefs         rw,nosuid,nodev,noexec,relatime,seclabel
| |-/sys/kernel/config                        configfs                            configfs        rw,nosuid,nodev,noexec,relatime
| |-/sys/fs/fuse/connections                  fusectl                             fusectl         rw,nosuid,nodev,noexec,relatime
| |-/sys/kernel/security                      securityfs                          securityfs      rw,nosuid,nodev,noexec,relatime
| |-/sys/fs/cgroup                            cgroup2                             cgroup2         rw,nosuid,nodev,noexec,relatime,seclabel,nsdelegate,memory_recursiveprot
| |-/sys/fs/pstore                            pstore                              pstore          rw,nosuid,nodev,noexec,relatime,seclabel
| |-/sys/firmware/efi/efivars                 efivarfs                            efivarfs        rw,nosuid,nodev,noexec,relatime
| `-/sys/fs/bpf                               bpf                                 bpf             rw,nosuid,nodev,noexec,relatime,mode=700
|-/proc                                       proc                                proc            rw,nosuid,nodev,noexec,relatime
| `-/proc/sys/fs/binfmt_misc                  systemd-1                           autofs          rw,relatime,fd=35,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=6473
|-/run                                        tmpfs                               tmpfs           rw,nosuid,nodev,seclabel,size=1625032k,nr_inodes=819200,mode=755,inode64
| |-/run/credentials/systemd-journald.service tmpfs                               tmpfs           ro,nosuid,nodev,noexec,relatime,nosymfollow,seclabel,size=1024k,nr_inodes=1024,mode=700,inode64,noswap
| |-/run/user/1000                            tmpfs                               tmpfs           rw,nosuid,nodev,relatime,seclabel,size=812512k,nr_inodes=203128,mode=700,uid=1000,gid=1000,inode64
| | |-/run/user/1000/gvfs                     gvfsd-fuse                          fuse.gvfsd-fuse rw,nosuid,nodev,relatime,user_id=1000,group_id=1000
| | `-/run/user/1000/doc                      portal                              fuse.portal     rw,nosuid,nodev,relatime,user_id=1000,group_id=1000
| |-/run/media/gaby/LINUXUDF                  /dev/sdd1                           vfat            rw,nosuid,nodev,relatime,uid=1000,gid=1000,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,showexec,utf8,flush,errors=remount-ro
| |-/run/credentials/getty@tty1.service       tmpfs                               tmpfs           ro,nosuid,nodev,noexec,relatime,nosymfollow,seclabel,size=1024k,nr_inodes=1024,mode=700,inode64,noswap
| `-/run/user/0                               tmpfs                               tmpfs           rw,nosuid,nodev,relatime,seclabel,size=812512k,nr_inodes=203128,mode=700,inode64
|-/boot/grub2/i386-pc                         /dev/sda2[/@/boot/grub2/i386-pc]    btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=258,subvol=/@/boot/grub2/i386-pc
|-/boot/grub2/x86_64-efi                      /dev/sda2[/@/boot/grub2/x86_64-efi] btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=257,subvol=/@/boot/grub2/x86_64-efi
|-/.snapshots                                 /dev/sda2[/@/.snapshots]            btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=265,subvol=/@/.snapshots
|-/home                                       /dev/sda2[/@/home]                  btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=264,subvol=/@/home
|-/opt                                        /dev/sda2[/@/opt]                   btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=263,subvol=/@/opt
| |-/opt/linuxia/data/shareA                  /dev/sdb6[/LinuxIA_SMB]             fuseblk         rw,nosuid,nodev,relatime,context=system_u:object_r:samba_share_t:s0,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096
| `-/opt/linuxia/data/shareB                  /dev/sdc3[/LinuxIA_SMB]             fuseblk         rw,nosuid,nodev,relatime,context=system_u:object_r:samba_share_t:s0,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096
|-/srv                                        /dev/sda2[/@/srv]                   btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=261,subvol=/@/srv
| |-/srv/artifacts-hot                        artifacts-hot                       virtiofs        rw,relatime
| | `-/srv/artifacts-hot/win-ssh              none                                virtiofs        rw,relatime
| |-/srv/linuxia-share/DATA_1TB_A             /dev/sdb6                           fuseblk         rw,nosuid,nodev,relatime,context=system_u:object_r:samba_share_t:s0,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096
| `-/srv/linuxia-share/DATA_1TB_B             /dev/sdc3                           fuseblk         rw,nosuid,nodev,relatime,context=system_u:object_r:samba_share_t:s0,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096
|-/root                                       /dev/sda2[/@/root]                  btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=262,subvol=/@/root
|-/tmp                                        tmpfs                               tmpfs           rw,nosuid,nodev,seclabel,size=4062580k,nr_inodes=1048576,inode64
|-/usr/local                                  /dev/sda2[/@/usr/local]             btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=260,subvol=/@/usr/local
|-/var                                        /dev/sda2[/@/var]                   btrfs           rw,relatime,seclabel,discard=async,space_cache=v2,subvolid=259,subvol=/@/var
|-/boot/efi                                   /dev/sda1                           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro
`-/mnt/linuxia/DATA_1TB_B                     /dev/sdc3                           fuseblk         rw,nosuid,nodev,relatime,context=system_u:object_r:samba_share_t:s0,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096


## Samba (services)

● smb.service - Samba SMB Daemon
     Loaded: loaded (/usr/lib/systemd/system/smb.service; enabled; preset: disabled)
     Active: active (running) since Sun 2026-02-08 02:40:25 EST; 14h ago
 Invocation: c2f9110a745440a7b2360111e4b5efdf
       Docs: man:smbd(8)
             man:samba(7)
             man:smb.conf(5)
   Main PID: 491499 (smbd)
     Status: "smbd: ready to serve connections..."
      Tasks: 3 (limit: 9390)
        CPU: 2.077s
     CGroup: /system.slice/smb.service
             ├─491499 /usr/sbin/smbd --foreground --no-process-group
             ├─491502 /usr/sbin/smbd --foreground --no-process-group
             └─491503 /usr/sbin/smbd --foreground --no-process-group

● nmb.service - Samba NMB Daemon
     Loaded: loaded (/usr/lib/systemd/system/nmb.service; enabled; preset: disabled)
     Active: active (running) since Sun 2026-02-08 02:40:24 EST; 14h ago
 Invocation: 0dd372745f2a49a1983894ca19764881
       Docs: man:nmbd(8)
             man:samba(7)
             man:smb.conf(5)
   Main PID: 491481 (nmbd)
     Status: "nmbd: ready to serve connections..."
      Tasks: 1 (limit: 9390)
        CPU: 1.169s
     CGroup: /system.slice/nmb.service
             └─491481 /usr/sbin/nmbd --foreground --no-process-group


## LinuxIA (units/timers)

UNIT FILE                     STATE   PRESET
linuxia-configsnap.service    static  -
linuxia-healthcheck.service   static  -
linuxia-repair.service        static  -
linuxia-samba-remount.service enabled disabled
linuxia-configsnap.timer      enabled disabled
linuxia-healthcheck.timer     enabled disabled

6 unit files listed.
  UNIT                          LOAD   ACTIVE SUB     DESCRIPTION
  linuxia-repair.service        loaded active exited  LinuxIA auto-repair (VM100)
  linuxia-samba-remount.service loaded active exited  LinuxIA - Remount NTFS + bind + restart Samba + healthcheck
  linuxia-configsnap.timer      loaded active waiting Run LinuxIA config snapshot nightly
  linuxia-healthcheck.timer     loaded active waiting Run LinuxIA healthcheck daily

Legend: LOAD   → Reflects whether the unit definition was properly loaded.
        ACTIVE → The high-level unit activation state, i.e. generalization of SUB.
        SUB    → The low-level unit activation state, values depend on unit type.

4 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
