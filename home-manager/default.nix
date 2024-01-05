{ config, pkgs, lib, ... }:

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

in
{
  home.username = ctx.user;
  home.homeDirectory = "/home/${ctx.user}";
  home.stateVersion = "23.11"; # Please read the comment before changing.
  home.keyboard.layout = "fr";

  home.packages = with pkgs; [
    cowsay
    clang
    neovim
    (nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; })
  ];

  home.file = {
    # ".config/nvim".source = ./static/config/nvim;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.userDirs = {
    desktop = "/tmp";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
  };

  wayland.windowManager.sway =
    {
      enable = true;
      config = {
        fonts = {
          names = [ ctx.font.default ];
          size = 10.0;
        };
        input = {
          "*".xkb_layout = "fr";
        };
        output = {
          "*" = {
            scale = "1.2";
            bg = "${./static/wallpaper.2.jpg} fill";
          };
        };
        window = {
          hideEdgeBorders = "smart";
          border = 2;
        };
        modifier = "Mod4";
        keybindings =
          let
            modifier = config.wayland.windowManager.sway.config.modifier;
          in
          lib.mkOptionDefault {
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
            # Change monitor for a workspace
            "Mod1+Left" = "move workspace to output left";
            "Mod1+Right" = "move workspace to output right";
          };
        terminal = "alacritty";
        startup = [
          { command = "firefox"; }
        ];
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
      package = pkgs.firefox-devedition;
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

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
