{
  config,
  pkgs,
  ...
}:

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
    ./scripts/KillActiveProcess.nix
    ./scripts/LazyvimDiffPlugins.nix
    ./lazyvim
  ];

  home.username = "progressio";
  home.homeDirectory = "/home/progressio";

  programs = {
    kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      inherit shellAliases;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "vi-mode"
        ];
        theme = "agnoster";
      };
    };

    bash = {
      inherit shellAliases;
    };
  };
  programs = {
    rofi.enable = true;
    hyprlock.enable = true;
    # https://github.com/Alexays/Waybar/blob/master/resources/config.jsonc
    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "bottom";
          modules-left = [
            "hyprland/workspaces"
            "wlr/taskbar"
          ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "keyboard-state"
            "battery"
            "clock"
          ];

          "keyboard-state" = {
            numlock = false;
            capslock = true;
            format = "{name} {icon}";
            format-icons = {
              locked = "";
              unlocked = "";
            };
            # Refresh is done via capslock keybinding
          };

          "wlr/taskbar" = {
            format = "{icon}";
            tooltip = true;
            tooltip-format = "{title}";
            on-click = "activate";
            on-click-middle = "close";
            active-first = true;
          };

          "hyprland/window" = {
            separate-outputs = true;
          };

          "hyprland/workspaces" = {
            format = "{name} : {icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "urgent" = "";
              "active" = "";
              "default" = "";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%d.%m.%Y}";
          };

          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };

          memory = {
            format = "{}% ";
          };
          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [
              ""
              ""
              ""
            ];
          };
          backlight = {
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };
        };
      };
    };
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

      "$mod" = "SUPER";
      bind = [
        "CTRL ALT, Delete, exec, hyprctl dispatch exit 0" # Exit Hyprland
        "$mod, Q, killactive" # close active (not kill)
        "$mod SHIFT, Q, exec, kill-active-process" # Kill active process
        "CTRL ALT, L, exec, hyprlock" # Screen Lock
        "CTRL ALT, P, exec, wlogout" # Open Power Settings
        "$mod SHIFT, N, exec, swaync-client -t -sw" # swayNC notification panel

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

        # Workspaces related
        "$mod, tab, workspace, m+1"
        "$mod SHIFT, tab, workspace, m-1"

        # Special workspace
        "$mod SHIFT, U, movetoworkspace, special"
        "$mod, U, togglespecialworkspace, "

        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow" # NOTE: mouse:272 = left click
        "$mod, mouse:273, resizeactive" # NOTE: mouse:272 = right click

        "$mod, B, exec, firefox"
        ", Print, exec, grimblast copy area"
        "$mod, T, exec, kitty"
        "$mod SHIFT, C, exec, hyprctl reload"
        "$mod, SPACE, exec, rofi -show drun -show-icons"
        " , Caps_Lock, exec, pkill waybar; waybar &" # use this to refresh capslock state in waybar
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
      ];
      input = {
        kb_layout = "ch";
        kb_variant = "de_nodeadkeys";
      };
    };
  };

  services.swaync.enable = true; # for notification
  services.hyprpolkitagent.enable = true; # for permission escalation
  services.nextcloud-client.enable = true;

  home.packages = with pkgs; [
    curl
    ripgrep

    #Terminal
    oh-my-zsh

    #IDE
    git

    #Desktop
    pavucontrol # audio controller
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland # display portal for hyprland, required
    wl-clipboard # allows copying to clipboard (for hyprpicker)
    polkit_gnome # polkit agent for GNOME
    seahorse # keyring manager GUI
    nautilus # file manager
    xdg-utils # allow xdg-open to work
    grimblast # screenshots
    wlogout # menu for power settings (lock, reboot, power off)
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    T_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };

  home.stateVersion = "24.05";
}
