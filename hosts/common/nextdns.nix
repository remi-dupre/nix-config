{ config, lib, ... }:

let
  cfg = config.repo.common;
  secrets = import ./secrets.nix;
in

{
  options.repo.common.nextdns = with lib.types; {
    enable = lib.mkOption {
      default = false;
      type = bool;
    };
  };

  config = lib.mkIf cfg.nextdns.enable {
    services.resolved = {
      enable = true;
      dnsovertls = "true";
    };

    networking.nameservers = [
      "45.90.28.0#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
      "2a07:a8c0::#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
      "45.90.30.0#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
      "2a07:a8c1::#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
    ];
  };
}
