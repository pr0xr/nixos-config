

vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) "\
		export REMOTE=https://raw.githubusercontent.com/oxypwn/nixos-config/main \
		. <(curl -H 'Pragma: no-cache' -H 'Cache-Control: no-cache, no-store, force-revalidate' -H 'Expires: 0' -fsL "${REMOTE}/_lib/functions.sh?$(date +%s)"); _loadblock "_lib/install""


vm/switch:
	nixos-rebuild switch --flake $HOME/source/nixos-config#vm-intel --show-trace
