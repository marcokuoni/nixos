{ config, pkgs, ... }:

{
  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  programs.zsh.enable = true;
  programs.waybar.enable = true;

  home.packages = with pkgs; [
    #IDE
    neovim
    git

    htop

    #sway
    alacritty
    rofi-wayland
    swaybg
    grim
    slurp
    wl-clipboard
    waybar
  ];
  
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = rec {
      terminal = "alacritty"; 
      input = {
        "*" = {
	  xkb_layout = "de(nodeadkeys)";
	};
      };
    };
  };

  services.gnome-keyring.enable = true;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
  };
 
  home.stateVersion = "24.05";
}

