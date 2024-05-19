{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.fish.enable = true;

  users.users.oxy = {
    isNormalUser = true;
    home = "/home/oxy";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$jAnSQQZJae.WiRMdStvV01$xv4FYyi0Um7PBT3eWrkSN0hsmMOq2vWgGPO2pYan6f3";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDO5zS+aopODyy42hMcdIw2VhVyL4aswKVP83QfRTyK0CJL0pZMHH+G9FkLYfpsnWnb30/Cx1JCY8O5xa4Va6UxvizQYv8XUse1BFV7ydUpyMCE0O+Y1BWDbj9iubA5Aqk5dAbwtJ/q6L3Gci/KSuy0xciFEY3SQfxJH3q8vt/xj2DSEtxZ/w9f63QrlD9YwcvI3kbf5kootdRNrzAJYlwSohix1Jtl/BVrZIhWvqSt/dM3qTG+gc1pkcCFw0mxvl/Fp3RYzlQ2qb2bL3QXkJrmgMmcuJywk5T1rljHC3ncIf9+7Ov+wAk+kYjfJip9/AefAL8478P7c23Woe0ie7pLGN/s4KaJb6a4ZXa27cu+m9jF4JKZKF/wJpL+4ZGzpNyE+SehhsyX8LeCgZqiBhopxSW94kE/YiwDNEFtlBSf6DCJQ10wXbNuSyrCw7TGACEBgJ0k0QxSSYf+mmKd+1BsrCTqyZxqZBdN0NFc3vVACGEROYaySznSvzFcDgt+CxQxssPnoElYhUnd747zHFN6HV/OYUBaAP4/DYgRSXGdfbvINEH4X+QrmXOTZDbqcbOAQGW/t4Pbcg9mqoRoFgBjAcZajXLxQBprQxrTN06SxASKI3/Y1hzmw4venpFnfM3LS1jEeBv+w+jxGV6HwzIZQgXoED9bsQ+Vsd0uP45Z7w=="
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix { inherit inputs; })
  ];
}
