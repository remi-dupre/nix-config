{
  config,
  lib,
  pkgs,
  pinix,
  ...
}@inputs:

let
  cfg = config.repo.common;
in

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    ./gnome.nix
    ./nextdns.nix
  ];

  options.repo.common = with lib; {
    deviceName = mkOption {
      type = types.str;
    };
  };

  config = {
    networking.hostName = cfg.deviceName;

    # Secrets management
    sops = {
      age.keyFile = "/home/remi/.age-key.txt";
      defaultSopsFile = ../../secrets/system.yaml;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.remi = {
      isNormalUser = true;
      description = "Rémi Dupré";
      shell = pkgs.fish;

      extraGroups = [
        "adbusers"
        "docker"
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
      ];
    };

    # System packages
    environment = {
      systemPackages = with pkgs; [
        neovim
        pinix.packages.x86_64-linux.pinix
        # Dev Libraries
        geos # C/C++ library for computational geometry with a focus on algori...
        gdal # Translator library for raster geospatial data formats
        zlib # Lossless data-compression library
      ];

      variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

    # Nix
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # Override existing files from home
    home-manager = {
      backupFileExtension = "hm-backup";

      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
    };

    # Docker
    virtualisation.docker.enable = true;
    systemd.services.docker.wantedBy = lib.mkForce [ ]; # disable by default

    # Bootloader
    boot = {
      tmp.useTmpfs = true;

      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    # Localization
    console.keyMap = "fr";
    time.timeZone = "Europe/Paris";

    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
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
    };
  };
}
