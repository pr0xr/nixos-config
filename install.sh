REMOTE=https://raw.githubusercontent.com/oxypwn/nixos-config/main
. <(curl -H 'Pragma: no-cache' -H 'Cache-Control: no-cache, no-store, force-revalidate' -H 'Expires: 0' -fsL "${REMOTE}/_lib/functions.sh?$(date +%s)"); _loadblock "_install/install"
