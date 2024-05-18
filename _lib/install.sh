#!/bin/bash

set -o errexit -x

_defaultvalue REMOTE http://raw.githubusercontent.com/oxypwn/nixos-config/main
_defaultvalue FILESYSTEM_TYPE ext4
_defaultvalue FILESYSTEM _lib/preinstall/filesystem
_defaultvalue INSTALL_DRIVE /dev/sda
_defaultvalue NIXOS _lib/preinstall/nixos

[ ! -f "${0}" ] && echo "Don't run this directly from curl. Save to file first." && exit
MNT=/mnt; TMP=/tmp/archblocks; POSTSCRIPT="/postinstall.sh"
[ -e "${POSTSCRIPT}" ] && INCHROOT=true || INCHROOT=false

if ! $INCHROOT; then
_loadblock "${FILESYSTEM}"
_filesystem_preinstall
_loadblock "${NIXOS}"
fi