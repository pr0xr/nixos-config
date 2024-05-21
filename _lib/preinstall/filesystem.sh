#!/usr/bin/env bash

BOOT_DRIVE=$INSTALL_DRIVE
AMOUNT_SWAP=1
PARTITION_BIOS_GPT=1
PARTITION_BOOT=2
PARTITION_SWAP=3
PARTITION_ROOT=4
LABEL_BIOS_GPT=biosgpt
LABEL_BOOT=boot
LABEL_SWAP=swap
LABEL_ROOT=root
MOUNT_PATH=/mnt
BOOT_SYSTEM_PARTITION=/boot

_filesystem_preinstall () {
umount /dev/sda?* || true
wipefs -af ${INSTALL_DRIVE}

# Prepare system disk
sgdisk -Z ${INSTALL_DRIVE} # DELETE install drive
sgdisk -a 2048 -o ${INSTALL_DRIVE} # CREATING 2048 alignment

# Create system partitions
#sgdisk -n ${PARTITION_BIOS_GPT}:0:+2M ${INSTALL_DRIVE} # BIOS partition GPT needs 2MB
#sgdisk -n ${PARTITION_BOOT}:0:+200M ${INSTALL_DRIVE} # BOOT partition
sgdisk -n ${PARTITION_BOOT}:0:+550M ${INSTALL_DRIVE} # BOOT partition
sgdisk -n ${PARTITION_SWAP}:0:+${AMOUNT_SWAP}G ${INSTALL_DRIVE} # SWAP partititon
sgdisk -n ${PARTITION_ROOT}:0:0 ${INSTALL_DRIVE} # ROOT partition

# Set partition types
#sgdisk -t ${PARTITION_BIOS_GPT}:ef02 ${INSTALL_DRIVE}
#sgdisk -t ${PARTITION_BOOT_GRUB}:8300 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_BOOT}:ef00 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_SWAP}:8200 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_ROOT}:8300 ${INSTALL_DRIVE}

# Label partitions
#sgdisk -c ${PARTITION_BIOS_GPT}:"${LABEL_BIOS_GPT}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_BOOT}:"${LABEL_BOOT}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_SWAP}:"${LABEL_SWAP}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_ROOT}:"${LABEL_ROOT}" ${INSTALL_DRIVE}

# Make filesystems
mkfs.vfat ${INSTALL_DRIVE}${PARTITION_BOOT}

SWAPON_DISK=$(swapon --show=NAME --noheadings)
if [[ "${SWAPON_DISK}" != "${INSTALL_DRIVE}${PARTITION_SWAP}" ]]
then
mkswap ${INSTALL_DRIVE}${PARTITION_SWAP}
swapon ${INSTALL_DRIVE}${PARTITION_SWAP}
fi
mkfs.${FILESYSTEM_TYPE} ${INSTALL_DRIVE}${PARTITION_ROOT}

# Mount
mkdir -p ${MOUNT_PATH}
mount ${INSTALL_DRIVE}${PARTITION_ROOT} ${MOUNT_PATH}
mkdir -p ${MOUNT_PATH}${BOOT_SYSTEM_PARTITION}
mount -t vfat -o umask=0077 ${INSTALL_DRIVE}${PARTITION_BOOT} ${MOUNT_PATH}${BOOT_SYSTEM_PARTITION}
}

