{ config, lib, pkgs, ... } @ inputs:

let
  bin = import ../../common/binaries.nix inputs;
  font = import ../../common/fonts.nix inputs;
in

{
  imports = [
    ./foot.nix
    ./gtk.nix
    ./nautilus.nix
  ];

  options.desktop = {
    display = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.string;
          };

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
        # Custom packages
        font.pkg

        # Terminal utilities
        xdg-utils # A set of command line tools that assist applications wit...

        # Desktop Applications
        evince # GNOME's document viewer
        gimp # The GNU Image Manipulation Program
        gnome.file-roller # Archive manager for the GNOME desktop environment
        libreoffice # Comprehensive, professional-quality productivity suite...
        loupe # A simple image viewer application written with GTK4 and Rust
        pavucontrol # PulseAudio Volume Control
        qgis # A Free and Open Source Geographic Information System
        signal-desktop # Private, simple, and secure messenger
        vlc # Cross-platform media player and streaming server
        wdisplays # A graphical application for configuring displays in Wayl...
        wl-gammarelay-rs # A simple program that provides DBus interface to ...
      ];

      # Workarround for wayland on electron apps. See
      # https://nixos.wiki/wiki/Wayland
      sessionVariables.NIXOS_OZONE_WL = "1";

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

    # A web browser built from Firefox source tree
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };
  };
}
