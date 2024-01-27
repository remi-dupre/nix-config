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
    stateVersion = "23.11";
    keyboard.layout = "fr";
  };
}
