#!/bin/bash

_defaultvalue () {
# Assign value to a variable in the install script only if unset.
# Note that *empty* variables that have purposefully been set as empty
# are not changed.
#
# usage:
#
# _defaultvalue VARNAME "value if VARNAME is currently unset or empty"
#
eval "${1}=\"${!1-${2}}\"";
}

_anykey () {
# Provide an alert (with optional custom preliminary message) and pause.
#
# Usage:
# _anykey "optional custom message"
#
echo -e "\n$@"; read -sn 1 -p "Any key to continue..."; echo;
}

_chroot_postscript () {
# handle interactively assigned install drive value
echo -e "#!/bin/bash\nINSTALL_DRIVE=$INSTALL_DRIVE" > "${MNT}${POSTSCRIPT}";
grep -v "^\s*INSTALL_DRIVE.*" "${0}" >> "${MNT}${POSTSCRIPT}";
echo -e 'export PS1="(chroot) $PS1"' >> "${MNT}${POSTSCRIPT}";
#cp "${0}" "${MNT}${POSTSCRIPT}";
chmod a+x "${MNT}${POSTSCRIPT}"; arch-chroot "${MNT}" "${POSTSCRIPT}";
}

_display_postinstall_messages () {
echo "\n\nInstallation complete; Reboot and then execute the post-reboot.sh script in the /root directory."
echo "\n"
[ -n "${POSTINSTALL_MSGS:-}" ] && echo "${POSTINSTALL_MSGS}"
}

_add_postinstall_messags () {
:
}

_preload () {
    isurl=false ispath=false isrootpath=false;
    case "$_block" in
        *://*) isurl=true ;;
        /*)    isrootpath=true ;;
        */*)   ispath=true ;;
        shell) echo "Dropping to shell..."; bash ;;  
    esac
    FILE="${_block/%.sh/}.sh";

    if $isurl; then URL="${FILE}";
    elif [ -f "${DIR/%\//}/${FILE}" ]; then URL="file://${FILE}";
    else URL="${REMOTE/%\//}/${FILE}"; fi
    echo "Fetching source "${URL}?$(date +%s)"";
    _loaded_block="$(curl \
        -H 'Cache-Control: no-cache, no-store' \
        -H 'Pragma: no-cache' \
        -fsL "${URL}?$(date +%s)")";
}


_loadblock () {
[ -z "$@" ] && return
for _block in $@; do
	_preload;
	echo "EXECUTING BLOCK \"$_block\""

	[ -n "$_loaded_block" ] && eval "${_loaded_block}";
     		
		while [ "$?" -gt 0 ]; do
            if [[ ! -z "$ERROR_EMAIL" ]]; then
                EMAIL=${ERROR_EMAIL}
                SUBJECT="${HOSTNAME} EXPERIENCED ERRORS IN BLOCK."
                TEXT="${HOSTNAME} report errors in $_block when installing."
                _mailgun
                unset EMAIL
                _anykey "BLOCK \"$_block\" EXPERIENCED ERRORS"
                read -p "Enter block or 'shell' for an interactive session: " _block;
            else
                _anykey "BLOCK \"$_block\" EXPERIENCED ERRORS" 
                read -p "Enter block or 'shell' for an interactive session: " _block;
            fi
			_preload;
			[ -n "$_loaded_block" ] && eval "${_loaded_block}";
    	done
done
}

_mailgun () {
curl -s --user $API_KEY_EMAIL \
    $API_URI_EMAIL \
    -F from="${HOSTNAME} <$API_FROM_EMAIL>" \
    -F to="$EMAIL" \
    -F subject="$SUBJECT" \
    -F text="$TEXT"
}

_pushover () {
curl -s \
    -F "token=$API_KEY_APP_PUSHOVER" \
    -F "user=$API_KEY_USER_PUSHOVER" \
    -F "message=${HOSTNAME} was successfully installed." \
    https://api.pushover.net/1/messages.json
}

_cleanupChroot () {

    if [[ ! -z "$API_KEY_APP_PUSHOVER" && ! -z "$API_KEY_USER_PUSHOVER" ]]; then
        MESSAGE="${HOSTNAME} was successfully installed."
        _pushover
    fi

    # Remove files We dont need in the system.
    rm $POSTSCRIPT

}

_postChroot () {
    if [[ ! -z "$POST_CHROOT" ]]; then
        _loadblock "$POST_CHROOT"
    else
        eject && reboot || reboot
        echo "postChroot"
    fi
}