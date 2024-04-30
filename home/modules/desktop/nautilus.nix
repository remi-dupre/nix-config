{ config, pkgs, lib, ... }:

let
  cfg = config.repo.desktop;

  nautEnv = pkgs.buildEnv {
    name = "nautilus-env";

    paths = with pkgs; [
      gnome.nautilus
      gnome.nautilus-python
      nautilus-open-any-terminal
    ];
  };
in

lib.mkIf cfg.enable {
  home = {
    packages = [ nautEnv ];
    sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${nautEnv}/lib/nautilus/extensions-4";
  };

  dconf = {
    enable = true;
    settings."com/github/stunkymonkey/nautilus-open-any-terminal".terminal = "foot";
  };

  programs.python = {
    enable = true;

    libraries = ps: with ps; [
      gst-python

      (buildPythonPackage
        rec {
          pname = "git-nautilus-icons";
          version = "2.1.0";
          src = fetchPypi {
            inherit pname version;
            sha256 = "sha256-P/0AC30PAnX9Xf/6/TsvXj2flUDugDnqBJ/UtYZCBEU=";
          };
        })
    ];
  };
}
