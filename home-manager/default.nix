{ config, pkgs, lib, inputs, ... }:

let
  ctx = {
    user = "remi";
    email = "remi@dupre.io";
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

  # Locations
  path-lock-wallpaper = "~/.lock-wallpaper.png";

  # Fonts
  fonts-pkg = pkgs.nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; };
  fonts-dir = "${fonts-pkg}/share/fonts/truetype/NerdFonts";

  # Binaries
  blueman-manager = "${pkgs.blueman}/bin/blueman-manager";
  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  dunstify = "${pkgs.dunst}/bin/dunstify";
  firefox = "${pkgs.firefox-devedition}/bin/firefox-devedition";
  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  nom = "${pkgs.nix-output-monitor}/bin/nom";
  pacmd = "${pkgs.pulseaudio}/bin/pacmd";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi = "${pkgs.rofi-wayland}/bin/rofi";
  rofimoji = "${pkgs.rofimoji}/bin/rofimoji";
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";

  # Update nixos config
  pkg-config-rebuild = pkgs.writeScriptBin "config-rebuild" ''
    nixos-rebuild switch --print-build-logs --log-format internal-json --flake $1 |& ${nom} --json
  '';

  # Take a a screenshot
  action-screenshot = mode: pkgs.writeShellScript "screenshot-${mode}" ''
    OUTPUT_FILE=/tmp/screenshot_$(date +"%Y-%m-%dT%H:%M:%S").png

    ${grimshot} copy ${mode}
    ${wl-paste} > $OUTPUT_FILE
    ${dunstify} --icon $OUTPUT_FILE "Saved ${mode} to clipboard" "$OUTPUT_FILE"
  '';

  # Notify of current brightness
  notify-brightness = pkgs.writeShellScript "notify-brightness" ''
    ID_FILE=/tmp/.notif_brightness_id

    brightness=$((100 * `${brightnessctl} get` / `${brightnessctl} max`))
    notif_id=$(cat $ID_FILE || echo -n "601")

    notif_id=$(
      ${dunstify} \
        --printid \
        --hints "int:value:$brightness" \
        --replace=$notif_id \
        --icon=display-brightness-symbolic \
        --urgency=low \
        --timeout=1000 "Brightness" "$brightness %"
    )

    echo $notif_id > $ID_FILE
  '';

  # Notify of current sound level
  action-notify-sound = pkgs.writeShellScript "notify-sound" ''
    ID_FILE=/tmp/.notif_sound_id

    notif_id=$(cat $ID_FILE || echo "600")
    default_sink_name=$(${pactl} get-default-sink)

    name=$(
      ${pactl} list sinks \
        | sed "0,/$default_sink_name/d" \
        | grep Description \
        | sed -e 's/^.*Description: \(.*\)$/\1/g' \
        | head -n 1
    )

    volume=$(
      ${pactl} get-sink-volume $default_sink_name \
        | head -n 1 \
        | sed -e 's/^.* \([0-9]\+\)%.*$/\1/g'
    )

    muted=$(
      ${pactl} get-sink-mute $default_sink_name \
        | sed -e 's/^Mute: \(.*\)$/\1/'
    )

    # Notification attributes
    if [ $volume -gt "101" ]; then
      force="overamplified"
    elif [ $volume -gt "70" ]; then
      force="high"
    elif [ $volume -gt "35" ]; then
      force="medium"
    elif [ $volume -gt "1" ]; then
      force="low"
    else
      force="muted"
    fi

    if [ $volume -gt "100" ]; then
      urgency="critical"
    else
      urgency="low"
    fi

    # Display
    if [ $muted = "yes" ]; then
      notif_id=$(
        ${dunstify} \
          --printid \
          --replace=$notif_id \
          --icon=audio-volume-muted-symbolic \
          --urgency=low \
          --timeout=1000 \
          "$name" "Off"
      )
    else
      notif_id=$(
        ${dunstify} \
          --printid \
          --hints "int:value:$volume" \
          --replace=$notif_id \
          --icon=audio-volume-$force-symbolic \
          --urgency=$urgency \
          --timeout=1000 \
          "$name" "$volume%"
      )
    fi

    echo $notif_id > $ID_FILE
  '';

  # Notify of current microphone level
  action-notify-micro = pkgs.writeShellScript "notify-micro" ''
    ID_FILE=/tmp/.notif_microphone_id

    notif_id=$(cat $ID_FILE || echo "602")
    default_source_name=$(${pactl} get-default-source)

    name=$(
      ${pactl} list sources \
        | sed "0,/$default_source_name/d" \
        | grep Description \
        | sed -e 's/^.*Description: \(.*\)$/\1/g' \
        | head -n 1
    )

    volume=$(
      ${pactl} get-source-volume $default_source_name \
        | head -n 1 | sed -e 's/^.* \([0-9]\+\)%.*$/\1/g'
    )

    muted=$(
      ${pactl} get-source-mute $default_source_name \
        | sed -e 's/^Mute: \(.*\)$/\1/'
    )

    # Notification attributes
    if [ $volume -gt "66" ]; then
      force="high"
    elif [ $volume -gt "33" ]; then
      force="medium"
    else
      force="low"
    fi

    if [ $volume -gt "100" ]; then
        urgency="critical"
    else
        urgency="low"
    fi

    # Display
    if [ $muted = "yes" ]; then
      notif_id=$(
        ${dunstify} \
          --printid \
          --replace=$notif_id \
          --icon=microphone-sensitivity-muted-symbolic \
          --urgency=low \
          --timeout=1000 \
          "$name" "Off"
      )
    else
      notif_id=$(
        ${dunstify} \
          --printid \
          --hints "int:value:$volume" \
          --replace=$notif_id \
          --icon=microphone-sensitivity-$force-symbolic \
          --urgency=$urgency \
          --timeout=1000 \
          "$name" "$volume%"
      )
    fi

    echo $notif_id > $ID_FILE
  '';

  # Load lock wallpaper from bing image
  action-update-wallpaper = pkgs.writers.writePython3
    "update-wallpaper"
    {
      libraries = with pkgs.python3Packages; [
        pillow
        pyyaml
      ];
    }
    (builtins.readFile ./static/scripts/update-wallpaper.py);

  # Forget sudo password, ssh keys and finaly locks
  action-lock = "sudo -K && ssh-add -D && gpgconf --reload gpg-agent && swaylock";
  # Sound control
  action-sound-mute = op: "${pactl} set-sink-mute @DEFAULT_SINK@ ${op}"; # op is toggle / off
  action-sound-volume = op: "${pactl} set-sink-volume @DEFAULT_SINK@ ${op}"; # op is +5% / -5%
  action-sample = op: "pw-play ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/${op}.oga";
  # Microphone control
  action-micro-mute = op: "${pactl} set-source-mute @DEFAULT_SOURCE@ ${op}"; # op is toggle / off
  action-micro-volume = op: "${pactl} set-source-volume @DEFAULT_SOURCE@ ${op}"; # op is +5% / -5%
in
rec {
  imports = [
    ../modules/htop.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = ctx.user;
    homeDirectory = "/home/${ctx.user}";
    stateVersion = "23.11"; # Please read the comment before changing.
    keyboard.layout = "fr";

    packages = with pkgs; [
      # Terminal Utilities
      httpie
      jq
      neovim
      pkg-config-rebuild
      ripgrep
      unzip
      wl-clipboard
      yq
      zip
      # Programming
      cargo
      gcc
      gitleaks
      helm-docs
      openssl
      pkg-config
      (pkgs.wrapHelm pkgs.kubernetes-helm { plugins = [ pkgs.kubernetes-helmPlugins.helm-secrets ]; })
      poetry
      pre-commit
      python3
      python311Packages.python-lsp-server
      ruff
      ruff-lsp
      sops
      yaml-language-server
      # Vim Plugins
      rnix-lsp
      # Desktop requirements
      adw-gtk3 # libadwaita theme for GTK3
      xdg-utils # for opening default programs when clicking links
      # Desktop
      evince
      gimp
      globalprotect-openconnect
      gnome.file-roller
      gnome.nautilus
      libreoffice
      pavucontrol
      qgis
      signal-desktop
      wdisplays
    ];

    sessionVariables = {
      GTK_THEME = "adw-gtk3-dark";

      # Required for some Python libraries to work
      # See https://discourse.nixos.org/t/how-to-solve-libstdc-not-found-in-shell-nix/25458/15
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";

      # See https://nixos.wiki/wiki/Wayland
      NIXOS_OZONE_WL = "1";
    };

    shellAliases = {
      l = "ll";
      utnm = "poetry run -C ~/code/libraries/utnm utnm";
      vim = "nvim";
    };

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 16;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };

    file = {
      ".config/rofi".source = ./static/config/rofi;
    };
  };

  xdg = {
    desktopEntries.nvim = {
      name = "NeoVim";
      exec = "foot nvim %F";
      type = "Application";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    };
    userDirs = {
      enable = true;
      desktop = "/tmp";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
    };
  };

  gtk.gtk3.bookmarks = [
    "/tmp"
    "${config.home.homeDirectory}/documents"
    "${config.home.homeDirectory}/downloads"
  ];

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark"; # gtk 4
      font-name = "${ctx.font.default} 10";
    };
  };


  wayland.windowManager.sway =
    let
      modifier = "Mod4";
    in
    {
      enable = true;

      wrapperFeatures = {
        base = true;
        gtk = true;
      };

      config = {
        inherit modifier;
        terminal = "foot";
        startup = [
          { command = "swaymsg split v"; }
          {
            command = ''
              ${action-update-wallpaper} ${toString ctx.screen.width} ${toString ctx.screen.height} ${fonts-dir}/NotoSansNerdFont-Regular.ttf ${path-lock-wallpaper}
            '';
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
            bg = "${./static/wallpaper.jpg} fill";
          };
        };
        floating = {
          criteria = [
            { app_id = "blueman-manager"; }
            { app_id = "pavucontrol"; }
            { app_id = "wdisplays"; }
            { instance = "protonmail-bridge"; }
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
        keybindings =
          lib.mkOptionDefault {
            # Application shortcuts
            "${modifier}+l" = "exec ${action-lock}";
            "Control+Mod1+d" = "exec nautilus";
            "Control+Mod1+f" = "exec ${firefox}";
            "Control+Shift+p" = "exec ${firefox} --private-window";
            "Control+Mod1+s" = "exec pavucontrol";
            "Control+Mod1+b" = "exec ${bluetoothctl} power on && ${blueman-manager}";
            # Close window
            "Mod1+F2" = "exec ${rofi} -theme ~/.config/rofi/drun.rasi -show";
            "Mod1+c" = "exec ${rofimoji} -f 'emojis_*' 'mathematical_*' 'miscellaneous_symbols_and_arrows' --hidden-description";
            "Mod1+F4" = "kill";
            # Screenshot
            "Print" = "exec ${action-screenshot "screen"} && ${action-sample "camera-shutter"}";
            "Shift+Print" = "exec ${action-screenshot "area"} && ${action-sample "camera-shutter"}";
            "Control+Print" = "exec ${action-screenshot "window"} && ${action-sample "camera-shutter"}";
            # Sound
            "XF86AudioRaiseVolume" = "exec '${action-sound-mute "off"} & ${action-sound-volume "+5%"} & ${action-notify-sound} & ${action-sample "audio-volume-change"}'";
            "XF86AudioLowerVolume" = "exec '${action-sound-mute "off"} & ${action-sound-volume "-5%"} & ${action-notify-sound} & ${action-sample "audio-volume-change"}'";
            "XF86AudioMute" = "exec '${action-sound-mute "toggle"} & ${action-notify-sound} & ${action-sample "audio-volume-change"}'";
            # Microphone
            "Shift+XF86AudioRaiseVolume" = "exec '${action-micro-mute "off"} & ${action-micro-volume "+5%"} & ${action-notify-micro}'";
            "Shift+XF86AudioLowerVolume" = "exec '${action-micro-mute "off"} & ${action-micro-volume "-5%"} & ${action-notify-micro}'";
            "Shift+XF86AudioMute" = "exec '${action-micro-mute "toggle"}; ${action-notify-micro}'";
            #  MPD Control
            "xf86audioplay" = "exec ${playerctl} play-pause";
            "xf86audionext" = "exec ${playerctl} next";
            "xf86audioprev" = "exec ${playerctl} prev";
            "xf86audiostop" = "exec ${playerctl} stop";
            # Brightness
            "XF86MonBrightnessUp" = "exec '${brightnessctl} set 5%+ && ${notify-brightness}'";
            "XF86MonBrightnessDown" = "exec '${brightnessctl} set 5%- && ${notify-brightness}'";
            # Rebuild config and reload
            "${modifier}+Shift+r" = "swaymsg reload";
            # Always on top window
            "${modifier}+w" = "sticky toggle";
            # Stick and resize
            "${modifier}+Shift+w" =
              let
                ratio = 0.20;
                margin = 25;
                width = builtins.floor (ratio * ctx.screen.width);
                height = builtins.floor (width * 9 / 16);
                pos-x = builtins.floor (ctx.screen.width / ctx.screen.scale - width - margin);
              in
              "floating enable; sticky enable; resize set ${toString width} ${toString height}; move position ${toString pos-x} ${toString margin}";
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
        modes =
          {
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
      extraConfig = ''
        bindswitch --reload --locked lid:on exec ${action-lock}
      '';
    };

  programs = {
    bat.enable = true;
    direnv.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;

    eza = {
      enable = true;
      enableAliases = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };

    fish = {
      enable = true;
      plugins = [
        { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      ];
      shellInit = ''
        # Fix conflict between fzf default script and fzf.fish plugin
        # See https://haseebmajid.dev/posts/2023-09-19-til-how-to-use-fzf-fish-history-search/#appendix
        bind \cr _fzf_search_history
        bind -M insert \cr _fzf_search_history
      '';
    };

    foot = {
      enable = true;

      settings = {
        main = {
          # term = "xterm-256color";
          font = "${ctx.font.monospace}:size=10";
          box-drawings-uses-font-glyphs = true;
          include = "${pkgs.foot.themes}/share/foot/themes/kitty";
          pad = "4x4";
        };

        bell = {
          urgent = "yes";
          visual = true;
          command = "dunstify -t 5000 -u low -a \${app-id} \${title} \${body}";
        };

        mouse = {
          hide-when-typing = " yes ";
        };
      };
    };

    fzf = {
      enable = true;
      enableBashIntegration = false; # managed by fish plugin
      enableFishIntegration = false; # managed by fish plugin
      enableZshIntegration = false; # managed by fish plugin
    };

    git = {
      enable = true;
      userName = ctx.user;
      userEmail = ctx.email;
      delta = {
        enable = true;
        options = {
          features = "side-by-side line-numbers decorations";
          whitespace-error-style = "22 reverse";
        };
      };
      signing = {
        signByDefault = true;
        key = "9A55335D0A120F1C1B1183237E40AB46381379CE";
      };
      extraConfig = {
        push.autoSetupRemote = true;
      };
    };


    i3status-rust = {
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
                net_wireless = "";
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
                command = "${bluetoothctl} show | grep -o 'Powered: yes' > /dev/null && echo -n '${text}'";
                format = "$text.pango-str()";
                interval = 1;

                click = [
                  {
                    button = "left";
                    cmd = "${blueman-manager}";
                  }
                  {
                    button = "right";
                    cmd = "${bluetoothctl} power off";
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
                format = "${name}{ $percentage|} {separator} ";
                disconnected_format = "";

                click = [{
                  button = "left";
                  cmd = "${blueman-manager}";
                }];
              })
            ++ [ (bluetooth-activated separator) ]
            ++ [
              {
                block = "net";
                format = "^icon_net_down$speed_down.eng(prefix:K) ^icon_net_up$speed_up.eng(prefix:K)";
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
                # hue_shifter = "gammastep";
                format = "☀ $temperature";
                step = 50;
                click_temp = 3500;
              }
              {
                block = "backlight";
              }
              (spacer separator)
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

    ssh = {
      addKeysToAgent = "30m";
    };

    starship = {
      enable = true;
      settings = {
        fill.symbol = " ";
        package.disabled = true;
        directory.style = "bold underline cyan";
        username.format = "[$user](dimmed yellow)@";

        format = lib.concatStrings [
          "$all$fill$kubernetes"
          "$line_break"
          "$jobs$battery$time$status$container$shell$character"
        ];

        hostname = {
          format = "[$hostname]($style) ";
          style = "dimmed";
          ssh_only = false;
        };

        time = {
          disabled = false;
          format = "[$time]($style) ";
          style = "dimmed";
        };

        custom.nice = {
          command = ''echo "★ $(nice)"'';
          when = ''if [ $(nice) == "0" ]; then exit 1; else exit 0; fi'';
          shell = "${pkgs.bash}/bin/bash";
        };
      };
    };

    ssh = {
      enable = true;
      matchBlocks = {
        castor.hostname = "castor.dupre.io";
        dgexsol_ssh_proxy = {
          hostname = "ssh-proxy.dgexsol.fr";
          port = 443;
          user = "jumpuser";
          forwardAgent = true;
        };
        ws-classic-01 = {
          hostname = "classic-01.workspaces.dgexsol.fr";
          user = "9609122y";
          proxyJump = "dgexsol_ssh_proxy";
        };
      };
    };

    swaylock = {
      enable = true;
      settings = {
        image = "${path-lock-wallpaper}";
        ignore-empty-password = true;
      };
    };
  };


  services = {
    mpris-proxy.enable = true;
    ssh-agent.enable = true;

    dunst = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = "symbolic";
      };
      settings = {
        global = {
          ### Display ###

          # Which monitor should the notifications be displayed on.
          monitor = 0;

          # Display notification on focused monitor.  Possible modes are:
          #   mouse: follow mouse pointer
          #   keyboard: follow window with keyboard focus
          #   none: don't follow anything
          #
          # "keyboard" needs a window manager that exports the
          # _NET_ACTIVE_WINDOW property.
          # This should be the case for almost all modern window managers.
          #
          # If this option is set to mouse or keyboard, the monitor option
          # will be ignored.
          follow = "mouse";

          ### Geometry ###

          # dynamic width from 0 to 300
          # width = (0, 300)
          # constant width of 300
          width = 350;

          # The maximum height of a single notification, excluding the frame.
          height = 700;

          # Position the notification in the top right corner
          origin = "top-right";

          # Offset from the origin
          offset = "10 x11";

          # Scale factor. It is auto-detected if value is 0.
          scale = 0;

          # Maximum number of notification (0 means no limit)
          notification_limit = 6;

          ### Progress bar ###

          # Turn on the progess bar. It appears when a progress hint is passed with
          # for example dunstify -h int:value:12
          progress_bar = true;

          # Set the progress bar height. This includes the frame, so make sure
          # it's at least twice as big as the frame width.
          progress_bar_height = 5;

          # Set the frame width of the progress bar
          progress_bar_frame_width = 0;

          # Set the minimum width for the progress bar
          progress_bar_min_width = 150;

          # Set the maximum width for the progress bar
          progress_bar_max_width = 300;

          # Show how many messages are currently hidden (because of geometry).
          indicate_hidden = "yes";

          # Shrink window if it's smaller than the width.  Will be ignored if
          # width is 0.
          shrink = "no";

          # The transparency of the window.  Range: [0; 100].
          # This option will only work if a compositing window manager is
          # present (e.g. xcompmgr, compiz, etc.).
          transparency = 0;

          # Draw a line of "separator_height" pixel height between two
          # notifications.
          # Set to 0 to disable.
          separator_height = 0;

          # Padding between text and separator.
          padding = 8;

          # Horizontal padding.
          horizontal_padding = 8;

          # Defines width in pixels of frame around the notification window.
          # Set to 0 to disable.
          frame_width = 4;

          # Defines color of the frame around the notification window.
          frame_color = "#ffffff";

          # Size of gap to display between notifications - requires a compositor.
          # If value is greater than 0, separator_height will be ignored and a border
          # of size frame_width will be drawn around each notification instead.
          # Click events on gaps do not currently propagate to applications below.
          gap_size = 10;

          # Define a color for the separator.
          # possible values are:
          #  * auto: dunst tries to find a color fitting to the background;
          #  * foreground: use the same color as the foreground;
          #  * frame: use the same color as the frame;
          #  * anything else will be interpreted as a X color.
          separator_color = "#ffffff00";

          # Sort messages by urgency.
          sort = "yes";

          # Don't remove messages, if the user is idle (no mouse or keyboard input)
          # for longer than idle_threshold seconds.
          # Set to 0 to disable.
          # Transient notifications ignore this setting.
          idle_threshold = 120;

          ### Text ###

          font = "${ctx.font.default} 9";

          # The spacing between lines.  If the height is smaller than the
          # font height, it will get raised to the font height.
          line_height = 0;

          # Possible values are:
          # full: Allow a small subset of html markup in notifications:
          #        <b>bold</b>
          #        <i>italic</i>
          #        <s>strikethrough</s>
          #        <u>underline</u>
          #
          #        For a complete reference see
          #        <http://developer.gnome.org/pango/stable/PangoMarkupFormat.html>.
          #
          # strip: This setting is provided for compatibility with some broken
          #        clients that send markup even though it's not enabled on the
          #        server. Dunst will try to strip the markup but the parsing is
          #        simplistic so using this option outside of matching rules for
          #        specific applications *IS GREATLY DISCOURAGED*.
          #
          # no:    Disable markup parsing, incoming notifications will be treated as
          #        plain text. Dunst will not advertise that it has the body-markup
          #        capability if this is set as a global setting.
          #
          # It's important to note that markup inside the format option will be parsed
          # regardless of what this is set to.
          markup = "full";

          # The format of the message.  Possible variables are:
          #   %a  appname
          #   %s  summary
          #   %b  body
          #   %i  iconname (including its path)
          #   %I  iconname (without its path)
          #   %p  progress value if set ([  0%] to [100%]) or nothing
          #   %n  progress value if set without any extra characters
          #   %%  Literal %
          # Markup is allowed
          format = "<b>%s</b>\n%b";

          # Alignment of message text.
          # Possible values are "left", "center" and "right".
          alignment = "left";

          # Show age of message if message is older than show_age_threshold
          # seconds.
          # Set to -1 to disable.
          show_age_threshold = 60;

          # Split notifications into multiple lines if they don't fit into
          # geometry.
          word_wrap = "yes";

          # When word_wrap is set to no, specify where to ellipsize long lines.
          # Possible values are "start", "middle" and "end".
          ellipsize = "middle";

          # Ignore newlines '\n' in notifications.
          ignore_newline = "no";

          # Merge multiple notifications with the same content
          stack_duplicates = true;

          # Hide the count of merged notifications with the same content
          hide_duplicate_count = false;

          # Display indicators for URLs (U) and actions (A).
          show_indicators = "yes";

          ### Icons ###

          # Align icons left/right/off
          icon_position = "left";

          # Scale larger icons down to this size, set to 0 to disable
          max_icon_size = 64;

          # Paths to default icons.
          # Managed by home-manager
          # icon_path = "/usr/share/icons/Numix/24/status/:/usr/share/icons/Numix/24/devices/:/usr/share/icons/Numix/48/notifications/";
          ### History ###

          # Should a notification popped up from history be sticky or timeout
          # as if it would normally do.
          sticky_history = "yes";

          # Maximum amount of notifications kept in history
          history_length = 20;

          ### Misc/Advanced ###

          # dmenu path.
          dmenu = "dmenu -p dunst";

          # Browser for opening urls in context menu.
          browser = "${firefox} -new-tab";

          # Always run rule-defined scripts, even if the notification is suppressed
          always_run_script = true;

          # Define the title of the windows spawned by dunst
          title = "Dunst";

          # Define the class of the windows spawned by dunst
          class = "Dunst";

          # Define the corner radius of the notification window
          # in pixel size. If the radius is 0, you have no rounded
          # corners.
          # The radius will be automatically lowered if it exceeds half of the
          # notification height to avoid clipping text and/or icons.
          corner_radius = 5;

          ### Legacy

          # Use the Xinerama extension instead of RandR for multi-monitor support.
          # This setting is provided for compatibility with older nVidia drivers that
          # do not support RandR and using it on systems that support RandR is highly
          # discouraged.
          #
          # By enabling this setting dunst will not be able to detect when a monitor
          # is connected or disconnected which might break follow mode if the screen
          # layout changes.
          force_xinerama = false;

          ### Shortcuts

          # Shortcuts are specified as [modifier+][modifier+]...key
          # Available modifiers are "ctrl", "mod1" (the alt-key), "mod2",
          # "mod3" and "mod4" (windows-key).
          # Xev might be helpful to find names for keys.

          # Close notification.
          close = "ctrl + space";

          # Close all notifications.
          # close_all = ctrl+shift+space

          # Redisplay last message(s).
          # On the US keyboard layout "grave" is normally above TAB and left
          # of "1". Make sure this key actually exists on your keyboard layout,
          # e.g. check output of 'xmodmap -pke'
          history = "ctrl + shift + space";

          # Context menu.
          context = "ctrl + shift + period";
        };

        experimental = {
          # Calculate the dpi to use on a per-monitor basis.
          # If this setting is enabled the Xft.dpi value will be ignored and instead
          # dunst will attempt to calculate an appropriate dpi value for each monitor
          # using the resolution and physical size. This might be useful in setups
          # where there are multiple screens with very different dpi values.
          per_monitor_dpi = false;
        };

        urgency_low = {
          # IMPORTANT: colors have to be defined in quotation marks.
          # Otherwise the "#" and following would be interpreted as a comment.
          background = "#000000";
          foreground = "#888888";
          frame_color = "#ffffff";
          timeout = 10;
          # icon = /path/to/icon;
        };

        urgency_normal = {
          background = "000000";
          foreground = "#ffffff";
          frame_color = "${ctx.color.prim}";
          timeout = 10;
          # icon = /path/to/icon;
        };

        urgency_critical = {
          background = "#992222";
          foreground = "#ffffff";
          frame_color = "#ffffff";
          timeout = 0;
          # icon = /path/to/icon;
        };
      };
    };

    gpg-agent = {
      enable = true;
      defaultCacheTtl = 7200; # 2h
      pinentryFlavor = "curses";
    };

    gammastep = {
      enable = true;
      # Paris
      latitude = 48.864;
      longitude = 2.349;
    };

    swayidle = {
      enable = true;

      events = [
        {
          event = "before-sleep";
          command = action-lock;
        }
        {
          event = "after-resume";
          command = ''swaymsg "output * power on"'';
        }
      ];

      timeouts = [
        {
          timeout = 1795;
          command = action-lock;
        }
        {
          timeout = 1800;
          command = ''swaymsg "output * power off"'';
        }
      ];
    };
  };
}
