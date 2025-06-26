{ config, pkgs, ... }:

{
  home.username = "progressio";
  home.homeDirectory = "/home/progressio";
  home.keyboard.layout = "de(nodeadkeys)";

  programs.zsh.enable = true;
  home.packages = [
    #IDE
    pkgs.neovim
    pkgs.git

    pkgs.htop

    pkgs.foot
  ];
  
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = rec {
      terminal = "foot"; 
      startup = [
        # Launch Firefox on start
        {command = "firefox";}
      ];
    };
  };

  services.gnome-keyring.enable = true;
  # Optional: Apply changes automatically
  home.stateVersion = "24.05";
}

