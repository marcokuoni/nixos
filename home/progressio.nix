{ config, pkgs, ... }:

{
  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  programs.zsh.enable = true;
  home.packages = [
    #IDE
    pkgs.neovim
    pkgs.git

    pkgs.htop

    #Sway
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintaine	
  ];

  # Optional: Apply changes automatically
  home.stateVersion = "24.05";
}

