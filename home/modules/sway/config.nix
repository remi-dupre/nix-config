{ pkgs, ... } @ inputs:

let
  # TODO : actual module params
  ctx = {
    screen = {
      width = 2560;
      height = 1600;
      scale = 1.20;
    };
    color = {
      back = "#000000"; # background color
      prim = "#2e2f5d"; # primary color for accents
      font = "#BABABA"; # font color
      fdim = "#222222"; # dimmed font color
      fbri = "#FFFFFF"; # bright font color
    };
    font = {
      default = "NotoSans Nerd Font";
      compact = "NotoSans Nerd Font SemiCondensed";
      monospace = "FiraMono Nerd Font";
    };
  };

  # Ressources
  fonts-pkg = pkgs.nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; };
  fonts-dir = "${fonts-pkg}/share/fonts/truetype/NerdFonts";
  lock-wallpaper = "~/.lock-wallpaper.png";
  scripts = (import ../scripts inputs);
in
{
  modifier = "Mod4";
  terminal = "foot";

  startup = [
    {
      # TODO: this doesn't seem to work
      command = "swaymsg split v";
    }
    {
      command = with ctx.screen;
        "${scripts.update-wallpaper} ${toString width} ${toString height} ${fonts-dir}/NotoSansNerdFont-Regular.ttf ${lock-wallpaper}"
      ;
    }
  ];

  fonts = {
    names = [ ctx.font.default ];
    size = 10.0;
  };

  input = {
    "*".xkb_layout = "fr";
    "type:touchpad".tap = "enabled";
  };

  output = {
    "*" = {
      scale = toString ctx.screen.scale;
      bg = "${../../static/wallpaper.jpg} fill";
    };
  };

  floating = {
    criteria = [
      { app_id = "blueman-manager"; }
      { app_id = "pavucontrol"; }
      { app_id = "wdisplays"; }
      { title = "Extension:*"; }
      { title = "Firefox Developer Edition — Sharing Indicator"; }
      { title = "Firefox — Sharing Indicator"; }
    ];
  };

  window = {
    hideEdgeBorders = "both";
    border = 1;
    titlebar = false;
  };

  bars = [{
    statusCommand = "SHELL=${pkgs.bash}/bin/bash i3status-rs ~/.config/i3status-rust/config-default.toml";
    position = "top";
    trayOutput = "none";

    fonts = {
      names = [ ctx.font.compact ];
      size = 10.0;
    };

    colors = {
      statusline = ctx.color.back;
      background = ctx.color.back;
      focusedWorkspace = with ctx.color; { background = prim; border = back; text = fbri; };
      inactiveWorkspace = with ctx.color; { background = back; border = back; text = font; };
    };
  }];

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
}
