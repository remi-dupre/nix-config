{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager;
    disko.url = github:nix-community/disko;
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.cerf = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./hosts/cerf/configuration.nix ];
    };
  };
}
