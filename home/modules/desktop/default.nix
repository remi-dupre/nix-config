{
  config,
  lib,
  pkgs,
  ...
}@inputs:

let
  bin = import ../../common/binaries.nix inputs;
  font = import ../../common/fonts.nix inputs;
  cfg = config.repo.desktop;
in

{
  imports = [
    ./gnome/default.nix
    ./foot.nix
    ./gammarelay.nix
    ./gtk.nix
    ./nautilus.nix
  ];

  options.repo.desktop = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    display = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
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

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        [ font.pkg ]
        ++ (with pkgs; [
          # Terminal utilities
          xdg-utils # A set of command line tools that assist applications wi...
          # Desktop Applications
          evince # GNOME's document viewer
          file-roller # Archive manager for the GNOME desktop environment
          foliate # A simple and modern GTK eBook reader
          gimp # The GNU Image Manipulation Program
          inkscape # Vector graphics editor
          krita # Free and open source painting application
          libreoffice # Comprehensive, professional-quality productivity suit...
          loupe # A simple image viewer application written with GTK4 and Rus
          organicmaps # Detailed Offline Maps for Travellers, Tourists, Hiker...
          pavucontrol # PulseAudio Volume Control
          qgis # A Free and Open Source Geographic Information System
          rawtherapee # RAW converter and digital photo processing software
          signal-desktop # Private, simple, and secure messenger
          simple-scan # Simple scanning utility
          vlc # Cross-platform media player and streaming server
          wdisplays # A graphical application for configuring displays in Way...
          wl-gammarelay-rs # A simple program that provides DBus interface to...
        ]);

      # Workarround for wayland on electron apps. See
      # https://nixos.wiki/wiki/Wayland
      sessionVariables.NIXOS_OZONE_WL = "1";

      pointerCursor = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 16;

        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };

      file = {
        # TODO: sway-specific
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

      mimeApps = {
        enable = true;

        defaultApplications =
          let
            browser = "firefox-devedition.desktop";
            image-viewer = "org.gnome.Loupe.desktop";
          in
          {
            "text/html" = browser;
            "x-scheme-handler/http" = browser;
            "x-scheme-handler/https" = browser;
            "x-scheme-handler/about" = browser;
            "x-scheme-handler/unknown" = browser;
            "application/pdf" = "org.gnome.Evince.desktop";
            "text/csv" = "nvim.desktop";
            "image/jpeg" = image-viewer;
            "image/png" = image-viewer;
            "image/svg+xml" = image-viewer;
          };
      };

    };

    # A web browser built from Firefox source tree
    programs = {
      firefox = {
        enable = true;
        package = pkgs.firefox-devedition;
      };
    };

    # An open source web browser from Google, with dependencies on Google web services removed
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    # Whether to enable Syncthing continuous file synchronization
    services.syncthing.enable = true;
  };
}
