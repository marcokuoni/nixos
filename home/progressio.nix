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
    ./scripts/VpnIntStart.nix
    ./scripts/VpnPubStatus.nix
    ./scripts/VpnPubToggle.nix
    ./scripts/VpnPubStart.nix
    ./kitty
    ./zsh
    ./lazyvim
    ./wayland
    ./waybar
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  services.nextcloud-client.enable = true;

  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;

  home.packages = with pkgs; [
    curl
    ripgrep
    openfortivpn
    openvpn
    libreoffice

    #Terminal
    oh-my-zsh

    #IDE
    git
  ];

  home.stateVersion = "24.05";
}
