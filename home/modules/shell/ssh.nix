{ ... }:

{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "30m";

    matchBlocks = {
      castor.hostname = "castor.dupre.io";
    };
  };
}
