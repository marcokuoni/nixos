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
    ./kitty
    ./zsh
    ./lazyvim
    ./hyprland
    ./waybar
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  services.nextcloud-client = {
    enable = true;
  };

  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;
  programs.chromium.enable = true;
  programs.ssh = {
    enable = true;
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

    # zip
    zip
    unzip

    #Terminal
    oh-my-zsh

    #IDE
    git
  ];

  home.stateVersion = "24.05";
}
