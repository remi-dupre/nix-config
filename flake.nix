{
  inputs = {
    disko.url = "github:nix-community/disko";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    pinix.url = "github:remi-dupre/pinix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:remi-dupre/nix-on-droid/4eac7c468941fb14665a8e2423322a85faf40d8f";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-on-droid,
      ...
    }@attrs:
    {
      nixosConfigurations = {
        cerf = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [ ./hosts/cerf/configuration.nix ];
        };

        sncf = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [ ./hosts/sncf.nix ];
        };

        surface = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [ ./hosts/surface/configuration.nix ];
        };
      };

      homeConfigurations = {
        deck = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = attrs;
          modules = [ ./hosts/deck.nix ];
        };
      };

      nixOnDroidConfigurations.fp3 = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [ ./hosts/fp3.nix ];
      };
    };
}
