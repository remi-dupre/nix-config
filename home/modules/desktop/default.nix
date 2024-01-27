{ config, lib, pkgs, ... } @ inputs:

let
  bin = import ../../common/binaries.nix inputs;
  font = import ../../common/fonts.nix inputs;
in

{
  imports = [
    ./foot.nix
  ];

  options.desktop = {
    screen = lib.mkOption {
      type = lib.types.submodule {
        options = {
          width = lib.mkOption {
            type = lib.types.int;
          };

          height = lib.mkOption {
            type = lib.types.int;
          };

          scale = lib.mkOption {
            type = lib.types.float;
            default = 1.2;
          };
        };
      };
    };
  };

  config = {
    home = {
      packages = with pkgs; [
        adw-gtk3 # The theme from libadwaita ported to GTK-3
        font.pkg
        xdg-utils # A set of command line tools that assist applications with a variety of desktop integration tasks

        # Desktop Applications
        evince # GNOME's document viewer
        gimp # The GNU Image Manipulation Program
        gnome.file-roller # Archive manager for the GNOME desktop environment
        gnome.nautilus # The file manager for GNOME
        libreoffice # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
        loupe # A simple image viewer application written with GTK4 and Rust
        pavucontrol # PulseAudio Volume Control
        qgis # A Free and Open Source Geographic Information System
        signal-desktop # Private, simple, and secure messenger
        wdisplays # A graphical application for configuring displays in Wayland compositors
      ];

      sessionVariables = {
        GTK_THEME = "adw-gtk3-dark";
        NIXOS_OZONE_WL = "1"; # See https://nixos.wiki/wiki/Wayland
      };

      pointerCursor = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 16;

        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };

      file = {
        ".config/rofi".source = ../../static/config/rofi;
      };
    };

    xdg = {
      # Replace nvim's desktop entry to be opened with foot
      desktopEntries.nvim = {
        name = "NeoVim";
        exec = "${bin.foot} ${bin.nvim} %F";
        type = "Application";
        icon = "nvim";

        mimeType = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
      };

      userDirs = {
        enable = true;
        desktop = "/tmp";
        documents = "${config.home.homeDirectory}/documents";
        download = "${config.home.homeDirectory}/downloads";
        music = null;
        pictures = null;
        videos = null;
      };
    };

    gtk.gtk3.bookmarks = [
      "/tmp"
      "${config.home.homeDirectory}/documents"
      "${config.home.homeDirectory}/downloads"
    ];

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark"; # gtk 4
        font-name = "${font.default} ${toString font.size}";
      };
    };
  };
}
