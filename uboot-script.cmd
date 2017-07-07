# Custom U-Boot startup script for Nerves

echo "Running Nerves U-Boot script"

# =========================================================================== #
# Boot Configure
# =========================================================================== #

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

# Load the DT. On the BBB, fdtfile=sun8i-h3-nanopi-neo.dtb
load mmc 0:1 ${fdt_addr_r} ${fdtfile}

# Boot!!
bootz ${kernel_addr_r} - ${fdt_addr_r}

echo "Nerves boot failed!"
