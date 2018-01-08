#!/bin/bash
# Copies raspi3.img into compr.img, resulting in many consecutive zero bytes
# which are nicely compressible.

set -e

qemu-img create -f raw compr.img 1100M

# copy partition table from raspi3.img
sfdisk --quiet --dump raspi3.img | sfdisk --quiet compr.img

readarray rmappings < <(sudo kpartx -asv raspi3.img)
readarray cmappings < <(sudo kpartx -asv compr.img)

# copy the vfat boot partition as-is
set -- ${rmappings[0]}
rboot="$3"
set -- ${cmappings[0]}
cboot="$3"
sudo dd if=/dev/mapper/${rboot?} of=/dev/mapper/${cboot?} bs=5M status=none

# copy the ext4 root partition in a space-saving way
set -- ${rmappings[1]}
rroot="$3"
set -- ${cmappings[1]}
croot="$3"
sudo e2fsck -y -f /dev/mapper/${rroot?}
sudo resize2fs /dev/mapper/${rroot?} 800M
sudo e2image -rap /dev/mapper/${rroot?} /dev/mapper/${croot?}

sudo kpartx -ds raspi3.img
sudo kpartx -ds compr.img

xz -8 -f compr.img
