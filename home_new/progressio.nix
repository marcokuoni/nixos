{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./scripts/LazyvimDiffPlugins.nix
    ./scripts/FortiStatus.nix
    ./scripts/FortiToggle.nix
    ./scripts/FortiStart.nix
    ./scripts/VpnIntStatus.nix
    ./scripts/VpnIntToggle.nix
    ./scripts/VpnPubStatus.nix
    ./scripts/VpnPubToggle.nix
    ./scripts/ToggleKeyboard.nix
    ./zsh
    ./tmux
    ./lazyvim
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  services = {
    nextcloud-client = {
      enable = true;
    };
  };

  programs.vscode.enable = true;
  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;
  programs.chromium.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 5;
      };

      "*.exigo.ch" = {
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
    };
  };

  home.packages = with pkgs; [
    curl
    ripgrep
    openfortivpn
    openvpn
    libreoffice
    qutebrowser
    nautilus
    projecteur
    bibata-cursors
    k9s

    # zip
    zip
    unzip

    #IDE
    git

    # Desktop
    libnotify
    brightnessctl

    vscode
  ];

  home.stateVersion = "25.05";
}
