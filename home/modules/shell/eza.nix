{ ... }:

{
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };
}
