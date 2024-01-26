{ pkgs, ... } @ inputs:

with pkgs; {
  blueman-manager = "${blueman}/bin/blueman-manager";
  bluetoothctl = "${bluez}/bin/bluetoothctl";
  brightnessctl = "${brightnessctl}/bin/brightnessctl";
  dunstify = "${dunst}/bin/dunstify";
  firefox = "${firefox-devedition}/bin/firefox-devedition";
  pacmd = "${pulseaudio}/bin/pacmd";
  pactl = "${pulseaudio}/bin/pactl";
  playerctl = "${playerctl}/bin/playerctl";
  rofi = "${rofi-wayland}/bin/rofi";
  rofimoji = "${rofimoji}/bin/rofimoji";
  wl-paste = "${wl-clipboard}/bin/wl-paste";
}
