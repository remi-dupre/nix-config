{ ... } @ inputs:

let
  secrets = import ./secrets.nix;
in

{
  users = {
    groups.cntlm = { };
    users.cntlm.group = "cntlm";
  };

  services.cntlm = {
    enable = true;
    port = [ 3128 ];
    username = "9609122Y";
    domain = "commun.ad.sncf.fr";
    noproxy = [ "localhost" "127.0.0.*" "10.*" "192.168.*" ];
    password = ""; # allow to input hashed password

    proxy = [
      "web-lyon4.sncf.fr:8080"
      "web-lyon5.sncf.fr:8080"
      "web-lyon6.sncf.fr:8080"
      "web-pa-1.sncf.fr:8080"
      "web-pa-2.sncf.fr:8080"
    ];

    extraConfig = ''
      Tunnel 127.0.0.1:11443:ssh-proxy.dgexsol.fr:443
      ${secrets.sncf-cntlm-password}
    '';
  };

  networking.proxy.default = "http://localhost:3128";
}
