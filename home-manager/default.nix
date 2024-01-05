{ config, pkgs, lib, inputs, ... }:

let
  ctx = {
    user = "remi";
    email = "remi@dupre.io";
    color = {
      back = "#000000"; # background color
      prim = "#2e2f5d"; # primary color for accents
      font = "#BABABA"; # font color
      fdim = "#222222"; # dimmed font color
      fbri = "#FFFFFF"; # bright font color
    };
    font = {
      default = "Noto Sans Nerd Font";
      monospace = "FiraMono Nerd Font";
    };
  };
  pkg-firefox = pkgs.firefox-devedition;

in
{
  home = {
    username = ctx.user;
    homeDirectory = "/home/${ctx.user}";
    stateVersion = "23.11"; # Please read the comment before changing.
    keyboard.layout = "fr";

    packages = with pkgs; [
      # Build base
      clang
      # Terminal Apps
      fzf
      neovim
      # Desktop requirements
      (nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; })
      gnome.adwaita-icon-theme
      # Desktop
      gnome.nautilus
      pavucontrol
      rofi-wayland
      signal-desktop
    ];

    file =
      {
        ".config/rofi".source = ./static/config/rofi;
      };
  };

  xdg.userDirs = {
    desktop = "/tmp";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
  };

  gtk.gtk3.bookmarks = [
    "/tmp"
    "${config.home.homeDirectory}/documents"
    "${config.home.homeDirectory}/downloads"
  ];

  dconf = {
    enable = true;
    settings."org.gnome.desktop.interface" = {
      color-scheme = "prefer-dark"; # gtk 4
      font-name = "Noto Sans 10";
    };
  };

  wayland.windowManager.sway =
    let
      modifier = "Mod4";
    in
    {
      enable = true;
      config = {
        inherit modifier;
        startup = [
          # { "command" = "configure-gtk"; }
        ];
        fonts = {
          names = [ ctx.font.default ];
          size = 10.0;
        };
        input = {
          "*".xkb_layout = "fr";
        };
        output = {
          "*" = {
            scale = "1";
            bg = "${./static/wallpaper.2.jpg} fill";
          };
        };
        window = {
          hideEdgeBorders = "both";
          border = 1;
          titlebar = false;
        };
        keybindings =
          lib.mkOptionDefault {
            # Close window
            "Mod1+F2" = "exec rofi -theme ~/.config/rofi/drun.rasi -show";
            "Mod1+F4" = "kill";
            # Rebuild config and reload
            "${modifier}+Shift+r" = "swaymsg reload";
            # Always on top window
            "${modifier}+w" = "sticky toggle";
            # Stick and resize
            "${modifier}+Shift+w" = "floating enable; sticky enable; border none; resize set 624 351; move position {{ (monitor.width / sway.scale - 634) | int }} 0";
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
            # Application shortcuts
            "Control+Mod1+d" = "exec nautilus";
            "Control+Mod1+f" = "exec ${pkg-firefox}/bin/firefox";
            "Control+Shift+p" = "exec ${pkg-firefox}/bin/firefox --private-window";
            "Control+Mod1+s" = "exec pavucontrol";
            "Control+Mod1+b" = "exec blueman-manager";
            "Mod1+c" = "exec rofimoji -f 'emojis_*' 'mathematical_*' 'miscellaneous_symbols_and_arrows' --hidden-descriptions --selector-args '-theme rofimoji'";

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
        # colors =
        #   let
        #     base = {
        #       background = ctx.color.fdim;
        #       border = ctx.color.fdim;
        #       childBorder = "#00000000";
        #       indicator = ctx.color.fdim;
        #       text = ctx.color.font;
        #     };
        #   in
        #   {
        #     focusedInactive = base;
        #     placeholder = base;
        #     focused = {
        #       inherit (base) border indicator childBorder;
        #       background = ctx.color.prim;
        #       text = ctx.color.fbri;
        #     };
        #     unfocused = {
        #       inherit (base) background border indicator childBorder;
        #       text = ctx.color.fbri;
        #     };
        #     urgent = {
        #       inherit (base) background border childBorder indicator;
        #       text = ctx.color.prim;
        #     };
        #   };
        terminal = "alacritty";
      };
      extraConfig = ''
        # Gesture navigation between workspaces
        bindgesture swipe:3:right workspace next
        bindgesture swipe:3:up    workspace next
        bindgesture swipe:3:left  workspace prev
        bindgesture swipe:3:down  workspace prev
      '';
    };

  programs = {
    bat.enable = true;
    bash.enable = true; # TODO: replace with fish
    home-manager.enable = true;

    alacritty = {
      enable = true;
      settings = {
        colors = {
          draw_bold_text_with_bright_colors = true;
          bright = {
            black = "#666666";
            blue = "#387CD3";
            cyan = "#3D97E2";
            green = "#77B869";
            magenta = "#957BBE";
            red = "#E05A4F";
            white = "#BABABA";
            yellow = "#EFD64B";
          };
          normal = {
            black = "#000000";
            blue = "#1C98E8";
            cyan = "#1C98E8";
            green = "#68C256";
            magenta = "#8E69C9";
            red = "#E8341C";
            white = "#BABABA";
            yellow = "#F2D42C";
          };
          primary = {
            background = ctx.color.back;
            foreground = ctx.color.font;
          };
        };
        cursor = {
          style = "Block";
          unfocused_hollow = true;
        };
        env = {
          TERM = "xterm-256color";
        };
        font = {
          size = 10.5;
          bold.family = ctx.font.monospace;
          bold_italic.family = ctx.font.monospace;
          italic.family = ctx.font.monospace;
          normal.family = ctx.font.monospace;
        };
        window = {
          dynamic_title = true;
          padding = { x = 4; y = 4; };
        };
      };
    };

    firefox = {
      enable = true;
      package = pkg-firefox;
    };

    fish = {
      enable = true;
      plugins = [
        { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      ];
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

    htop = {
      enable = true;
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
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
  };
}
