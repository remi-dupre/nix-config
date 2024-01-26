{ pkgs, ... } @ inputs:

let
  action = (import ../actions.nix inputs);
in
{
  imports = [
    ./keybindings.nix
  ];

  wayland.windowManager.sway = {
    enable = true;

    wrapperFeatures = {
      base = true;
      gtk = true;
    };

    config = (import ./config.nix inputs);

    extraConfig = ''
      bindswitch --reload --locked lid:on exec ${action.lock}
    '';
  };
}
