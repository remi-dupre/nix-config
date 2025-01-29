{ pkgs, ... }@inputs:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ../common/base.nix
    ../common/nextdns.nix
    ./disko-partitioning.nix
    ./hardware-configuration.nix # results of the hardware scan.
  ];

  # As the surface hardware configuration may build a patched version of the
  # Kernel which is not cached, using /tmp might result in memory shortage
  # while building configuration.
  environment = {
    # systemPackages = with pkgs; [
    #   libwacom-surface # Libraries, configuration, and diagnostic tools for W...
    # ];

    gnome.excludePackages = with pkgs; [
      baobab # Graphical application to analyse disk usage in any GNOME envir...
      epiphany # WebKit based web browser for GNOME
      geary # Mail client for GNOME 3
      gnome-backgrounds # Default wallpaper set for GNOME
      gnome-characters # Simple utility application to find and insert unusua...
      gnome-connections # Remote desktop client for the GNOME desktop environ...
      gnome-console # Simple user-friendly terminal emulator for the GNOME de...
      gnome-contacts # GNOME’s integrated address book
      gnome-disk-utility # Udisks graphical front-end
      gnome-extension-manager # Desktop app for managing GNOME shell extensions
      gnome-font-viewer # Program that can preview fonts and create thumbnail...
      gnome-logs # Log viewer for the systemd journal
      gnome-music # Music player and management application for the GNOME des...
      gnome-shell-extensions # Modify and extend GNOME Shell functionality an...
      gnome-software # Software store that lets you install and update applic...
      gnome-system-monitor # System Monitor shows you what programs are runni...
      gnome-terminal # GNOME Terminal Emulator
      gnome-tour # GNOME Greeter & Tour
      gnome-user-docs # User and system administration help for the GNOME des...
      orca # A free, open source, flexible and extensible screen reader that ...
      seahorse # Application for managing encryption keys and passwords in th...
      snapshot # Take pictures and videos on your computer, tablet, or phone ...
      sushi # Quick previewer for Nautilus
      sysprof # System-wide profiler for Linux
      totem # Movie player for the GNOME desktop based on GStreamer
      yelp # Help viewer in Gnome
    ];
  };

  services = {
    flatpak.enable = true;
    nextdns.enable = true; # TODO: common?

    # beesd.filesystems.root = {
    #   spec = "/";
    #   verbosity = "crit";
    #
    #   extraOptions = [
    #     "--thread-count"
    #     "1"
    #   ];
    # };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      wacom.enable = true;
    };
  };

  zramSwap.enable = true;

  hardware = {
    sane.enable = true; # enables support for SANE scanners

    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot

      # Allow to fetch battery level for connected devices
      # https://nixos.wiki/wiki/Bluetooth#Showing_battery_charge_of_bluetooth_devices
      settings.General.Experimental = true;
    };
  };

  # Network
  networking = {
    hostName = "surface";

    # # TODO: common?
    # nameservers = [
    #   "45.90.28.25" # NextDNS
    #   "45.90.30.25" # NextDNS
    # ];

    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.remi = {
    isNormalUser = true;
    description = "Rémi Dupré";
    extraGroups = [
      "adbusers"
      "docker"
      "networkmanager"
      "wheel"
      "scanner"
      "lp"
    ];
    shell = pkgs.fish;
  };

  programs = {
    fish.enable = true;

    nix-ld = {
      enable = true;

      libraries = with pkgs; [
        openssl # A cryptographic library that implements the SSL and TLS protocols
        zlib # Lossless data-compression library
      ];
    };

    sway = {
      enable = true;
      extraPackages = [ ];
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  # Include homemanager config
  home-manager.users.remi = {
    imports = [ ../../home ];

    repo = {
      games.enable = true;
      sway.enable = true;
      work.enable = true;

      desktop = {
        enable = true;
        gnome.enable = true;

        display = {
          name = "eDP-1";
          width = 2560;
          height = 1600;
          scale = 1.00;
        };
      };
    };
  };

  # Init after install with `sudo waydroid init -f`
  virtualisation.waydroid.enable = true;

  # This value determines the NixOS release from which the default settings for
  # stateful data, like file locations and database versions on your system
  # were taken. It‘s perfectly fine and recommended to leave this value at the
  # release version of the first install of this system. Before changing this
  # value read the documentation for this option (e.g. man configuration.nix or
  # on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
