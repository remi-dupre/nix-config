{ ... }:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "30m";

    matchBlocks = {
      castor.hostname = "castor.dupre.io";
    };
  };

  # TODO: it appears it doesn't work
  services.ssh-agent.enable = true;
}
