{ config, pkgs, ... }:

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
    bat.enable = true; # A cat(1) clone with syntax highlighting and Git int...
    direnv.enable = true; # A shell extension that manages your environment
    nix-index.enable = true; # A files database for nixpkgs

    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = [ "--disable-up-arrow" ];

      settings = {
        key_path = config.sops.secrets.atuin-key.path;
        sync_frequency = "5m";
        sync.records = true;
      };
    };

    python = {
      enable = true;

      libraries =
        ps: with ps; [
          httpie
          python-lsp-server

          (buildPythonPackage rec {
            pname = "httpie-credential-store";
            version = "3.0.0";
            src = fetchPypi {
              inherit pname version;
              sha256 = "sha256-MfURNdYPatsnKnC6O9dFFCcVFC1SUZ4l33E208rSNis=";
            };
            doCheck = false;
            propagatedBuildInputs = [ keyring ];
          })
        ];
    };

    tmux = {
      enable = true;
      mouse = true;
    };
  };

  home.packages = with pkgs; [
    # Terminal Utilities
    fd # A simple, fast and user-friendly alternative to find
    ffmpeg-full # A complete, cross-platform solution to record, convert and...
    jq # A lightweight and flexible command-line JSON processor
    killall # Kill processes by name
    neovim # Vim text editor fork focused on extensibility and agility
    ripgrep # A utility that combines the usability of The Silver Searcher w...
    unzip # An extraction utility for archives compressed in .zip format
    wl-clipboard # Command-line copy/paste utilities for Wayland
    yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML
    zip # Compressor/archiver for creating and modifying zipfiles

    # Programming
    cargo-audit # Audit Cargo.lock files for crates with security vulnerabil...
    cargo-bloat # A tool and Cargo subcommand that helps you find out what t...
    cargo-fuzz # Command line helpers for fuzzing
    cargo-nextest # Next-generation test runner for Rust projects
    cargo-outdated # A cargo subcommand for displaying when Rust dependencie...
    cargo-tarpaulin # A code coverage tool for Rust projects
    cargo-udeps # Find unused dependencies in Cargo.toml
    gcc # GNU Compiler Collection (wrapper script)
    gitleaks # Scan git repos (or files) for secrets
    nodePackages.prettier # Prettier is an opinionated code formatter
    openssl # A cryptographic library that implements the SSL and TLS protocols
    pkg-config # A tool that allows packages to find out information about o...
    pre-commit # A framework for managing and maintaining multi-language pre...
    ruff # An extremely fast Python linter
    rustup # The Rust toolchain installer

    # IDE Integration
    lua-language-server # A language server that offers Lua language support
    nixd # Nix language server
    nixfmt-rfc-style # Official formatter for Nix code
    ruff-lsp # A Language Server Protocol implementation for Ruff
    yaml-language-server # Language Server for YAML Files

    # Poetry : Python dependency management and packaging made easy
    (poetry.withPlugins (p: [
      p.poetry-audit-plugin # Poetry plugin for checking security vulnerabil...
      p.poetry-plugin-up # Poetry plugin to simplify package updates
    ]))
  ];
}
