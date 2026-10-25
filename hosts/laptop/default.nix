# The laptop "progressio": its hardware, its user, and the services it runs.
# How things are set up is in modules/nixos (system) and home/ (user).
{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.home-manager
    inputs.go2hs.nixosModules.default
  ];

  networking.hostName = "progressio";

  users.users.progressio = {
    isNormalUser = true;
    shell = pkgs.zsh;
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
  };
  # zsh as login shell (configured in home/zsh). compinit runs in ~/.zshrc,
  # so the system-wide one is skipped to avoid running it twice.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    promptInit = ""; # the prompt comes from starship
  };

  # the user environment (niri, shell, editor, apps) via home-manager
  home-manager = {
    # use the system's nixpkgs instead of a separate instance
    useGlobalPkgs = true;
    # install user packages into /etc/profiles instead of ~/.nix-profile
    useUserPackages = true;
    # files home-manager would overwrite (e.g. a hand-made
    # ~/.config/jj/config.toml) are renamed to *.hm-backup instead of
    # failing the rebuild
    backupFileExtension = "hm-backup";
    sharedModules = [
      inputs.niri.homeModules.niri
      inputs.noctalia.homeModules.default
      inputs.zen-browser.homeModules.beta
    ];
    users.progressio.imports = [ ../../home/progressio.nix ];
  };

  nixpkgs.overlays = [
    (import ../../pkgs/overlay.nix inputs)
    # pkgs.waac (with waa-lsp) and pkgs.vimPlugins.waa-nvim
    inputs.board.overlays.default
  ];

  # reMarkable tablet: cloud sync + notebooks converted to PDF
  services.remarkable-sync = {
    enable = true;
    user = "progressio";
    interval = "5min";
    extraArgs = [ "--verbose" ];
  };
  services.rmdoc-to-pdf = {
    enable = true;
    user = "progressio";
    # inputDir  = "/home/progressio/remarkable";    # default
    # outputDir = "/home/progressio/remarkable-pdf"; # default
    # interval  = "10min";                           # default
  };

  # Unitree Go2 robot dev network
  go2 = {
    enable = true;
    interface = "enp1s0f0";
    address = "192.168.123.99"; # default
    ollama = true;
  };

  system.stateVersion = "25.05";
}
