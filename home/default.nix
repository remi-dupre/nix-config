{ config, pkgs, lib, ... } @ inputs:

rec {
  imports = [
    ./modules/shell
    ./modules/sway
    ./modules/desktop
  ];

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  services.mpris-proxy.enable = true;

  desktop.screen = {
    width = 2560;
    height = 1600;
    scale = 1.20;
  };

  home = {
    username = "remi";
    homeDirectory = "/home/remi";
    keyboard.layout = "fr";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "23.11"; # Did you read the comment?
  };
}
