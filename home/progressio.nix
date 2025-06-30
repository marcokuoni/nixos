{ config, pkgs, ... }:
 
let
  shellAliases = {
    g = "git";
    ga = "git add";
    gc = "git commit";
    gd = "git diff";
    gds = "git diff --staged";
    gf = "git fetch";
    glg = "git log --graph --abbrev-commit --date=relative";
    gp = "git push";
    gpf = "git push --force-with-lease --force-if-includes";
    gsh = "git show";
    gst = "git status";

    nix-shell = "nix-shell --command zsh";

    mv = "mv -i";
  };
in
{
  imports = [
    ./scripts/test.nix
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      inherit shellAliases;
    };

    bash = {
      inherit shellAliases;
    };
  };
  programs.rofi.enable = true;
  programs.hyprlock.enable = true;
  programs.alacritty.enable = true;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # https://github.com/JaKooLit/Hyprland-v4/blob/main/config/hypr/configs/Keybinds.conf
  # https://github.com/JaKooLit/Hyprland-Dots/blob/main/config/hypr/configs/Keybinds.conf
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];
    settings = {
      "$mod" = "SUPER";
      # "$scriptsDir" = "$HOME/.config/hypr/scripts"
      bind =
        [
	  "CTRL ALT, Delete, exec, hyprctl dispatch exit 0" # Exit Hyprland
	  "$mod, Q, killactive" # close active (not kill)
	  # "$mod SHIFT, Q, exec, $scriptsDir/KillActiveProcess.sh" # Kill active process
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
	  "$mod, T, exec, alacritty"
	  "$mod SHIFT, C, exec, hyprctl reload"
	  "$mod, D, exec, rofi -show drun -show-icons"
	  "$mod, L, exec, hyprlock"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
        );
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
      input = {
        kb_layout = "ch";
        kb_variant = "de_nodeadkeys";
      };
    };
  };

  services.swaync.enable = true; # for notification
  services.hyprpolkitagent.enable = true; # for permission escalation

  home.packages = with pkgs; [
    #IDE
    neovim
    git

    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland # display portal for hyprland, required
    wl-clipboard # allows copying to clipboard (for hyprpicker)
    polkit_gnome # polkit agent for GNOME
    seahorse # keyring manager GUI
    nautilus # file manager
    xdg-utils # allow xdg-open to work
    grimblast # screenshots
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL="1";
    T_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };
 
  home.stateVersion = "24.05";
}

