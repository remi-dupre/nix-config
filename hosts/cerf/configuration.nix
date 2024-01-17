# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, disko, home-manager, ... }:

{
  imports = [
    home-manager.nixosModules.home-manager
    disko.nixosModules.disko
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./disko-partitioning.nix
  ];

  zramSwap.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware = {
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot

      # Allow to fetch battery level for connected devices
      # https://nixos.wiki/wiki/Bluetooth#Showing_battery_charge_of_bluetooth_devices
      settings.General.Experimental = true;
    };
  };

  fonts = {
    fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [ "NotoSerif Nerd Font" ];
        sansSerif = [ "NotoSans Nerd Font" ];
      };
    };

    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; })
    ];
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true; # recommanded with pipewire

    pam.loginLimits = [
      { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
    ];
  };

  # Docker
  virtualisation.docker.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network
  networking = {
    hostName = "cerf"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.remi = {
    isNormalUser = true;
    description = "Rémi Dupré";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  programs = {
    fish.enable = true;

    nix-ld = {
      enable = true;

      libraries = with pkgs; [
        openssl
      ];
    };

    sway = {
      enable = true;
      extraPackages = [ ];
    };
  };

  services = {
    # Bluetooth pairing management
    blueman.enable = true;

    # Required by xdg portal
    dbus.enable = true;

    # VPN capabilities
    globalprotect.enable = true;

    # Required by nautilus for trash management
    gvfs.enable = true;

    # Required by nautilus for indexing files, see
    # https://discourse.nixos.org/t/after-upgrading-to-23-05-gnome-applications-take-a-long-time-to-start/28900
    gnome.tracker.enable = true;
    gnome.tracker-miners.enable = true;

    # Prevents overheating on Intel CPUs
    thermald.enable = true;

    # Multimedia support
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Session manager
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          # sway is started inside of a shell to load user's env variables
          command = "fish -c sway";
          user = "remi";
        };
        default_session = initial_session;
      };
    };

    # Power management
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    tlp = {
      enable = true;
      settings = {
        # Help save long term battery health
        START_CHARGE_THRESH_BAT0 = 94;
        STOP_CHARGE_THRESH_BAT0 = 98;
        # Device management
        DEVICES_TO_ENABLE_ON_STARTUP = "wifi";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
      };

    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Include homemanager config
  home-manager.users.remi = {
    imports = [ ../../home-manager ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      neovim
      # Dev Libraries
      geos
      gdal
    ];

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
