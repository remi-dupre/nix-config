{ pkgs, ... }@inputs:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ../common/base.nix
    ./disko-partitioning.nix
    ./hardware-configuration.nix # results of the hardware scan.
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true;
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
      (nerdfonts.override {
        fonts = [
          "FiraMono"
          "Noto"
        ];
      })
    ];
  };

  # Network
  networking = {
    hostName = "surface";

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

        display = {
          name = "eDP-1";
          width = 2560;
          height = 1600;
          scale = 1.00;
        };
      };
    };
  };

  # This value determines the NixOS release from which the default settings for
  # stateful data, like file locations and database versions on your system
  # were taken. It‘s perfectly fine and recommended to leave this value at the
  # release version of the first install of this system. Before changing this
  # value read the documentation for this option (e.g. man configuration.nix or
  # on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
