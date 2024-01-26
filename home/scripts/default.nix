{ pkgs, ... } @ inputs:

{
  notify = {
    sound =
      let pkg = pkgs.writeShellApplication {
        name = "notify-sound";
        runtimeInputs = with pkgs; [ pulseaudio dunst ];
        text = (builtins.readFile ./notify-sound.sh);
      };
      in "${pkg}/bin/notify-sound";

    micro =
      let pkg = pkgs.writeShellApplication {
        name = "notify-micro";
        runtimeInputs = with pkgs; [ pulseaudio dunst ];
        text = (builtins.readFile ./notify-micro.sh);
      };
      in "${pkg}/bin/notify-micro";

    brightness =
      let pkg = pkgs.writeShellApplication {
        name = "notify-brightness";
        runtimeInputs = with pkgs; [ brightnessctl dunst ];
        text = (builtins.readFile ./notify-brightness.sh);
      };
      in "${pkg}/bin/notify-brightness";
  };

  screenshot =
    let pkg = pkgs.writeShellApplication {
      name = "screenshot";
      runtimeInputs = with pkgs; [ dunst sway-contrib.grimshot wl-clipboard ];
      text = (builtins.readFile ./screenshot.sh);
    };
    in "${pkg}/bin/screenshot";

  update-wallpaper = pkgs.writers.writePython3
    "update-wallpaper"
    { libraries = with pkgs.python3Packages; [ pillow pyyaml ]; }
    (builtins.readFile ./update-wallpaper.py);
}
