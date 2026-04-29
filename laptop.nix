{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./remarkable-sync
    ./remarkable-sync/rmdoc-to-pdf.nix
  ];

  networking = {
    # System hostname
    hostName = "progressio";

    # NetworkManager handles all network connections including VPN
    networkmanager = {
      enable = true;

      # VPN plugins for OpenVPN and OpenConnect (Cisco/Fortinet)
      plugins = with pkgs; [
        networkmanager-openvpn
        (networkmanager-openconnect.override { withGnome = true; })
      ];

      # Declarative VPN profiles — no manual setup needed after rebuild
      ensureProfiles = {
        profiles = {
          # Internal LB VPN (certificate-based OpenVPN)
          lb-int = {
            connection = {
              id = "lb-int";
              type = "vpn";
              autoconnect = false;
              permissions = "user:progressio:;";
            };
            vpn = {
              ca = "/home/progressio/vpn/int/lb-vpn-int-ca.crt";
              cert = "/home/progressio/vpn/int/lb-vpn-int-marco-kuoni.crt";
              key = "/home/progressio/vpn/int/lb-vpn-int-marco-kuoni.key";
              cert-pass-flags = "1";
              connection-type = "tls";
              remote = "193.93.23.35";
              ta = "/home/progressio/vpn/int/lb-vpn-ta.key";
              ta-dir = "1";
              service-type = "org.freedesktop.NetworkManager.openvpn";
              remote-cert-tls = "server";
              data-ciphers = "AES-256-GCM";
            };
          };

          # Public LB VPN (certificate-based OpenVPN)
          lb-pub = {
            connection = {
              id = "lb-pub";
              type = "vpn";
              autoconnect = false;
              permissions = "user:progressio:;";
            };
            vpn = {
              ca = "/home/progressio/vpn/pub/lb-vpn-pub-ca.crt";
              cert = "/home/progressio/vpn/pub/vpn-pub-marco.crt";
              key = "/home/progressio/vpn/pub/vpn-pub-marco.key";
              cert-pass-flags = "1";
              connection-type = "tls";
              remote = "193.93.23.34";
              ta = "/home/progressio/vpn/pub/lb-vpn-ta.key";
              ta-dir = "1";
              service-type = "org.freedesktop.NetworkManager.openvpn";
              remote-cert-tls = "server";
              data-ciphers = "AES-256-GCM";
            };
          };

          # Exigo VPN (Fortinet via OpenConnect)
          exigo = {
            connection = {
              id = "exigo";
              type = "vpn";
              autoconnect = false;
              permissions = "user:progressio:;";
            };
            vpn = {
              authtype = "password";
              autoconnect-flags = "0";
              certsigs-flags = "0";
              cookie-flags = "2";
              disable_udp = "no";
              enable_csd_trojan = "no";
              gateway = "gate2.exigo.ch";
              gateway-flags = "2";
              gwcert-flags = "2";
              lasthost-flags = "0";
              pem_passphrase_fsid = "no";
              prevent_invalid_cert = "no";
              protocol = "fortinet";
              resolve-flags = "2";
              stoken_source = "disabled";
              useragent = "";
              xmlconfig-flags = "0";
              service-type = "org.freedesktop.NetworkManager.openconnect";
            };
            vpn-secrets = {
              "certificate:193.93.23.20:443" = "pin-sha256:6EuCXl3bvo3RctLhzkfSRCf4KP4+f5CossNjRokrJ2o=";
              "form:_login:username" = "lemonbrain";
              lasthost = "gate2.exigo.ch";
            };
          };

          # School VPN (Cisco AnyConnect via OpenConnect)
          school = {
            connection = {
              id = "school";
              type = "vpn";
              autoconnect = false;
              permissions = "user:progressio:;";
            };
            vpn = {
              service-type = "org.freedesktop.NetworkManager.openconnect";
              gateway = "vpn.ost.ch";
              protocol = "anyconnect";
              useragent = "AnyConnect";
              username = "marco.kuoni@ost.ch";
              authtype = "password";
            };
            vpn-secrets = { };
          };
        };
      };
    };

    # Local dev domains and lab server
    extraHosts = ''
      127.0.0.1 bank-avera.local
      127.0.0.1 ksgl.local
      127.0.0.1 lemonbrain.local
      127.0.0.1 backoffice.local
      127.0.0.1 formidable.local
      127.0.0.1 kulturkarussell.local
      127.0.0.1 innovationsbox.internal
      152.96.10.67 ins-lab
    '';

    firewall.allowedTCPPorts = [
      9003 # XDebug (PHP)
      631 # CUPS (printing)
    ];

    # Use DHCP on all interfaces by default
    useDHCP = lib.mkDefault true;

    # Needed for VPN DNS to work correctly with NetworkManager
    resolvconf.enable = true;
  };

  nix = {
    settings = {
      # Enable flakes and new nix CLI
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Deduplicate store paths automatically
      auto-optimise-store = true;
      # Trigger GC when less than 50GB free
      min-free = "50G";
      # Binary cache for niri compositor
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];
    };
    # Auto garbage collect weekly, keep last 7 days
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  time.timeZone = "Europe/Zurich";

  # English UI, Swiss German formats (dates, currency, paper size etc.)
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_CH.UTF-8";
    LC_COLLATE = "de_CH.UTF-8";
    LC_CTYPE = "de_CH.UTF-8";
    LC_IDENTIFICATION = "de_CH.UTF-8";
    LC_MEASUREMENT = "de_CH.UTF-8";
    LC_MONETARY = "de_CH.UTF-8";
    LC_NAME = "de_CH.UTF-8";
    LC_NUMERIC = "de_CH.UTF-8";
    LC_PAPER = "de_CH.UTF-8";
    LC_TELEPHONE = "de_CH.UTF-8";
    LC_TIME = "de_CH.UTF-8";
  };

  # Swiss German keyboard layout for TTY
  console.keyMap = "de_CH-latin1";

  services = {
    #remarkable syncing script
    remarkable-sync = {
      enable = true;
      user = "progressio";
      interval = "5min";
      extraArgs = [ "--verbose" ];
    };
    rmdoc-to-pdf = {
      enable = true;
      user = "progressio";
      # inputDir  = "/home/progressio/remarkable";    # default
      # outputDir = "/home/progressio/remarkable-pdf"; # default
      # interval  = "10min";                           # default
    };

    # Battery/power management
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # DBus is required by almost everything (keyring, NM, pipewire...)
    dbus.enable = true;

    # greetd is a minimal login manager, tuigreet gives a TUI login screen
    # much lighter than GDM, no GNOME dependencies
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri-unstable}/bin/niri-session";
          user = "greeter";
        };
      };
    };

    # GNOME Keyring stores secrets, SSH keys, VPN passwords etc.
    # Runs as a standalone daemon — no full GNOME desktop needed
    gnome.gnome-keyring.enable = true;

    # Printing via CUPS
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    # Avahi enables mDNS so .local hostnames and AirPrint work
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # PipeWire for audio (replaces PulseAudio)
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      # PulseAudio compatibility layer
      pulse.enable = true;
    };

    # Allow users to configure Bastard Keyboard via browser (WebHID)
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };

  users = {
    users.progressio = {
      isNormalUser = true;
      extraGroups = [
        "docker"
        "wheel" # sudo access
        "video"
        "audio"
        "networkmanager"
        "input"
        "lp" # printing
        "lpadmin" # manage printers
        "dialout" # serial ports
      ];
      shell = pkgs.zsh;
    };
    defaultUserShell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  fonts = {
    packages = with pkgs; [
      corefonts
      nerd-fonts.ubuntu
      nerd-fonts.fira-code
      nerd-fonts._0xproto
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  security = {
    # Needed by PipeWire for low-latency audio
    rtkit.enable = true;

    pam = {
      services = {
        login = {
          # Unlock GNOME keyring automatically on login with your password
          enableGnomeKeyring = true;
          # Require YubiKey (U2F) with PIN on login
          u2fAuth = true;
          rules.auth.u2f.args = lib.mkAfter [ "pinverification=1" ];
        };
        sudo = {
          # Require YubiKey (U2F) with PIN for sudo
          u2fAuth = true;
          rules.auth.u2f.args = lib.mkAfter [ "pinverification=1" ];
        };
        # Also unlock keyring on greetd login
        greetd.enableGnomeKeyring = true;
      };

      # YubiKey U2F config — generated with pamu2fcfg
      u2f = {
        enable = true;
        settings = {
          authfile = pkgs.writeText "u2f-mappings" (
            lib.concatStrings [
              "progressio"
              ":Dld2Hwn9kVGjImdI2x37Iho6m8dG/H/INYW+5DjGn6s6s8rzH9SjjFUS4fas88WtHLC6hlOni5RlANRzGzvKhgbu7VkO6IKe4r+RSv8lZrg3/jVc/7jZ+0OQ5h90LOwx,GFi3pUUcIpF7fWAZ/1FBGoG84osWS7z2LbYiYY0e2uJGGNfdQfPDfoBJzayOvyDK9nAW5hs9vU1JGIGbYZoC1Q==,es256,+presence"
              ":X1FGyZEu3GwF6ILuT3cDFE9yElO60EvmXRw1XjCDNj/TLjOoAkCSrnIxT6S1pK+oW1vaicCHDk46slBMvCt+0BB937mOyBQb4bPXjv5RnMeTcodfFPd90IeFY/nBRxtg,G8mdY+E9qmQv89VC/AGH0qtC+iQEJtKDVmzqLvBFZZOEq1B829FOVpd9pAsp7JYiy6uaSxt7YDt0urGlXkptRg==,es256,+presence"
            ]
          );
        };
      };
    };
  };

  programs = {
    firefox.enable = true;
    # nix-ld allows running unpatched binaries (e.g. downloaded scripts)
    nix-ld.enable = true;
    zsh.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      # gnome is added by programs.niri.enable, but listing it explicitly
      # is harmless and makes intent obvious
      pkgs.xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [ "gnome" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

  environment = {
    shells = [ pkgs.zsh ];
    # Required for xdg-desktop-portal to work with home-manager useUserPackages
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    systemPackages = with pkgs; [
      # NetworkManager tray applet (for nm-applet in niri bar)
      networkmanagerapplet
      networkmanager-openconnect
      openconnect
      # Polkit agent — handles privilege escalation popups in non-GNOME setups
      lxqt.lxqt-policykit
      # Wayland display management (multi-monitor setup)
      nwg-displays
      # GTK theme/cursor/font configuration for Wayland
      nwg-look
      bibata-cursors
      # XWayland bridge for running X11 apps under niri
      xwayland-satellite
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Required for SSHFS with allow_other option
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  system.stateVersion = "25.05";
}
