{ config, lib, pkgs, ... } @ inputs:

let
  font = import ../../common/fonts.nix inputs;
  cfg = config.repo.desktop;
in

lib.mkIf cfg.enable {
  home = {
    packages = with pkgs; [
      adw-gtk3 # The theme from libadwaita ported to GTK-3
    ];

    sessionVariables.GTK_THEME = "adw-gtk3-dark";
  };

  gtk = {
    enable = true;

    gtk3 = {
      bookmarks = [
        "file:///tmp"
      ];

      # Force straight corners, which works better in tiling mode. Inspired from
      # https://forum.manjaro.org/t/xfce-gtk-and-qt-remove-rounded-corners-using-css/66879
      extraCss = ''
        headerbar {
          border-radius: 0 0 0 0;
        }

        decoration {
          border-radius: 0px;
        }
      '';
    };
  };

  dconf = {
    enable = true;

    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark"; # gtk 4
      font-name = "${font.default} ${toString font.size}";
    };
  };
}
