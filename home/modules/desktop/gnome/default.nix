{
  config,
  lib,
  pkgs,
  ...
}@inputs:

let
  cfg = config.repo.desktop.gnome;
  font = import ../../../common/fonts.nix inputs;
in

{
  options.repo.desktop.gnome = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    dconf = {
      enable = true;

      settings = {
        "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
        "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
        "org/gnome/desktop/interface".toolkit-accessibility = true;

        "org/gnome/shell" = {
          disable-user-extensions = false; # enables user extensions

          favorite-apps = [
            "firefox-devedition.desktop"
            "org.gnome.Console.desktop"
            "org.gnome.Nautilus.desktop"
          ];
        };

        "org/gnome/desktop/background" = {
          picture-uri = "${../../../static/wallpaper.jpg}";
          picture-uri-dark = "${../../../static/wallpaper.jpg}";
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark"; # gtk 4
          font-name = "${font.default} ${toString font.size}";
        };

        "org/gnome/desktop/interface" = {
          enable-hot-corners = true;
          edge-tiling = true;
        };

        "org/gnome/mutter" = {
          dynamic-workspaces = true;
          workspaces-only-on-primary = true;
          experimental-features = [ "scale-monitor-framebuffer" ];
        };

        "org/gnome/desktop/a11y/mouse" = {
          secondary-click-enabled = true;
          secondary-click-time = 1.2;
        };
      };
    };

    home.packages = with pkgs; [
      mission-center # Monitor your CPU, Memory, Disk, Network and GPU usage
      surface-control # Control various aspects of Microsoft Surface devices
    ];

    programs = {
      gnome-shell = {
        enable = true;

        extensions = [
          # Need version 31
          # { package = pkgs.gnomeExtensions.gjs-osk; }
        ];
      };
    };
  };
}
