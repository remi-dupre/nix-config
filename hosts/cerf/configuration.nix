{ lib, pkgs, ... }@inputs:

let
  json = pkgs.formats.json { };
in

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    ../common/base.nix
    ./hardware-configuration.nix # results of the hardware scan.
    ./disko-partitioning.nix
  ];

  zramSwap.enable = true;

  hardware = {
    sane.enable = true; # enables support for SANE scanners

    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot

      # Allow to fetch battery level for connected devices
      # https://nixos.wiki/wiki/Bluetooth#Showing_battery_charge_of_bluetooth_devices
      settings.General.Experimental = true;
    };

    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true;
    };
  };

  fonts = {
    fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [ "NotoSerif Nerd Font" ];
        sansSerif = [ "NotoSans Nerd Font" ];
      };
    };

    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraMono"
          "Noto"
        ];
      })
    ];
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true; # recommanded with pipewire

    pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };

  # Docker
  virtualisation.docker.enable = true;

  # Disabled services
  systemd.services.docker.wantedBy = lib.mkForce [ ];

  # Bootloader.
  boot = {
    tmp.useTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Network
  networking = {
    hostName = "cerf";

    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.remi = {
    isNormalUser = true;
    description = "Rémi Dupré";
    extraGroups = [
      "adbusers"
      "docker"
      "networkmanager"
      "wheel"
      "scanner"
      "lp"
    ];
    shell = pkgs.fish;
  };

  programs = {
    adb.enable = true;
    fish.enable = true;

    nix-ld = {
      enable = true;

      libraries = with pkgs; [
        openssl # A cryptographic library that implements the SSL and TLS protocols
        zlib # Lossless data-compression library
      ];
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    sway = {
      enable = true;
      extraPackages = [ ];
    };
  };

  services = {
    # Bluetooth pairing management
    blueman.enable = true;

    # Required by xdg portal
    dbus.enable = true;

    # VPN capabilities
    globalprotect.enable = true;

    # Required by nautilus for trash management
    gvfs.enable = true;

    # Required by nautilus for indexing files, see
    # https://discourse.nixos.org/t/after-upgrading-to-23-05-gnome-applications-take-a-long-time-to-start/28900
    gnome.tinysparql.enable = true;
    gnome.localsearch.enable = true;

    # Enable the local print service
    printing.enable = true;

    # Prevents overheating on Intel CPUs
    thermald.enable = true;

    # Support for network scanning:
    # https://nixos.wiki/wiki/Scanners#Network_scanning
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    # Multimedia support
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      extraConfig.pipewire = {
        "99-input-denoising.conf" = {
          source = json.generate "99-input-denoising.conf" {
            "context.modules" = [
              {
                name = "libpipewire-module-echo-cancel";

                args = {
                  # Monitor mode: Instead of creating a virtual sink into which all
                  # applications must play, in PipeWire the echo cancellation
                  # module can read the audio that should be cancelled directly
                  # from the current fallback audio output
                  "monitor.mode" = true;

                  # The audio source / microphone wherein the echo should be
                  # cancelled is not specified explicitely; the module follows the
                  # fallback audio source setting
                  "source.props" = {
                    # Name and description of the virtual source where you get the
                    # audio without echoed speaker output
                    "node.name" = "source_ec";
                    "node.description" = "Echo-cancelled source";
                  };

                  "aec.args" = {
                    # Settings for the WebRTC echo cancellation engine
                    "webrtc.gain_control" = true;
                    "webrtc.extended_filter" = false;
                    "webrtc.noise_suppression" = true;
                  };
                };
              }
            ];
          };
        };
      };
    };

    # Session manager
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          # sway is started inside of a shell to load user's env variables
          command = "fish -c sway";
          user = "remi";
        };
        default_session = initial_session;
      };
    };

    # Power management
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    tlp = {
      enable = true;
      settings = {
        # Help save long term battery health
        START_CHARGE_THRESH_BAT0 = 94;
        STOP_CHARGE_THRESH_BAT0 = 98;
        # Device management
        DEVICES_TO_ENABLE_ON_STARTUP = "wifi";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Include homemanager config
  home-manager.users.remi = {
    imports = [ ../../home ];

    repo = {
      games.enable = true;
      sway.enable = true;
      work.enable = true;

      desktop = {
        enable = true;

        display = {
          name = "eDP-1";
          width = 2560;
          height = 1600;
          scale = 1.00;
        };
      };
    };
  };

  # This value determines the NixOS release from which the default settings for
  # stateful data, like file locations and database versions on your system
  # were taken. It‘s perfectly fine and recommended to leave this value at the
  # release version of the first install of this system. Before changing this
  # value read the documentation for this option (e.g. man configuration.nix or
  # on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
