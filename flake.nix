{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager;
    disko.url = github:nix-community/disko;
    pinix.url = github:remi-dupre/pinix;

    nix-on-droid = {
      url = "github:remi-dupre/nix-on-droid/4eac7c468941fb14665a8e2423322a85faf40d8f";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-on-droid, ... } @ attrs: {
    nixosConfigurations = {
      cerf = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [ ./hosts/cerf/configuration.nix ];
      };

      fp3 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = attrs;
        modules = [ ./hosts/fp3/configuration.nix ];
      };
    };

    nixOnDroidConfigurations.fp3 = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [ ./hosts/fp3/configuration.nix ];
    };
  };
}
