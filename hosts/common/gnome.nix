{ config, lib, pkgs, ... }:

let
  cfg = config.repo.common.gnome;
in

{
  options.repo.common.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # systemPackages = with pkgs; [
      #   libwacom-surface # Libraries, configuration, and diagnostic tools for W...
      # ];

      gnome.excludePackages = with pkgs; [
        baobab # Graphical application to analyse disk usage in any GNOME envir...
        epiphany # WebKit based web browser for GNOME
        geary # Mail client for GNOME 3
        gnome-backgrounds # Default wallpaper set for GNOME
        gnome-characters # Simple utility application to find and insert unusua...
        gnome-connections # Remote desktop client for the GNOME desktop environ...
        gnome-console # Simple user-friendly terminal emulator for the GNOME de...
        gnome-contacts # GNOME’s integrated address book
        gnome-disk-utility # Udisks graphical front-end
        gnome-extension-manager # Desktop app for managing GNOME shell extensions
        gnome-font-viewer # Program that can preview fonts and create thumbnail...
        gnome-logs # Log viewer for the systemd journal
        gnome-music # Music player and management application for the GNOME des...
        gnome-shell-extensions # Modify and extend GNOME Shell functionality an...
        gnome-software # Software store that lets you install and update applic...
        gnome-system-monitor # System Monitor shows you what programs are runni...
        gnome-terminal # GNOME Terminal Emulator
        gnome-tour # GNOME Greeter & Tour
        gnome-user-docs # User and system administration help for the GNOME des...
        orca # A free, open source, flexible and extensible screen reader that ...
        seahorse # Application for managing encryption keys and passwords in th...
        snapshot # Take pictures and videos on your computer, tablet, or phone ...
        sushi # Quick previewer for Nautilus
        sysprof # System-wide profiler for Linux
        totem # Movie player for the GNOME desktop based on GStreamer
        yelp # Help viewer in Gnome
      ];
    };

    services = {
      flatpak.enable = true;

      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        wacom.enable = true;
      };
    };

    home-manager.users.remi.repo.desktop = {
      enable = true;
      gnome.enable = true;
    };
  };
}
