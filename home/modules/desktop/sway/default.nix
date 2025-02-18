{ config, lib, pkgs, ... }:

let
  lock-wallpaper = "~/.lock-wallpaper.png";
  action = import ../../../common/actions.nix { inherit lib; inherit pkgs; };
  bin = import ../../../common/binaries.nix pkgs;
  font = import ../../../common/fonts.nix pkgs;
  script = import ../../../common/scripts pkgs;
  cfg-display = config.repo.desktop.display;
in

{
  imports = [
    ./bar.nix
    ./dunst.nix
    ./keybindings.nix
  ];

  options.repo.desktop.sway = with lib.types; {
    enable = lib.mkOption {
      default = false;
      type = bool;
    };
  };

  config = lib.mkIf config.repo.desktop.sway.enable {
    home.packages = with pkgs; [
      wl-gammarelay-rs
    ];

    wayland.windowManager.sway = {
      enable = true;
      extraConfig = "bindswitch --reload --locked lid:on exec ${action.lock-nofail}";

      wrapperFeatures = {
        base = true;
        gtk = true;
      };

      config = {
        modifier = "Mod4";
        terminal = bin.foot;

        startup = [
          {
            command = lib.strings.concatStringsSep " " [
              script.bin.update-wallpaper
              (toString cfg-display.width)
              (toString cfg-display.height)
              "${font.directory}/NotoSansNerdFont-Regular.ttf"
              lock-wallpaper
            ];
          }
        ];

        fonts = {
          names = [ font.default ];
          size = font.size;
        };

        input = {
          "*".xkb_layout = "fr";
          "type:touchpad".tap = "enabled";
        };

        output = {
          "*" = {
            scale = toString cfg-display.scale;
            bg = "${../../../static/wallpaper.jpg} fill";
          };
        };

        floating = {
          criteria = [
            { app_id = "blueman-manager"; }
            { app_id = "pavucontrol"; }
            { title = "Ankama Launcher"; }
            { title = "Extension:*"; }
            { title = "Firefox Developer Edition — Sharing Indicator"; }
            { title = "Firefox — Sharing Indicator"; }
          ];
        };

        window = {
          hideEdgeBorders = "both";
          border = 1;
          titlebar = false;

          commands = [
            {
              # Dofus notifications
              command = lib.strings.concatStringsSep " ; " [
                "floating enable"
                "sticky enable"
                "move position 10 25"
              ];
              criteria = {
                app_id = "dofus.exe";
              };
            }

          ];
        };
      };
    };

    programs.swaylock = {
      enable = true;

      settings = {
        image = "${lock-wallpaper}";
        ignore-empty-password = true;
      };
    };

    services.swayidle = {
      enable = true;

      events = [
        {
          event = "before-sleep";
          command = action.lock-nofail;
        }
        {
          event = "after-resume";
          command = ''swaymsg "output * power on"'';
        }
      ];

      timeouts = [
        {
          timeout = 1795;
          command = ''swaymsg "output * power off"'';
        }
        {
          timeout = 1800;
          command = action.lock-nofail;
        }
      ];
    };

    systemd.user.services = {
      gammarelay-sun = {
        Unit.Description = "Control wl-gammarelay-rs depending on sun position.";
        Service.ExecStart = "${script.bin.gammarelay-sun}";
        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
