{ config, lib, pkgs, ... }:

let
  cfg = config.programs.python;
in

{
  options.programs.python = with lib.types; {
    enable = lib.mkOption {
      default = false;
      type = types.bool;
    };

    libraries = lib.mkOption {
      type = functionTo (listOf package);
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.python3.withPackages cfg.libraries)
    ];
  };
}
