# Custom U-Boot startup script for Nerves

echo "Running Nerves U-Boot script"

# Kernel arguments and arguments to erlinit are passed here
# The erlinit arguments can just be tacked on to the end.
# For example, add "-v" to the end to put erlinit into verbose
# mode.

# Determine the boot arguments
#
# Note the root filesystem specification. In Linux, /dev/mmcblk0 is always
# the boot device. In uboot, mmc 0 is the SDCard.
# Therefore, we hardcode root=/dev/mmcblk0p2 since we always want to mount
# the root partition off the same device that ran u-boot and supplied
# zImage.
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootfstype=squashfs ro rootwait

# Load the kernel
load mmc 0:1 ${kernel_addr_r} zImage

# Load the DT. On the BBB, fdtfile=sun8i-h3-nanopi-neo.dtb
load mmc 0:1 ${fdt_addr_r} ${fdtfile}

# Boot!!
bootz ${kernel_addr_r} - ${fdt_addr_r}

echo "Nerves boot failed!"
