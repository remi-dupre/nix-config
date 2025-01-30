{ config, lib, pkgs, ... }:

let
  bin = import ../../common/binaries.nix pkgs;
  color = import ../../common/colors.nix;
  font = import ../../common/fonts.nix pkgs;
in

lib.mkIf config.repo.sway.enable {
  services.dunst = {
    enable = true;

    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
      size = "scalable";
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
        font = "${font.default} ${toString font.size}";

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
        format = "<b>%s</b>\\n%b";

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
}
