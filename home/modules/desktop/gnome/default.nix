{ config, lib, pkgs, ... }:

let
  cfg = config.repo.desktop.gnome;
  font = import ../../../common/fonts.nix pkgs;
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
        "com/raggesilver/BlackBox".working-directory-mode = 1;
        "io/missioncenter/MissionCenter".performance-page-network-use-bytes = true;
        "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
        "org/gnome/desktop/interface".toolkit-accessibility = true;
        "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
        "org/gnome/shell/app-switcher".current-workspace-only = true;

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
            "com.raggesilver.BlackBox.desktop"
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

        "org/gnome/shell/extensions/quick-settings-tweaks" = {
          add-dnd-quick-toggle-enabled = false;
          add-unsafe-quick-toggle-enabled = false;
          datemenu-remove-media-control = false;
          datemenu-remove-notifications = false;
          input-always-show = false;
          input-show-selected = false;
          media-control-compact-mode = true;
          media-control-enabled = false;
          notifications-enabled = false;
          output-show-selected = false;
          volume-mixer-position = "bottom";
          volume-mixer-show-description = true;
          volume-mixer-show-icon = true;

          user-removed-buttons = [
            "KeyboardMenuToggle"
            "DarkModeToggle"
            "RfkillToggle"
          ];

          list-buttons = builtins.toJSON [
            {
              name = "SystemItem";
              title = null;
              visible = true;
            }
            {
              name = "OutputStreamSlider";
              title = null;
              visible = false;
            }
            {
              name = "InputStreamSlider";
              title = null;
              visible = false;
            }
            {
              name = "St_BoxLayout";
              title = null;
              visible = true;
            }
            {
              name = "BrightnessItem";
              title = null;
              visible = false;
            }
            {
              name = "NMWiredToggle";
              title = null;
              visible = false;
            }
            {
              name = "NMWirelessToggle";
              title = "Wi-Fi";
              visible = true;
            }
            {
              name = "NMModemToggle";
              title = null;
              visible = false;
            }
            {
              name = "NMBluetoothToggle";
              title = null;
              visible = false;
            }
            {
              name = "NMVpnToggle";
              title = null;
              visible = false;
            }
            {
              name = "BluetoothToggle";
              title = "Bluetooth";
              visible = true;
            }
            {
              name = "PowerProfilesToggle";
              title = "Power Mode";
              visible = true;
            }
            {
              name = "NightLightToggle";
              title = "Night Light";
              visible = true;
            }
            {
              name = "DarkModeToggle";
              title = "Dark Style";
              visible = true;
            }
            {
              name = "KeyboardBrightnessToggle";
              title = "Keyboard";
              visible = false;
            }
            {
              name = "RfkillToggle";
              title = "Airplane Mode";
              visible = true;
            }
            {
              name = "RotationToggle";
              title = "Auto Rotate";
              visible = true;
            }
            {
              name = "KeyboardMenuToggle";
              title = "Screen Keyboard";
              visible = true;
            }
            {
              name = "CaffeineToggle";
              title = "Caffeine";
              visible = true;
            }
            {
              name = "DndQuickToggle";
              title = "Do Not Disturb";
              visible = true;
            }
            {
              name = "BackgroundAppsToggle";
              title = "No Background Apps";
              visible = false;
            }
            {
              name = "MediaSection";
              title = null;
              visible = false;
            }
            {
              name = "Notifications";
              title = null;
              visible = true;
            }
          ];

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
      blackbox-terminal # Beautiful GTK 4 terminal
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
          { package = caffeine; }
          { package = quick-settings-tweaker; }
          { package = screen-rotate; }
          { package = unite; }
          # Need version 31
          # { package = gjs-osk; }
        ];
      };
    };
  };
}
