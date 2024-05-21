{ lib, pkgs, ... } @ inputs:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.home-manager.nixosModules.home-manager
    ./common/sncf-cntml.nix
    ./common/sncf-certs.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "remi";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    systemPackages = (with pkgs; [
      neovim
      # Dev Libraries
      geos
      gdal
      zlib # Lossless data-compression library
    ]) ++ [
      inputs.pinix.packages.x86_64-linux.pinix
    ];

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.remi = {
    isNormalUser = true;
    description = "Rémi Dupré";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
  };

  # Include homemanager config
  home-manager.users.remi = {
    imports = [ ../home ];
    repo.work = {
      enable = true;
      proxy.enable = true;
    };
  };

  programs = {
    fish.enable = true;
    ssh.startAgent = true;

    nix-ld = {
      enable = true;

      libraries = with pkgs; [
        openssl # A cryptographic library that implements the SSL and TLS protocols
        zlib # Lossless data-compression library
      ];
    };
  };

  # Docker
  virtualisation.docker.enable = true;

  # Disabled services
  systemd.services.docker.wantedBy = lib.mkForce [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

