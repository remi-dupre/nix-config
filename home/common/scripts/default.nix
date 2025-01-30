pkgs: rec {
  pkg = {
    gammarelay-sun = pkgs.writers.writePython3Bin
      "gammarelay-sun"
      { libraries = with pkgs.python3Packages; [ astral dbus-python ]; }
      (builtins.readFile ./gammarelay-sun.py);

    notify.sound = pkgs.writeShellApplication {
      name = "notify-sound";
      runtimeInputs = with pkgs; [ pulseaudio dunst ];
      text = (builtins.readFile ./notify-sound.sh);
    };

    notify.micro = pkgs.writeShellApplication {
      name = "notify-micro";
      runtimeInputs = with pkgs; [ pulseaudio dunst ];
      text = (builtins.readFile ./notify-micro.sh);
    };

    notify.brightness = pkgs.writeShellApplication {
      name = "notify-brightness";
      runtimeInputs = with pkgs; [ brightnessctl dunst ];
      text = (builtins.readFile ./notify-brightness.sh);
    };

    screenshot = pkgs.writeShellApplication {
      name = "screenshot";
      runtimeInputs = with pkgs; [ dunst sway-contrib.grimshot wl-clipboard ];
      text = (builtins.readFile ./screenshot.sh);
    };

    update-wallpaper = pkgs.writers.writePython3Bin
      "update-wallpaper"
      { libraries = with pkgs.python3Packages; [ pillow pyyaml ]; }
      (builtins.readFile ./update-wallpaper.py);
  };

  bin = {
    gammarelay-sun = "${pkg.gammarelay-sun}/bin/gammarelay-sun";
    notify.sound = "${pkg.notify.sound}/bin/notify-sound";
    notify.micro = "${pkg.notify.micro}/bin/notify-micro";
    notify.brightness = "${pkg.notify.brightness}/bin/notify-brightness";
    screenshot = "${pkg.screenshot}/bin/screenshot";
    update-wallpaper = "${pkg.update-wallpaper}/bin/update-wallpaper";
  };
}

