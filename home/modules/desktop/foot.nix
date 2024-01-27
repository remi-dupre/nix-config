{ pkgs, ... } @ inputs:

let
  font = import ../../common/fonts.nix inputs;
in

{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        term = "xterm-256color";
        font = "${font.monospace}:size=${toString font.size}";
        include = "${pkgs.foot.themes}/share/foot/themes/kitty";
        box-drawings-uses-font-glyphs = true;
        pad = "4x4";
      };

      bell = {
        urgent = "yes";
        visual = true;
        command = "dunstify -t 5000 -u low -a \"\${app-id}\" \"\${title}\" \"\${body}\"";
      };

      mouse = {
        hide-when-typing = " yes ";
      };

      scrollback = {
        lines = 10000;
        multiplier = 5.0;
      };

      url = {
        label-letters = "qsdfghjklmwxcvbn";
      };
    };
  };
}
