{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./scripts/KillActiveProcess.nix
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
    # ./kitty
    ./tmux
    ./lazyvim
    ./waybar
    ./hyprland
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
    matchBlocks = {
      "*.exigo.ch" = {
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
    };
    extraConfig = ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 5
    '';
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

    #Terminal
    oh-my-zsh

    #IDE
    git

    # Desktop
    libnotify
    brightnessctl

    #Cloud solution
    railway
  ];

  home.stateVersion = "24.05";
}
