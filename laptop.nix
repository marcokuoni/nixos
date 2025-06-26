# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, ... }:

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
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "de_nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "sg";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.progressio = {
    isNormalUser = true;
    description = "Progressio";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  security.pam.services = {
    login = {
      u2fAuth = true;
      rules.auth.u2f.args = lib.mkAfter [
        "pinverification=1"
      ];
    };
    sudo = {
      u2fAuth = true;
      rules.auth.u2f.args = lib.mkAfter [
        "pinverification=1"
      ];
    };
    swaylock = {
      u2fAuth = true;
      rules.auth.u2f.args = lib.mkAfter [
        "pinverification=1"
      ];
    };
  };

  security.pam.u2f.settings = {
    authfile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
      "progressio"
      ":EiIM/QYe93WmeZzozdS/mlSSAyr6WSP6AjdnSpkU9YOFgVH7xtz7IVjlT4RTD5m4tLchwfm5IGJc2ET52UDtAFaZuY+Idtm3Ma9eoxX9Jtohz1TTeCzT9whwrpX6usRd,h/Jdj53wbia4JC4oHpQgC0EZ5KniR9ImFM4/A1dCHy3AC0E6UPJ54OpJRugw9FHVbbffF9wUCaGV+zeYYMX9kA==,es256,+presence"
      ":FgniLy8rpTkmdKfBWWayvXSxNlWYGIdcwDSSGJtb729FaMop0QXhdC5mKzhA/Bmvc+0rOCrcz3LdJmQfOfjKOGMhsbs/bwMd9TFg99PTBA0jLt44GgnY1B7sQ24qi+xf,V3O/CtCBu3qnniXRUhUmfIGCBTe9fgTouaRyYHMz/nXWjZPMU6vghGqpv0uhiwj1T07s8MZD3//tsg4kjXyw5A==,es256,+presence"
    ]);
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    # IDE
    neovim
    git

    #Sway
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintaine	
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu
  ];

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
  
  # We need this to enable homemanager with sway
  security.polkit.enable = true;

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };

  system.stateVersion = "24.11"; # Did you read the comment?

}
