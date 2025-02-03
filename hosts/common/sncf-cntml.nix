{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.proxy.default = "http://localhost:3128";
  sops.secrets.cntlm-config.owner = "cntlm";

  users = {
    groups.cntlm = { };
    users.cntlm.group = "cntlm";
  };

  services.cntlm = {
    enable = true;
    domain = "foo";
    username = "foo";
    proxy = [ ];
  };

  systemd.services = {
    cntlm.serviceConfig.ExecStart = lib.mkForce "${pkgs.cntlm}/bin/cntlm -U cntlm -c ${config.sops.secrets.cntlm-config.path} -v -f";
    nix-daemon.environment.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };
}
