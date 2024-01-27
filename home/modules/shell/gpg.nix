{ ... }:

{
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200; # 2h
    pinentryFlavor = "curses";
  };
}
