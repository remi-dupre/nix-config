{ ... }:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "30m";

    matchBlocks = {
      castor.hostname = "castor.dupre.io";

      dgexsol_ssh_proxy = {
        hostname = "ssh-proxy.dgexsol.fr";
        port = 443;
        user = "jumpuser";
        forwardAgent = true;
      };

      ws-classic-01 = {
        hostname = "classic-01.workspaces.dgexsol.fr";
        user = "9609122y";
        proxyJump = "dgexsol_ssh_proxy";
      };
    };
  };

  services.ssh-agent.enable = true;
}
