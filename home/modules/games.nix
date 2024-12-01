{ config, lib, pkgs, ... }:

let
  cfg = config.repo.games;
in

{
  options.repo.games.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lutris # Open Source gaming platform for GNU/Linux
      wineWowPackages.stable # Open Source implementation of the Windows API...
    ];
  };
}
