{ lib, pkgs, ... } @ inputs:

let
  # TODO : actual module params
  ctx = {
    screen = {
      width = 2560;
      height = 1600;
      scale = 1.20;
    };
    font = {
      default = "NotoSans Nerd Font";
      compact = "NotoSans Nerd Font SemiCondensed";
      monospace = "FiraMono Nerd Font";
    };
  };

  # Ressources
  fonts-pkg = pkgs.nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; };
  fonts-dir = "${fonts-pkg}/share/fonts/truetype/NerdFonts";
  lock-wallpaper = "~/.lock-wallpaper.png";
  action = (import ../../common/actions.nix inputs);
  bin = (import ../../common/binaries.nix inputs);
  scripts = (import ../../common/scripts inputs);
in
{
  imports = [
    ./bar.nix
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
            scripts.update-wallpaper
            (toString ctx.screen.width)
            (toString ctx.screen.height)
            "${fonts-dir}/NotoSansNerdFont-Regular.ttf"
            lock-wallpaper
          ];
        }
      ];

      fonts = {
        names = [ ctx.font.default ];
        size = 10.0;
      };

      input = {
        "*".xkb_layout = "fr";
        "type:touchpad".tap = "enabled";
      };

      output = {
        "*" = {
          scale = toString ctx.screen.scale;
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
}
