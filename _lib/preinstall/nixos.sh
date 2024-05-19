#!/usr/bin/env bash
_defaultvalue NIXOS_CONFIG https://github.com/oxypwn/nixos-config/archive/refs/heads/main.tar.gz

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
nixos-enter -c "${POSTSCRIPT}"    
}