{ config, lib, pkgs, ... } @ inputs:

let
  lock-wallpaper = "~/.lock-wallpaper.png";
  action = import ../../common/actions.nix inputs;
  bin = import ../../common/binaries.nix inputs;
  font = import ../../common/fonts.nix inputs;
  script = import ../../common/scripts inputs;
in
{
  imports = [
    ./bar.nix
    ./dunst.nix
    ./gammastep.nix
    ./keybindings.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    extraConfig = "bindswitch --reload --locked lid:on exec ${action.lock}";

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
            (toString config.desktop.screen.width)
            (toString config.desktop.screen.height)
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
          scale = toString config.desktop.screen.scale;
          bg = "${../../static/wallpaper.jpg} fill";
        };
      };

      floating = {
        criteria = [
          { app_id = "blueman-manager"; }
          { app_id = "pavucontrol"; }
          { app_id = "wdisplays"; }
          { title = "Extension:*"; }
          { title = "Firefox Developer Edition — Sharing Indicator"; }
          { title = "Firefox — Sharing Indicator"; }
        ];
      };

      window = {
        hideEdgeBorders = "both";
        border = 1;
        titlebar = false;
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
        command = action.lock;
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
        command = action.lock;
      }
    ];
  };
}
