{ config, lib, pkgs, ... }:

let
  cfg = config.repo.work;
  ssh-proxy = "ssh-proxy.dgexsol.fr";
in

{

  options.repo.work = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    proxy.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2 # Unified tool to manage your AWS services
      helm-docs # A tool for automatically generating markdown documentation f...
      helm-ls #  A nix-shell will temporarily modify your $PATH environment va...
      kubernetes-helm # A package manager for kubernetes
      sops # Simple and flexible tool for managing secrets
    ];

    programs.ssh = {
      matchBlocks = {
        # Networking policy occasionally breaks port 22
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };

        # Networking policy occasionally breaks port 22
        "gitlab.com" = {
          hostname = "altssh.gitlab.com";
          port = 443;
        };


        # Workspace
        ws-classic-01 = {
          hostname = "classic-01.workspaces.dgexsol.fr";
          user = "9609122y";
          proxyJump = ssh-proxy;
        };
      } // (
        if cfg.proxy.enable then {
          # The SSH proxy through a tunnel provided by cntml
          "${ssh-proxy}" = {
            hostname = "127.0.0.1";
            port = 11443;
            user = "jumpuser";
            forwardAgent = true;
          };

          # Proxy every SSH connexion through dgexsol's proxy
          "* !ssh-proxy.dgexsol.fr" = {
            proxyJump = ssh-proxy;
          };
        }
        else {
          "${ssh-proxy}" = {
            port = 443;
            user = "jumpuser";
            forwardAgent = true;
          };
        }
      );
    };
  };
}
