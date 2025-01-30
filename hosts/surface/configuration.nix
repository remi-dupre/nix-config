{ pkgs, ... }@inputs:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ../common
    ../common/nextdns.nix
    ./disko-partitioning.nix
    ./hardware-configuration.nix # results of the hardware scan.
  ];

  repo.common = {
    deviceName = "surface";
    gnome.enable = true;
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
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
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
      work.enable = true;

      desktop.display = {
        name = "eDP-1";
        width = 2560;
        height = 1600;
        scale = 1.00;
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
