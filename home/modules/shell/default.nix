{ lib, pkgs, ... } @ inputs:

let
  script = (import ../../common/scripts inputs);

  pkg-helm = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      pkgs.kubernetes-helmPlugins.helm-secrets
    ];
  };

  pkg-python = pkgs.python3.withPackages (ps: with ps; [
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
in

{
  imports = [
    ./eza.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./htop.nix
    ./ssh.nix
  ];

  home = {
    shellAliases = {
      l = "ll";
      utnm = "poetry run -C ~/code/libraries/utnm utnm";
      vim = "nvim";
    };

    sessionVariables = {
      # Required for some Python libraries to work
      # See https://discourse.nixos.org/t/how-to-solve-libstdc-not-found-in-shell-nix/25458/15
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    };
  };

  programs = {
    bat.enable = true; # A cat(1) clone with syntax highlighting and Git integration
    direnv.enable = true; # A shell extension that manages your environment
    nix-index.enable = true; # A files database for nixpkgs

    # A web browser built from Firefox source tree
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };
  };

  home.packages = with pkgs; [
    # Terminal Utilities
    fd # A simple, fast and user-friendly alternative to find
    jq # A lightweight and flexible command-line JSON processor
    neovim # Vim text editor fork focused on extensibility and agility
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    script.pkg.config-rebuild # Shorcut to rebuild NixOS configuration
    syncthing # Open Source Continuous File Synchronization
    unzip # An extraction utility for archives compressed in .zip format
    wl-clipboard # Command-line copy/paste utilities for Wayland
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
    zip # Compressor/archiver for creating and modifying zipfiles

    # Programming
    cargo # Downloads your Rust project's dependencies and builds your project
    gcc # GNU Compiler Collection (wrapper script)
    gitleaks # Scan git repos (or files) for secrets
    helm-docs # A tool for automatically generating markdown documentation for Helm charts
    openssl # A cryptographic library that implements the SSL and TLS protocols
    pkg-config # A tool that allows packages to find out information about other packages (wrapper script)
    pkg-helm # A package manager for kubernetes
    pkg-python # A high-level dynamically-typed programming language
    poetry # Python dependency management and packaging made easy
    pre-commit # A framework for managing and maintaining multi-language pre-commit hooks
    ruff # An extremely fast Python linter

    # IDE Integration
    rnix-lsp # A work-in-progress language server for Nix, with syntax checking and basic completion
    nixd # Nix language server
    ruff-lsp # A Language Server Protocol implementation for Ruff
    yaml-language-server # Language Server for YAML Files
  ];
}
