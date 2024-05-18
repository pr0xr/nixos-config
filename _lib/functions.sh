
_anykey () {
# Provide an alert (with optional custom preliminary message) and pause.
#
# Usage:
# _anykey "optional custom message"
#
echo -e "\n$@"; read -sn 1 -p "Any key to continue..."; echo;
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
    else URL="${REMOTE/%\//}/archlinux/${FILE}"; fi

    _loaded_block="$(curl -fsL ${URL})";
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