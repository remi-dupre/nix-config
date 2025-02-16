{
  config,
  lib,
  pkgs,
  ...
}:

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
      appimage-run
      wineWowPackages.stable # Open Source implementation of the Windows API...
    ];

    programs.mangohud = {
      enable = true;
      enableSessionWide = true;

      settings = {
        battery = true;
        battery_time = true;
        battery_watt = true;
        fps_limit = 40;
        no_display = true;
      };
    };
  };

}
