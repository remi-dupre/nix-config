{ config, lib, pkgs, ... }:

let
  action = import ../../../common/actions.nix pkgs;
  bin = import ../../../common/binaries.nix pkgs;
  script = import ../../../common/scripts pkgs;
  cfg-display = config.repo.desktop.display;
  modifier = "Mod4";
in

lib.mkIf config.repo.desktop.sway.enable {
  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      # Application shortcuts
      "${modifier}+l" = "exec ${action.lock}";
      "Control+Mod1+t" = "exec foot";
      "Control+Mod1+d" = "exec nautilus -w";
      "Control+Mod1+f" = "exec ${bin.firefox}";
      "Control+Shift+p" = "exec ${bin.firefox} --private-window";
      "Control+Mod1+s" = "exec pavucontrol";
      "Control+Mod1+b" = "exec ${bin.bluetoothctl} power on && ${bin.blueman-manager}";

      # Close window
      "Mod1+F2" = "exec ${bin.rofi} -theme ~/.config/rofi/drun.rasi -show";
      "Mod1+c" = "exec ${bin.rofimoji} -f 'emojis_*' 'mathematical_*' 'miscellaneous_symbols_and_arrows' --hidden-description --selector-args '-theme rofimoji'";
      "Mod1+F4" = "kill";

      # Screenshot
      "Print" = ''exec ${script.bin.screenshot} "screen" && ${action.sample "camera-shutter"}'';
      "Shift+Print" = ''exec ${script.bin.screenshot} "area" && ${action.sample "camera-shutter"}'';
      "Control+Print" = ''exec ${script.bin.screenshot} "window" && ${action.sample "camera-shutter"}'';

      # Sound
      "XF86AudioRaiseVolume" = "exec '${action.sound.mute "off"} & ${action.sound.volume "+5%"} & ${script.bin.notify.sound} & ${action.sample "audio-volume-change"}'";
      "XF86AudioLowerVolume" = "exec '${action.sound.mute "off"} & ${action.sound.volume "-5%"} & ${script.bin.notify.sound} & ${action.sample "audio-volume-change"}'";
      "XF86AudioMute" = "exec '${action.sound.mute "toggle"} & ${script.bin.notify.sound} & ${action.sample "audio-volume-change"}'";

      # Microphone
      "Shift+XF86AudioRaiseVolume" = "exec '${action.micro.mute "off"} & ${action.micro.volume "+5%"} & ${script.bin.notify.micro}'";
      "Shift+XF86AudioLowerVolume" = "exec '${action.micro.mute "off"} & ${action.micro.volume "-5%"} & ${script.bin.notify.micro}'";
      "Shift+XF86AudioMute" = "exec '${action.micro.mute "toggle"}; ${script.bin.notify.micro}'";

      # MPD Control
      "xf86audioplay" = "exec ${bin.playerctl} play-pause";
      "xf86audionext" = "exec ${bin.playerctl} next";
      "xf86audioprev" = "exec ${bin.playerctl} prev";
      "xf86audiostop" = "exec ${bin.playerctl} stop";

      # Brightness
      "XF86MonBrightnessUp" = "exec '${bin.brightnessctl} set 5%+ && ${script.bin.notify.brightness}'";
      "XF86MonBrightnessDown" = "exec '${bin.brightnessctl} set 5%- && ${script.bin.notify.brightness}'";

      # Rebuild config and reload
      "${modifier}+Shift+r" = "swaymsg reload";

      # Always on top window
      "${modifier}+w" = "sticky toggle";

      # Stick and resize
      "${modifier}+Shift+w" =
        let
          ratio = 0.20;
          margin = 25;
          width = builtins.floor (ratio * cfg-display.width);
          height = builtins.floor (width * 9 / 16);
          pos-x = builtins.floor (cfg-display.width / cfg-display.scale - width - margin);
        in
        lib.strings.concatStringsSep " ; " [
          "floating enable; sticky enable"
          "resize set ${toString width} ${toString height}"
          "move position ${toString pos-x} ${toString margin}"
        ];

      # Handle sleep key (if not managed by /etc/systemd/logind.conf)
      "XF86Sleep" = "exec systemctl suspend-then-hibernate";

      # Shutdown button
      "XF86PowerOff" = "exec shutdown -h now";

      # Change focus
      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";
      "${modifier}+Tab" = "focus next";
      "${modifier}+Shift+Tab" = "focus prev";

      # Move focused window
      "${modifier}+Shift+Left" = "move left";
      "${modifier}+Shift+Down" = "move down";
      "${modifier}+Shift+Up" = "move up";
      "${modifier}+Shift+Right" = "move right";

      # Split in horizontal orientation
      "${modifier}+h" = "split h";

      # Split in vertical orientation
      "${modifier}+v" = "split v";

      # Enter fullscreen mode for the focused container
      "${modifier}+f" = "fullscreen toggle";

      # Change container layout (stacked, tabbed, toggle split)
      "${modifier}+s" = "layout stacking";
      "${modifier}+z" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";

      # Toggle tiling / floating
      "${modifier}+Shift+space" = "floating toggle";

      # Change focus between tiling / floating windows
      "${modifier}+space" = "focus mode_toggle";

      # Focus the parent container
      "${modifier}+q" = "focus parent";

      # Focus the child container
      "${modifier}+d" = "focus child";

      # Switch to workspace
      "${modifier}+ampersand" = "workspace number 1";
      "${modifier}+eacute" = "workspace number 2";
      "${modifier}+quotedbl" = "workspace number 3";
      "${modifier}+apostrophe" = "workspace number 4";
      "${modifier}+parenleft" = "workspace number 5";
      "${modifier}+minus" = "workspace number 6";
      "${modifier}+egrave" = "workspace number 7";
      "${modifier}+underscore" = "workspace number 8";
      "${modifier}+ccedilla" = "workspace number 9";
      "${modifier}+agrave" = "workspace number 10";
      "${modifier}+t" = "workspace ";

      # Move focused container to workspace
      "${modifier}+Shift+ampersand" = "move container to workspace number 1";
      "${modifier}+Shift+eacute" = "move container to workspace number 2";
      "${modifier}+Shift+quotedbl" = "move container to workspace number 3";
      "${modifier}+Shift+apostrophe" = "move container to workspace number 4";
      "${modifier}+Shift+parenleft" = "move container to workspace number 5";
      "${modifier}+Shift+minus" = "move container to workspace number 6";
      "${modifier}+Shift+egrave" = "move container to workspace number 7";
      "${modifier}+Shift+underscore" = "move container to workspace number 8";
      "${modifier}+Shift+ccedilla" = "move container to workspace number 9";
      "${modifier}+Shift+agrave" = "move container to workspace number 10";
      "${modifier}+Shift+t" = "move container to workspace ";

      # Switch to resize mode
      "${modifier}+r" = "mode resize";

      # Change monitor for a workspace
      "Mod1+Left" = "move workspace to output left";
      "Mod1+Right" = "move workspace to output right";
    };

    keycodebindings = lib.mkOptionDefault {
      # Left trackpad button on Tuxedo Laptop
      "${modifier}+Control+93" = "exec systemctl suspend-then-hibernate";
    };

    modes = {
      resize = {
        # These bindings trigger as soon as you enter the resize mode
        "Left" = "resize shrink width 1 px or 1 ppt";
        "Down" = "resize grow height 1 px or 1 ppt";
        "Up" = "resize shrink height 1 px or 1 ppt";
        "Right" = "resize grow width 1 px or 1 ppt";
        # All the same but 10 times as effective with controll key pressed
        "Control+Left" = "resize shrink width 10 px or 10 ppt";
        "Control+Down" = "resize grow height 10 px or 10 ppt";
        "Control+Up" = "resize shrink height 10 px or 10 ppt";
        "Control+Right" = "resize grow width 10 px or 10 ppt";
        # Back to normal: Enter or Escape
        "Return" = "mode default";
        "Escape" = "mode default";
      };
    };
  };
}
