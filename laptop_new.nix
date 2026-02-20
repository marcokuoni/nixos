# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  networking = {
    hostName = "progressio"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        (networkmanager-openconnect.override { withGnome = true; })
      ];
      ensureProfiles = {
        # secrets.entries = [
        #   {
        #     file = config.sops.secrets."school/vpn".path;
        #     matchId = "school";
        #     matchType = "vpn";
        #     matchSetting = "vpn-secrets";
        #     key = "password";
        #   }
        # ];
        profiles.school = {
          connection = {
            id = "school";
            type = "vpn";
          };
          vpn = {
            service-type = "org.freedesktop.NetworkManager.openconnect";

            cookie-flags = "1";

            gateway = "vpn.ost.ch";
            remote = "vpn.ost.ch";
            protocol = "anyconnect";
            useragent = "AnyConnect";
            username = "marco.kuoni@ost.ch";
            authtype = "password";
          };
          vpn-secrets = {
            gateway = "vpn.ost.ch";
            gwcert = "";
            cookie = "";
            resolve = "";
          };
        };
      };
    };

    extraHosts = ''
      127.0.0.1 bank-avera.local
      127.0.0.1 ksgl.local
      127.0.0.1 lemonbrain.local
      127.0.0.1 backoffice.local
      127.0.0.1 ksgl.local
      152.96.10.67 ins-lab
      193.93.22.14 elma-ag.ch
    '';
    # 9003 XDebug, 631 CUPS
    firewall.allowedTCPPorts = [
      9003
      631
    ];
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

    # provide resolvconf/openresolv
    resolvconf.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      min-free = "50G";
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
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
  # Configure console keymap
  console.keyMap = "de_CH-latin1";

  services = {
    dbus.enable = true;
    openvpn.servers = {
      lb-pub = {
        config = ''
          client
          dev tun
          proto udp
          remote 193.93.23.34 1194
          resolv-retry infinite
          nobind
          persist-key
          persist-tun

          data-ciphers AES-256-GCM
          remote-cert-tls server
          auth-nocache

          ca /home/progressio/lemonbrain/vpn/pub/lb-vpn-pub-ca.crt
          cert /home/progressio/lemonbrain/vpn/pub/vpn-pub-marco.crt
          key /home/progressio/lemonbrain/vpn/pub/vpn-pub-marco.key
          tls-auth /home/progressio/lemonbrain/vpn/pub/lb-vpn-ta.key 1
          askpass /tmp/openvpn-lb-pub.pass

          verb 3
        '';
        updateResolvConf = true; # ← hook OpenVPN to resolvconf
        autoStart = false; # or true if you want it started on boot
      };
      lb-int = {
        config = ''
          client
          dev tun
          proto udp
          remote 193.93.23.35 1194
          resolv-retry infinite
          nobind
          persist-key
          persist-tun

          data-ciphers AES-256-GCM
          remote-cert-tls server
          auth-nocache

          ca /home/progressio/lemonbrain/vpn/int/lb-vpn-int-ca.crt
          cert /home/progressio/lemonbrain/vpn/int/lb-vpn-int-marco-kuoni.crt
          key /home/progressio/lemonbrain/vpn/int/lb-vpn-int-marco-kuoni.key
          tls-auth /home/progressio/lemonbrain/vpn/int/lb-vpn-ta.key 1
          askpass /tmp/openvpn-lb-int.pass

          verb 3
        '';
        updateResolvConf = true; # ← hook OpenVPN to resolvconf
        autoStart = false; # or true if you want it started on boot
      };
    };
    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "ch";
        variant = "de_nodeadkeys";
      };
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
    # Für automatische Erkennung (AirPrint/mDNS/IPP)
    avahi = {
      enable = true;
      nssmdns4 = true; # .local-Namen auflösen
      openFirewall = true; # mDNS-Port freigeben
    };
    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    # make it possible to configure on user level through browser
    # https://docs.bastardkb.com/help/troubleshooting.html#custom-udev-rules
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Basic user example
  users = {
    users.progressio = {
      isNormalUser = true;
      extraGroups = [
        "docker"
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "input"
        "aspizu"
        "lp"
        "lpadmin"
        "dialout"
      ];
      shell = pkgs.zsh;
    };
    defaultUserShell = pkgs.zsh;
  };

  virtualisation.docker = {
    enable = true;
    # blocks dns resolution
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  fonts = {
    packages = with pkgs; [
      # fc-list
      nerd-fonts.ubuntu
      nerd-fonts.fira-code
      nerd-fonts._0xproto
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];

    # Enable fontconfig (for fallback rules)
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  security = {
    rtkit.enable = true;
    # Define a user account. Don't forget to set a password with ‘passwd’.
    # pam = {
    #   services = {
    #     login = {
    #       u2fAuth = true;
    #       rules.auth.u2f = {
    #         args = lib.mkAfter [
    #           "pinverification=1"
    #         ];
    #       };
    #     };
    #     sudo = {
    #       # unixAuth = false;
    #       u2fAuth = true;
    #       rules.auth.u2f.args = lib.mkAfter [
    #         "pinverification=1"
    #       ];
    #     };
    #     hyprlock = {
    #       u2fAuth = true;
    #       rules.auth.u2f.args = lib.mkAfter [
    #         "pinverification=1"
    #       ];
    #     };
    #   };
    #   u2f = {
    #     enable = true;
    #     settings = {
    #       authfile = pkgs.writeText "u2f-mappings" (
    #         lib.concatStrings [
    #           "progressio"
    #           ":5a3ZpJl8dZkJZ1Fhy0YQ44NBUm0yvwTmb99u0uh93y7ovfsN3ooAYIuVqhWQO0BSjadSzlex/tH9xd9PDFlF7enR7VCsutYlLcYR0HhRm3Fo9Bz1IaB9LSjOFC7tPm/6,131W8LOSNyjno2PNMP577L7+VjLknSuPHvZqYzyygecd8ZyOgOEOJoCHKWLS/hcrX+sQ0iGyhx5y7qEK+lY2xA==,es256,+presence"
    #           ":yk49+p8WGHWbmNL03ov/oBdv1HHkn1Q178StpRbyVr3oHzsPiguPoYGHwcnRNmRVgvCG9uoQ43whcFzATUg6FW8k5kMjINccq/+Ifd/ZoJhi1wIOIF+PY16Kxa7TRn7e,+2FYscYOkQexTeCS48kjR7sjg6HbLYM35ILMw3LhExypeM/DLSqe0bWs7rbklyY+oudXI/oJtxjLRDz2aOFrAQ==,es256,+presence"
    #         ]
    #       );
    #     };
    #   };
    # };
  };

  # Install firefox.
  programs = {
    firefox.enable = true;
    # Shell
    nix-ld.enable = true;
    zsh.enable = true;
  };
  environment = {
    shells = [ pkgs.zsh ];
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      # mount (if you delete you delete on server)
      # mkdir remote_concrete_hub_functions
      # sshfs root@192.168.10.12:/root/functions remote_concrete_hub_functions -o uid=$(id -u) -o gid=$(id -g) -o allow_other
      # cd ~/remote-project
      # nvim .
      # unmount
      # fusermount -u remote_concrete_hub_functions
      # sshfs

      #nvidia
      networkmanagerapplet # liefert das 'nm-applet' Binary
      networkmanager-openconnect
      openconnect
      lxqt.lxqt-policykit
      nwg-displays
      nwg-look
      bibata-cursors

    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  system.stateVersion = "25.05"; # Did you read the comment?
}
