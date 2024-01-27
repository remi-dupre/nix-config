{ config, pkgs, lib, ... } @ inputs:

let
  ctx = {
    user = "remi";
    email = "remi@dupre.io";
    screen = {
      width = 2560;
      height = 1600;
      scale = 1.20;
    };
    font = {
      default = "NotoSans Nerd Font";
      compact = "NotoSans Nerd Font SemiCondensed";
      monospace = "FiraMono Nerd Font";
    };
  };

  # Commons
  action = (import ./common/actions.nix inputs);
  bin = (import ./common/binaries.nix inputs);
  color = (import ./common/colors.nix inputs);
  scripts = (import ./common/scripts inputs);

  # Fonts
  fonts-pkg = pkgs.nerdfonts.override { fonts = [ "FiraMono" "Noto" ]; };
  fonts-dir = "${fonts-pkg}/share/fonts/truetype/NerdFonts";

  # Paths
  lock-wallpaper = "~/.lock-wallpaper.png";
in
rec {
  imports = [
    ./modules/shell
    ./modules/sway
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = ctx.user;
    homeDirectory = "/home/${ctx.user}";
    stateVersion = "23.11"; # Please read the comment before changing.
    keyboard.layout = "fr";

    packages = with pkgs; [
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
      loupe
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
      music = null;
      pictures = null;
      videos = null;
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

  programs = {
    bat.enable = true;
    direnv.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;

    eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
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

        scrollback = {
          lines = 10000;
          multiplier = 5.0;
        };

        url = {
          label-letters = "qsdfghjklmwxcvbn";
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
        init.defaultBranch = "main";
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
        image = "${lock-wallpaper}";
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
          browser = "${bin.firefox} -new-tab";

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
          frame_color = "${color.prim}";
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
          command = action.lock;
        }
        {
          event = "after-resume";
          command = ''swaymsg "output * power on"'';
        }
      ];

      timeouts = [
        {
          timeout = 1795;
          command = action.lock;
        }
        {
          timeout = 1800;
          command = ''swaymsg "output * power off"'';
        }
      ];
    };
  };
}
