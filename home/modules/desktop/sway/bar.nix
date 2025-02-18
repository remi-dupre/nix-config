{ config, lib, pkgs, ... }:

let
  bin = import ../../../common/binaries.nix pkgs;
  color = import ../../../common/colors.nix;
  font = import ../../../common/fonts.nix pkgs;
in

lib.mkIf config.repo.desktop.sway.enable {
  wayland.windowManager.sway.config.bars = [{
    statusCommand = "SHELL=${bin.bash} i3status-rs ~/.config/i3status-rust/config-default.toml";
    position = "top";
    trayOutput = "none";

    fonts = {
      names = [ font.compact ];
      size = font.size;
    };

    colors = {
      statusline = color.back;
      background = color.back;

      focusedWorkspace = with color; {
        background = prim;
        border = back;
        text = fbri;
      };

      inactiveWorkspace = {
        background = color.back;
        border = color.back;
        text = color.font;
      };
    };

    extraConfig = ''
      height 28
    '';

  }];

  programs.i3status-rust = {
    enable = true;

    bars = {
      default = {
        settings = {
          theme = {
            theme = "plain";
            overrides.separator = " ";
          };

          icons = {
            icons = "awesome4";
            overrides = {
              net_up = "";
              net_down = "";
              backlight = [ "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ];
            };
          };
        };

        blocks =
          let
            separator = "  ·  ";

            spacer = char: {
              block = "custom";
              command = "echo '${char}'";
              interval = 3600;
            };

            spacers =
              size: char: lib.lists.forEach
                (lib.lists.range 1 size)
                (_: spacer char);

            bluetooth-activated = text: {
              block = "custom";
              format = "$text.pango-str()";
              interval = 1;

              command = lib.strings.concatStringsSep " && " [
                "${bin.bluetoothctl} show | grep -o 'Powered: yes' > /dev/null"
                "echo -n '${text}'"
              ];

              click = [
                {
                  button = "left";
                  cmd = "${bin.blueman-manager}";
                }
                {
                  button = "right";
                  cmd = "${bin.bluetoothctl} power off";
                  update = true;
                }
              ];
            };
          in
          [{
            block = "focused_window";
            format = "<b>$title.str(max_w:120)</b>|";
          }]
          ++ spacers 30 ""
          ++ [ (bluetooth-activated "") ]
          ++ lib.lists.forEach
            [
              { mac = "00:00:AB:CD:55:75"; name = "FP Earbuds"; }
              { mac = "04:21:44:49:4C:C6"; name = "HyperX"; }
              { mac = "5C:EB:68:70:9E:9E"; name = "Platan"; }
            ]
            (device: with device; {
              inherit mac;
              block = "bluetooth";
              format = "${name}{ $percentage|} ${separator} ";
              disconnected_format = "";

              click = [{
                button = "left";
                cmd = "${bin.blueman-manager}";
              }];
            })
          ++ [
            {
              block = "net";
              format = "$icon  $ssid ^icon_net_down$speed_down.eng(prefix:K) ^icon_net_up$speed_up.eng(prefix:K)";
              interval = 5;
            }
            {
              block = "custom";
              command = "echo -n ⇄ $(ping -c1 8.8.8.8 | perl -nle '/time=(\\d+)/ && print $1')ms";
              interval = 60;
            }
            (spacer separator)
            {
              block = "cpu";
              interval = 1;
            }
            {
              block = "memory";
              format = "$icon $mem_used";
            }
            (spacer separator)
            {
              block = "sound";
              device_kind = "source";
              show_volume_when_muted = true;
            }
            {
              block = "sound";
              show_volume_when_muted = true;
            }
            (spacer separator)
            {
              block = "hueshift";
              format = " $temperature";
              hue_shifter = "wl_gammarelay_rs";

              click = [
                {
                  button = "right";
                  cmd = "systemctl restart --user gammarelay-sun.service";
                }
              ];
            }
            {
              block = "backlight";
            }
            {
              block = "battery";
              interval = 1;
              format = "$icon   $percentage";
              full_format = "";
              empty_format = "";
              full_threshold = 100;
              good = 100;
              info = 75;
              warning = 50;
              critical = 25;
            }
            {
              block = "battery";
              interval = 10;
              format = "($time)";
              full_threshold = 100;
              good = 100;
              info = 75;
              warning = 50;
              critical = 25;
            }
            (spacer separator)
            {
              block = "time";
              interval = 1;
              format = "<b>$timestamp.datetime(f:'%A %d %B %Y - %H:%M', l:fr_FR)</b>";
            }
          ];
      };
    };
  };
}
