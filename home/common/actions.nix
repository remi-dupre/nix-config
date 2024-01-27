{ lib, pkgs, ... } @ inputs:

let
  bin = (import ./binaries.nix inputs);
in
{
  lock = lib.strings.concatStringsSep " && " [
    "sudo -K"
    "ssh-add -D"
    "gpgconf --reload gpg-agent"
    "swaylock"
  ];

  micro = {
    mute = op: "${bin.pactl} set-source-mute @DEFAULT_SOURCE@ ${op}"; # op is toggle / off
    volume = op: "${bin.pactl} set-source-volume @DEFAULT_SOURCE@ ${op}"; # op is +5% / -5%
  };

  sample = op:
    "pw-play ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/${op}.oga";

  sound = {
    mute = op: "${bin.pactl} set-sink-mute @DEFAULT_SINK@ ${op}"; # op is toggle / off
    volume = op: "${bin.pactl} set-sink-volume @DEFAULT_SINK@ ${op}"; # op is +5% / -5%
  };
}
