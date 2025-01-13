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
        "io/missioncenter/MissionCenter".performance-page-network-use-bytes = true;

        "org/gnome/shell" = {
          disable-user-extensions = false;
          disable-extension-version-validation = true;

          enabled-extensions = [
            "Always-Show-Titles-In-Overview@gmail.com"
            "auto-activities@CleoMenezesJr.github.io"
            "gjsosk@vishram1123.com"
            "screen-rotate@shyzus.github.io"
            "unite@hardpixel.eu"
          ];

          favorite-apps = [
            "firefox-devedition.desktop"
            "org.gnome.Console.desktop"
            "org.gnome.Nautilus.desktop"
            "signal-desktop.desktop"
            "io.missioncenter.MissionCenter.desktop"
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

          experimental-features = [
            "scale-monitor-framebuffer"
            "xwayland-native-scaling"
          ];
        };

        "org/gnome/desktop/a11y/mouse" = {
          secondary-click-enabled = true;
          secondary-click-time = 1.2;
        };

        # Extension settings

        "org/gnome/shell/extensions/gjsosk" = {
          background-a = 1.0;
          background-a-dark = 1.0;
          background-b = 250.0;
          background-b-dark = 50.0;
          background-g = 250.0;
          background-g-dark = 50.0;
          background-r = 250.0;
          background-r-dark = 50.0;
          border-spacing-px = 2;
          default-snap = 7;
          enable-drag = true;
          enable-tap-gesture = 1;
          font-bold = false;
          font-size-px = 16;
          indicator-enabled = true;
          landscape-height-percent = 40;
          landscape-width-percent = 70;
          layout = 0;
          layout-landscape = 4;
          layout-portrait = 4;
          outer-spacing-px = 8;
          play-sound = false;
          portrait-height-percent = 30;
          portrait-width-percent = 100;
          round-key-corners = true;
          show-icons = true;
          snap-spacing-px = 45;
        };

        "org/gnome/shell/extensions/unite" = {
          enable-titlebar-actions = true;
          extend-left-box = false;
          greyscale-tray-icons = false;
          hide-activities-button = "never";
          hide-app-menu-icon = true;
          hide-window-titlebars = "maximized";
          notifications-position = "center";
          reduce-panel-spacing = false;
          restrict-to-primary-screen = true;
          show-appmenu-button = false;
          show-desktop-name = false;
          show-legacy-tray = true;
          show-window-title = "always";
          use-activities-text = false;
        };

        "org/gnome/shell/extensions/screen-rotate" = {
          invert-horizontal-rotation-direction = false;
          orientation-offset = 0;
        };
      };
    };

    home.packages = with pkgs; [
      flatpak # Linux application sandboxing and distribution framework
      gnome-software # Software store that lets you install and update applic...
      mission-center # Monitor your CPU, Memory, Disk, Network and GPU usage
      surface-control # Control various aspects of Microsoft Surface devices
    ];

    programs = {
      gnome-shell = {
        enable = true;

        extensions = with pkgs.gnomeExtensions; [
          { package = always-show-titles-in-overview; }
          { package = auto-activities; }
          { package = screen-rotate; }
          { package = unite; }
          # Need version 31
          # { package = gjs-osk; }
        ];
      };
    };
  };
}
