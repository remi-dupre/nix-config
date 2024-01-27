{ pkgs, ... }:

rec {
  pkg = pkgs.nerdfonts.override {
    fonts = [
      "FiraMono"
      "Noto"
    ];
  };

  directory = "${pkg}/share/fonts/truetype/NerdFonts";
  default = "NotoSans Nerd Font";
  compact = "NotoSans Nerd Font SemiCondensed";
  monospace = "FiraMono Nerd Font";
  size = 10.0;
}
