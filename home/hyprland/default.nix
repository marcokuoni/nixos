{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    rofi = {
      enable = true;
      plugins = [
        pkgs.rofi-calc
        pkgs.rofi-emoji
      ];
      modes = [
        "window"
        "drun"
        "run"
        "ssh"
        "calc"
        "filebrowser"
        "emoji"
      ];
    };
    hyprlock.enable = true;
  };

  # https://github.com/JaKooLit/Hyprland-v4/blob/main/config/hypr/configs/Keybinds.conf
  # https://github.com/JaKooLit/Hyprland-Dots/blob/main/config/hypr/configs/Keybinds.conf
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.variables = [ "--all" ];
    settings = {
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 2;
        gaps_out = 0;
        border_size = 1;

        no_border_on_floating = true;
      };

      cursor = {
        sync_gsettings_theme = false;
        zoom_factor = 1;
      };

      windowrulev2 = [
        "float,title:^(Spotlight Circle)$"
        "pin,title:^(Spotlight Circle)$"
        "noborder,title:^(Spotlight Circle)$"
        "noanim,title:^(Spotlight Circle)$"
        "noblur,title:^(Spotlight Circle)$"
      ];

      windowrule = [
        "workspace special:cloud silent, class:^(nextcloud)$"
      ];

      "$mod" = "SUPER";
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow" # NOTE: mouse:272 = left click
        "$mod, mouse:273, resizeactive" # NOTE: mouse:272 = right click
        "$mod ALT, mouse:272, resizewindow"
      ];

      bindl = [
        ", switch:lid, exec, hyprlock"
      ];

      exec-once = [
        "nm-applet"
      ];

      bind = [
        "CTRL ALT, Delete, exec, hyprctl dispatch exit 0" # Exit Hyprland
        "$mod, Q, killactive" # close active (not kill)
        "$mod SHIFT, Q, exec, kill-active-process" # Kill active process
        "CTRL ALT, L, exec, hyprlock" # Screen Lock
        "CTRL ALT, P, exec, wlogout" # Open Power Settings
        "$mod SHIFT, N, exec, swaync-client -t -sw" # swayNC notification panel
        "$mod, N, togglespecialworkspace, cloud"

        # Master Layout
        "$mod CTRL, D, layoutmsg, removemaster"
        "$mod, I, layoutmsg, addmaster"
        "$mod, J, layoutmsg, cyclenext"
        "$mod, K, layoutmsg, cycleprev"
        "$mod CTRL, Return, layoutmsg, swapwithmaster"

        # Dwindle Layout
        "$mod SHIFT, I, togglesplit" # only works on dwidle layout
        "$mod, P, pseudo, " # dwindle

        # Resize windows
        "$mod SHIFT, F, fullscreen"
        "$mod SHIFT, H, resizeactive, -50 0"
        "$mod SHIFT, L, resizeactive, 50 0"
        "$mod SHIFT, K, resizeactive, 0 -50"
        "$mod SHIFT, J, resizeactive, 0 50"

        # Move windows
        "$mod CTRL, H, movewindow, l"
        "$mod CTRL, L, movewindow, r"
        "$mod CTRL, K, movewindow, u"
        "$mod CTRL, J, movewindow, d"

        # Swap windows
        "$mod ALT, H, swapwindow, l"
        "$mod ALT, L, swapwindow, r"
        "$mod ALT, K, swapwindow, u"
        "$mod ALT, J, swapwindow, d"

        # Move focus with mainMod + arrow keys
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Workspaces related
        "$mod, tab, workspace, m+1"
        "$mod SHIFT, tab, workspace, m-1"

        # Special workspace
        "$mod SHIFT, U, movetoworkspace, special"
        "$mod, U, togglespecialworkspace, "

        "$mod, B, exec, firefox"
        "$mod SHIFT, B, exec, qutebrowser"
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast save area ~/Downloads/screenshot.png"
        "$mod, T, exec, kitty"
        "$mod SHIFT, C, exec, hyprctl reload"
        "$mod, SPACE, exec, rofi -show drun -show-icons"
        # "$mod, SUPER_L, exec, rofi -show drun -show-icons"
        # " , Caps_Lock, exec, pkill waybar; waybar &" # use this to refresh capslock state in waybar
        " , Caps_Lock, exec, sleep 0.2; toggle-keyboard" # use this to refresh capslock state in waybar
        "$mod, C, exec, rofi -show calc"
        "$mod, F, exec, rofi -show filebrowser"
        "$mod, S, exec, rofi -show ssh"
        "$mod, E, exec, emoji"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              "$mod CTRL, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
            ]
          ) 9
        )
      );
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "HYPRCURSOR_THEME,Bibata-Modern-Ice" # I think the theme is installed in the wrong directory cause nvg-look gives this an i cant find ~/.local/share/icon folder
        "HYPRCURSOR_SIZE,40"
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
    #Desktop
    # bluez # bluetooth controller
    # rofi-bluetooth # bluetooth menu
    pavucontrol # audio controller
    libappindicator-gtk3 # für AppIndicator-Unterstützung
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland # display portal for hyprland, required
    wl-clipboard # allows copying to clipboard (for hyprpicker)
    polkit_gnome # polkit agent for GNOME
    seahorse # keyring manager GUI
    xdg-utils # allow xdg-open to work
    grimblast # screenshots
    wlogout # menu for power settings (lock, reboot, power off)
    networkmanagerapplet
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    T_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";

    # NVIDIA + Wayland + Hyprland
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
  };
}
