# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, lib, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    luks.devices."luks-f61c12a1-ffc3-4e66-9d3e-ed879e8c585a" = {
      crypttabExtraOpts = [ "fido2-device=auto" ];
      device = "/dev/disk/by-uuid/f61c12a1-ffc3-4e66-9d3e-ed879e8c585a";
    };
    systemd.enable = true;
  };
  networking.hostName = "progressio"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      min-free = "50G";
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  services.xserver.enable = false;
  services.xserver.xkb = {
    layout = "ch";
    variant = "de_nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "de_CH-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

            # Basic user example
  users.users.progressio= {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  security.pam.services = {
    login = {
      u2fAuth = true;
      rules.auth.u2f = {
        args = lib.mkAfter [
          "pinverification=1"
        ];
      };
    };
    sudo = {
      # unixAuth = false;
      u2fAuth = true;
      rules.auth.u2f.args = lib.mkAfter [
        "pinverification=1"
      ];
    };
    hyprlock = {
      u2fAuth = true;
      rules.auth.u2f.args = lib.mkAfter [
        "pinverification=1"
      ];
    };
  };

  security.pam.u2f = {
    enable = true;
    settings = {
      authfile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
        "progressio"
        ":5a3ZpJl8dZkJZ1Fhy0YQ44NBUm0yvwTmb99u0uh93y7ovfsN3ooAYIuVqhWQO0BSjadSzlex/tH9xd9PDFlF7enR7VCsutYlLcYR0HhRm3Fo9Bz1IaB9LSjOFC7tPm/6,131W8LOSNyjno2PNMP577L7+VjLknSuPHvZqYzyygecd8ZyOgOEOJoCHKWLS/hcrX+sQ0iGyhx5y7qEK+lY2xA==,es256,+presence"
        ":yk49+p8WGHWbmNL03ov/oBdv1HHkn1Q178StpRbyVr3oHzsPiguPoYGHwcnRNmRVgvCG9uoQ43whcFzATUg6FW8k5kMjINccq/+Ifd/ZoJhi1wIOIF+PY16Kxa7TRn7e,+2FYscYOkQexTeCS48kjR7sjg6HbLYM35ILMw3LhExypeM/DLSqe0bWs7rbklyY+oudXI/oJtxjLRDz2aOFrAQ==,es256,+presence"
      ]);
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #nvidia
    egl-wayland
  ];
  
  security.pam.services.regreet.enableGnomeKeyring = true;

  # We need this to enable homemanager with sway
  security.polkit.enable = true;

  # https://nixos.wiki/wiki/Greetd
  # tweaked for Hyprland
  # ...
  # launches swaylock with exec-once in home/hyprland/hyprland.conf
  # ...
  # single user and single window manager
  # my goal here is auto-login with authentication
  # so I can declare my user and environment (Hyprland) in this config
  # my goal is NOT to allow user selection or environment selection at the the login screen
  # (which a login manager provides beyond just the authentication check)
  # so I don't need a login manager
  # I just launch Hyprland as iancleary automatically, which starts swaylock (to authenticate)
  # I thought I needed a greeter, but I really don't
  # ...
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "progressio";
      };
      default_session = initial_session;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  system.stateVersion = "24.11"; # Did you read the comment?

}
