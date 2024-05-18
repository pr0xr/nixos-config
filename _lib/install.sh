#!/bin/bash

_defaultvalue FILESYSTEM_TYPE ext4
_defaultvalue FILESYSTEM pre/filesystem

[ ! -f "${0}" ] && echo "Don't run this directly from curl. Save to file first." && exit
[ -e "${POSTSCRIPT}" ] && INCHROOT=true || INCHROOT=false

if ! $INCHROOT; then
_loadblock "${FILESYSTEM}"
_filesystem_preinstall
fi