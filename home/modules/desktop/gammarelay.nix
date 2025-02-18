{ config, lib, pkgs, ... }:

let
  bin = import ../../common/binaries.nix pkgs;
  script = import ../../common/scripts pkgs;
  cfg = config.repo.desktop;
in

lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    wl-gammarelay-rs
  ];

  systemd.user.services = {
    wl-gammarelay = {
      Unit.Description = (
        "A simple program that provides DBus interface to control display "
        + "temperature and brightness under wayland without flickering"
      );

      Service = {
        Type = "dbus";
        BusName = "rs.wl-gammarelay";
        ExecStart = "${bin.wl-gammarelay-rs}";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    gammarelay-sun = {
      Unit = {
        Description = "Control wl-gammarelay-rs depending on sun position.";
        After = [ "wl-gammarelay.service" ];
      };

      Service.ExecStart = "${script.bin.gammarelay-sun}";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
