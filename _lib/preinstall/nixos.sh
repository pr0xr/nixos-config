#!/usr/bin/env bash
_defaultvalue NIXOS_CONFIG https://github.com/oxypwn/nixos-config/archive/refs/heads/main.tar.gz
_defaultvalue NIXNAME vm-intel

_nixos_pre () {
    nixos-generate-config --root /mnt;
    sed --in-place '/system\.stateVersion = .*/a \
        nix.package = pkgs.nixUnstable;\n \
        nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
        services.openssh.enable = true;\n \
        services.openssh.settings.PasswordAuthentication = true;\n \
        services.openssh.settings.PermitRootLogin = \"yes\";\n \
        users.users.root.initialPassword = \"root\";\n \
        boot.loader.grub.device = \"/dev/sda\";\n \
    ' /mnt/etc/nixos/configuration.nix;

    nixos-install --no-root-passwd
}

_nixos_post () {
    mkdir -p /boot/EFI/{systemd,BOOT}
    cd $HOME \
        && mkdir /nixos-config \
        && curl \
            -H "Accept: application/vnd.github.raw+json" \
            -H "Authorization: Bearer ${GITHUB_TOKEN}" \
            -LSs https://api.github.com/repos/oxypwn/nixos-config/tarball | tar xvzf - -C /nixos-config --strip-components=1
    NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake "/nixos-config#${NIXNAME}" --show-trace
}