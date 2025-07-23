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
    # sudo openfortivpn gate2.exigo.ch --username lemonbrain  --trusted-cert 3308ac43ca0749e1f24756b3eacc5d16db3833f0830da7f780ca567a4c4969e8
    openfortivpn

    #Terminal
    oh-my-zsh

    #IDE
    git
  ];

  home.stateVersion = "24.05";
}
