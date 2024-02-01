{ home-manager, ... }:

{
  imports = [
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "remi";
  system.stateVersion = "23.11";
  home-manager.config = ../../home;
}
