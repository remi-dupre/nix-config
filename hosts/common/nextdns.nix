{ config, lib, ... }:

let
  cfg = config.repo.common;
in

{
  options.repo.common.nextdns = with lib.types; {
    enable = lib.mkOption {
      default = false;
      type = bool;
    };
  };

  config = lib.mkIf cfg.nextdns.enable {
    sops = {
      secrets.nextdns-id = { };

      templates.nextdns-config.content = ''
        profile     ${config.sops.placeholder.nextdns-id}
        forwarder   https://dns.nextdns.io/${config.sops.placeholder.nextdns-id}/${cfg.deviceName}#45.90.28.0
        forwarder   https://dns.nextdns.io/${config.sops.placeholder.nextdns-id}/${cfg.deviceName}#2a07:a8c0::
        forwarder   https://dns.nextdns.io/${config.sops.placeholder.nextdns-id}/${cfg.deviceName}#45.90.30.0
        forwarder   https://dns.nextdns.io/${config.sops.placeholder.nextdns-id}/${cfg.deviceName}#2a07:a8c1::
        cache-size  10MB
      '';
    };

    services.nextdns = {
      enable = true;

      arguments = [
        "-config-file"
        "${config.sops.templates.nextdns-config.path}"
      ];
    };

    # See https://github.com/nextdns/nextdns/issues/699
    systemd.services.nextdns-suspend-hack = {
      enable = true;
      wantedBy = [ "suspend.target" ];

      unitConfig = {
        Description = "Hack to restart nextdns on resume";
        After = "suspend.target";
      };

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        ExecStart = "systemctl restart nextdns";
        TimeoutSec = "0";
        StandardOutput = "syslog";
      };
    };

    networking.nameservers = [
      "127.0.0.1"
      "::1"
    ];
  };
}
