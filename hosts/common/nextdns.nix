{ config, ... }:

let
  cfg = config.common;
  secrets = import ./secrets.nix;
in

{
  services.resolved = {
    enable = true;
    dnsovertls = "true";
  };

  # TODO: configurable name
  networking.nameservers = [
    "45.90.28.0#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
    "2a07:a8c0::#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
    "45.90.30.0#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
    "2a07:a8c1::#${cfg.deviceName}-${secrets.nextdns-id}.dns.nextdns.io"
  ];
}
