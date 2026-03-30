{ config, pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
    settings = {
      input.keyboard.xkb = {
        layout = "ch";
        variant = "de_nodeadkeys";
      };
      overview = {
        backdrop-color = "#26233a";
      };
      window-rules = [
        {
          geometry-corner-radius = {
            top-left = 20.0;
            top-right = 20.0;
            bottom-left = 20.0;
            bottom-right = 20.0;
          };
          clip-to-geometry = true;
        }
      ];

      debug = {
        honor-xdg-activation-with-invalid-serial = { };
      };
      spawn-at-startup = [
        {
          command = [
            "noctalia-shell"
          ];
        }
      ];
      binds = with config.lib.niri.actions; {
        # docu: https://github.com/sodiboo/niri-flake/blob/main/docs.md
        # Lukas: https://github.com/lbuchli/nixos-config/blob/main/configs/niri/config.kdl
        # App settings von noctalia: https://docs.noctalia.dev/theming/program-specific/neovim/
        # Terminal öffnen
        "Mod+T".action.spawn-sh = "ghostty";

        # App-Launcher
        "Mod+D".action.spawn-sh = "noctalia-shell ipc call launcher toggle";
        "Ctrl+Alt+L".action.spawn-sh = "noctalia-shell ipc call lockScreen toggle";

        # Fenster
        "Mod+Q".action.close-window = { };
        "Mod+O".action.toggle-overview = { };
        "Mod+F".action.maximize-column = { };
        "Mod+Shift+F".action.fullscreen-window = { };

        # Screenshot
        "Print".action.screenshot = { };
        "Ctrl+Print".action.screenshot-screen = { };
        "Alt+Print".action.screenshot-window = { };

        # Fokus bewegen
        "Mod+H".action.focus-column-left = { };
        "Mod+L".action.focus-column-right = { };
        "Mod+J".action.focus-window-down = { };
        "Mod+K".action.focus-window-up = { };

        # Fenster verschieben
        "Mod+Shift+H".action.move-column-left = { };
        "Mod+Shift+L".action.move-column-right = { };

        # Workspaces
        # "Mod+1".action = focus-workspace 1;
        # "Mod+2".action = focus-workspace 2;
        # "Mod+3".action = focus-workspace 3;
        # "Mod+Ctrl+1".action.move-column-to-workspace = [ 1 ];
        # "Mod+Ctrl+2".action.move-column-to-workspace = [ 2 ];
        #
        # # Fenstergrösse
        # "Mod+Minus".action = set-column-width "-10%";
        # "Mod+Equal".action = set-column-width "+10%";
        # "Mod+Shift+Minus".action = set-window-height "-10%";
        # "Mod+Shift+Equal".action = set-window-height "+10%";
        #
        # # Floating toggle
        # "Mod+V".action = toggle-window-floating;
        #
        # # Audio (Media-Tasten)
        # "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
        # "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
        # "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        #
        # # Niri beenden
        # "Mod+Shift+E".action = quit;
      };
    };
  };
}
