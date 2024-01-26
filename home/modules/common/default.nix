{ config, pkgs, lib, inputs, ... }:

let
  # Python
  python-packages = (ps: with ps; [
    httpie
    python-lsp-server
    (buildPythonPackage
      rec {
        pname = "httpie-credential-store";
        version = "3.0.0";
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-MfURNdYPatsnKnC6O9dFFCcVFC1SUZ4l33E208rSNis=";
        };
        doCheck = false;
        propagatedBuildInputs = [
          keyring
        ];
      })
  ]);

  # Binaries
  nom = "${pkgs.nix-output-monitor}/bin/nom";

  # Shortcut to update nixos config
  pkg-config-rebuild = pkgs.writeScriptBin "config-rebuild" ''
    nixos-rebuild switch --print-build-logs --log-format internal-json --flake $1 |& ${nom} --json
  '';
in
{
  imports = [
    ./htop.nix
  ];

  home.packages = with pkgs; [
    # Terminal Utilities
    jq
    neovim
    pkg-config-rebuild
    ripgrep
    syncthing
    unzip
    wl-clipboard
    yq
    zip
    # Programming
    cargo
    gcc
    gitleaks
    helm-docs
    openssl
    pkg-config
    (pkgs.wrapHelm pkgs.kubernetes-helm { plugins = [ pkgs.kubernetes-helmPlugins.helm-secrets ]; })
    poetry
    pre-commit
    (python311.withPackages python-packages)
    rnix-lsp
    ruff
    ruff-lsp
    sops
    yaml-language-server
  ];
}
