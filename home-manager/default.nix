{ config, pkgs, ... }:

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

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [
        { command = "firefox"; }
      ];
    };
  };

  programs = {
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
