{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
  inputs.home-manager.url = github:nix-community/home-manager/release-23.11;

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.chamois = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
