# Custom U-Boot base environment for Nerves

# This environment is a majorly trimmed down version of the default
# one that ships with the Beaglebone.
#
# Why?
#   1. We want to store settings in the U-boot environment so that they're
#      accessible both to Elixir and U-boot.
#   2. This makes us add an environment block.
#   3. Unfortunately, if we point U-Boot to this block, it replaces its
#      default environment settings which contain all of the logic to
#      boot the boards. Therefore we have to copy/paste the relevant
#      parts here.
#   4. We can support more complicated firmware validation methods by
#      deferring validation of new software to the application. The
#      default below is to automatically validate new software.
#
# See U-Boot/include/configs/ti_armv7_common.h and
# U-Boot/include/configs/am335x_evm.h for most of what's below.

#
# Nerves variables
#

nerves_fw_active=a

# nerves_fw_autovalidate controls whether updates are considered valid once
# applied. If set to 0, the user needs to set nerves_fw_validated to 1 in their
# application. If they don't set it before a reboot, then the previous software
# is run. If 1, then no further action needs to be taken.
nerves_fw_autovalidate=1

# nerves_fw_validated is 1 if the current boot selection is accepted It is set
# to 1 here, since this environment is written in the factory, so it is
# implicitly valid.
nerves_fw_validated=1

# nerves_fw_booted is 0 for the first boot and 1 for all reboots after that.
# NOTE: Keep this '0' so that all new boards run a 'saveenv' to exercise the
#       code that writes back to the eMMC early on.
nerves_fw_booted=0

# The nerves initialization logic
#
# The nerves_init code is run at boot (see the last line of the file). It
# checks whether this is a first boot or not. If it's not the first boot, then
# the firmware better be validated or it reverts to running the firmware on
# the opposite partition.
nerves_revert=\
    if test ${nerves_fw_active} = "a"; then\
        echo "Reverting to partition B";\
        setenv nerves_fw_active "b";\
    else\
        echo "Reverting to partition A";\
        setenv nerves_fw_active "a";\
    fi

nerves_init=\
    if test ${nerves_fw_booted} = 1; then\
        if test ${nerves_fw_validated} = 0; then\
            run nerves_revert;\
            setenv nerves_fw_validated 1;\
            saveenv;\
        fi;\
    else\
        setenv nerves_fw_booted 1;\
        if test ${nerves_fw_autovalidate} = 1; then\
            setenv nerves_fw_validated 1;\
        fi;\
        saveenv;\
    fi;\
    setenv bootfile zImage.${nerves_fw_active};\
    if test ${nerves_fw_active} = "a"; then\
        setenv uenv_root /dev/mmcblk0p2;\
        setenv bootpart 0:2;\
    else\
        setenv uenv_root /dev/mmcblk0p3;\
        setenv bootpart 0:3;\
    fi

# Custom U-Boot startup script for Nerves

echo "Running Nerves U-Boot script"

# =========================================================================== #
# Boot Configure
# =========================================================================== #

# Defaults
console=ttyS0,115200n8
bootdir=
fdtdir=/boot
fdtfile=undefined
devtype=mmc
# squashfs support is slow, so always load the kernel from FAT (FIXME)
kernel_bootpart=0:1

# default values
setenv load_addr "0x44000000"
setenv verbosity "1"
setenv console "both"
setenv disp_mem_reserves "off"
setenv rootfstype "squashfs"

## Armbian:
# setenv rootdev "/dev/mmcblk0p1"

## Nerves BBB:
# Note the root filesystem specification. In Linux, /dev/mmcblk0 is always
# the boot device. In uboot, mmc 0 is the SDCard.
# Therefore, we hardcode root=/dev/mmcblk0p2 since we always want to mount
# the root partition off the same device that ran u-boot and supplied
# zImage.
setenv rootdev "/dev/mmcblk0p2"

# =========================================================================== #
# Boot Runtime Configuration
# =========================================================================== #

# Print boot source
itest.b *0x28 == 0x00 && echo "Booting from SD"
itest.b *0x28 == 0x02 && echo "Booting from eMMC or secondary SD"

if test "${console}" = "display" || test "${console}" = "both"; then setenv consoleargs "console=tty1"; fi
if test "${console}" = "serial" || test "${console}" = "both"; then setenv consoleargs "${consoleargs} console=ttyS0,115200"; fi

# # Allow the user to override the kernel/erlinit arguments
# # via a "uEnv.txt" file in the FAT partition.
# if load mmc ${mmcdev}:1 ${loadaddr} uEnv.txt; then
#     echo "uEnv.txt found. Overriding environment."
#     env import -t -r ${loadaddr} ${filesize}
#
#     # Check if the user provided a set of commands to run
#     if test -n $uenvcmd; then
#         echo "Running uenvcmd..."
#         run uenvcmd
#     fi
# fi

# =========================================================================== #
# Boot System
# =========================================================================== #

# setenv bootargs "root=${rootdev} ro rootwait rootfstype=squashfs ${consoleargs} cgroup_enable=memory panic=10 consoleblank=0 enforcing=0 loglevel=${verbosity}"

# Disable GPU memory (?)
# if test "${disp_mem_reserves}" = "off"; then setenv bootargs "${bootargs} sunxi_ve_mem_reserve=0 sunxi_g2d_mem_reserve=0 sunxi_fb_mem_reserve=16"; fi

setenv bootargs console=ttyS0,115200 earlyprintk loglevel=8 root=/dev/mmcblk0p2 rootfstype=squashfs ro rootwait

echo "Bootargs: ${bootargs}"

# Load the kernel
# load mmc 0:1 ${ramdisk_addr_r} /boot/uInitrd || load mmc 0 ${ramdisk_addr_r} uInitrd
# load mmc 0:1 ${kernel_addr_r} /boot/zImage || load mmc 0 ${kernel_addr_r} zImage
load mmc 0:1 ${kernel_addr_r} zImage

fdtfile=sun8i-h2-plus-orangepi-zero.dtb
# Load the DT. On the BBB, fdtfile=sun8i-h3-nanopi-neo.dtb
load mmc 0:1 ${fdt_addr_r} ${fdtfile}

# Boot!!
bootz ${kernel_addr_r} - ${fdt_addr_r}

echo "Nerves boot failed!"
