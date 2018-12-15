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

echo "Running Nerves U-Boot script"

# =========================================================================== #
# Boot Configure
# =========================================================================== #

# Defaults
bootdir=
fdtdir=/boot
fdtfile=undefined
devtype=mmc
# squashfs support is slow, so always load the kernel from FAT (FIXME)
kernel_bootpart=0:1

# default values
load_addr="0x44000000"
verbosity="1"
disp_mem_reserves="off"
rootfstype="squashfs"

## Nerves BBB:
# Note the root filesystem specification. In Linux, /dev/mmcblk0 is always
# the boot device. In uboot, mmc 0 is the SDCard.
# Therefore, we hardcode root=/dev/mmcblk0p2 since we always want to mount
# the root partition off the same device that ran u-boot and supplied
# zImage.
rootdev="/dev/mmcblk0p2"

# =========================================================================== #
# Boot Runtime Configuration
# =========================================================================== #

# Print boot source
itest.b *0x28 == 0x00 && echo "Booting from SD"
itest.b *0x28 == 0x02 && echo "Booting from eMMC or secondary SD"

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

# Disable GPU memory (?)
# if test "${disp_mem_reserves}" = "off"; then setenv bootargs "${bootargs} sunxi_ve_mem_reserve=0 sunxi_g2d_mem_reserve=0 sunxi_fb_mem_reserve=16"; fi

setenv bootargs console=ttyS0,115200 earlyprintk loglevel=8 root=/dev/mmcblk0p2 rootfstype=squashfs overlays=uart1 ro rootwait

echo "Bootargs: ${bootargs}"

# Load the kernel
# load mmc 0:1 ${ramdisk_addr_r} /boot/uInitrd || load mmc 0 ${ramdisk_addr_r} uInitrd
# load mmc 0:1 ${kernel_addr_r} /boot/zImage || load mmc 0 ${kernel_addr_r} zImage
load mmc 0:1 ${kernel_addr_r} zImage

fdtfile=sun8i-h2-plus-orangepi-zero.dtb
# Load the DT. On the BBB, fdtfile=sun8i-h3-nanopi-neo.dtb
load mmc 0:1 ${fdt_addr_r} ${fdtfile}

fdt addr ${fdt_addr_r}
fdt resize 65536

overlay_prefix=sun8i-h3

for overlay_file in ${overlays}; do
    if load ${devtype} ${devnum} ${load_addr} overlays/${overlay_prefix}-${overlay_file}.dtbo; then
      echo "Applying kernel provided DT overlay ${overlay_prefix}-${overlay_file}.dtbo"
      fdt apply ${load_addr} || setenv overlay_error "true"
    fi
done

# Boot!!
bootz ${kernel_addr_r} - ${fdt_addr_r}

echo "Nerves boot failed!"
