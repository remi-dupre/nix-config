{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager;
    disko.url = github:nix-community/disko;
    pinix.url = github:remi-dupre/pinix;
  };

  outputs = { self, nixpkgs, pinix, ... }@attrs: {
    nixosConfigurations.cerf = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./hosts/cerf/configuration.nix
      ];
    };
  };
}
