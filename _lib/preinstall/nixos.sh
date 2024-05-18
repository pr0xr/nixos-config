#!/usr/bin/env bash


nixos-generate-config --root /mnt;
sed --in-place '/system\.stateVersion = .*/a \
    nix.package = pkgs.nixUnstable;\n \
    nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
    services.openssh.enable = true;\n \
    services.openssh.settings.PasswordAuthentication = true;\n \
    services.openssh.settings.PermitRootLogin = \"yes\";\n \
    users.users.root.initialPassword = \"root\";\n \
' /mnt/etc/nixos/configuration.nix;