{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2 # Unified tool to manage your AWS services
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

      # Proxy used for workspace connexion
      dgexsol_ssh_proxy = {
        hostname = "ssh-proxy.dgexsol.fr";
        port = 443;
        user = "jumpuser";
        forwardAgent = true;
      };

      # Workspace
      ws-classic-01 = {
        hostname = "classic-01.workspaces.dgexsol.fr";
        user = "9609122y";
        proxyJump = "dgexsol_ssh_proxy";
      };
    };
  };
}
