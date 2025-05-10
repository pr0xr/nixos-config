#!/bin/bash

set -o errexit -x

_defaultvalue REMOTE http://raw.githubusercontent.com/oxypwn/nixos-config/main
_defaultvalue FILESYSTEM_TYPE ext4
_defaultvalue FILESYSTEM _install/preinstall/filesystem
_defaultvalue INSTALL_DRIVE /dev/sda
_defaultvalue NIXOS _install/preinstall/nixos
_defaultvalue FSTAB _install/preinstall/fstab
_defaultvalue CHROOTPLZ _install/chrootplz
_defaultvalue CHROOT /mnt


[ ! -f "${0}" ] && echo "Don't run this directly from curl. Save to file first." && exit
MNT=/mnt; TMP=/tmp/archblocks; POSTSCRIPT="/postinstall.sh"
[ -e "${POSTSCRIPT}" ] && INCHROOT=true || INCHROOT=false

if ! $INCHROOT; then
_loadblock "${FILESYSTEM}"
#_filesystem_preinstall
_filesystem_nixos
#_loadblock "${FSTAB}"
#_filesystem_fstab
_loadblock "${NIXOS}"
_nixos_pre
#_nixos_post
#_loadblock "${CHROOTPLZ}"
_build_postscript
fi

if $INCHROOT; then
_loadblock "${NIXOS}"
_nixos_post
#_cleanup_chroot
#_exit_and_reboot
fi

