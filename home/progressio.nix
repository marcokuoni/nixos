{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./scripts/KillActiveProcess.nix
    ./scripts/LazyvimDiffPlugins.nix
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

    #Terminal
    oh-my-zsh

    #IDE
    git
  ];

  home.stateVersion = "24.05";
}
