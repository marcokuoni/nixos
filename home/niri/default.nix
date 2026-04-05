{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
    settings = {
      outputs."DP-8" = {
        transform.rotation = 270;
      };
      input.keyboard.xkb = {
        layout = "ch";
        variant = "de_nodeadkeys";
      };
      overview = {
        backdrop-color = "#26233a";
      };
      layout = {
        gaps = 6;
        border.width = 1;
        tab-indicator = {
          place-within-column = true;
        };
      };
      layer-rules = [
        {
          matches = [
            {
              namespace = "^notifications$";
            }
          ];

          block-out-from = "screencast";
        }
      ];
      window-rules = [
        {
          matches = [ { app-id = "wl-mirror"; } ];
          open-fullscreen = true;
          open-on-output = "HDMI-A-1"; # your beamer output name
        }
        {
          matches = [ { app-id = "zen-beta"; } ];
          open-fullscreen = true;
          open-on-workspace = "1";
        }
        {
          matches = [
            {
              is-window-cast-target = true;
            }
          ];

          focus-ring = {
            active.color = "#f38ba8";
            inactive.color = "#7d0d2d";
          };

          border = {
            inactive.color = "#7d0d2d";
          };

          shadow = {
            color = "#7d0d2d70";
          };

          tab-indicator = {
            active.color = "#f38ba8";
            inactive.color = "#7d0d2d";
          };
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
      binds =
        with config.lib.niri.actions;
        lib.attrsets.mergeAttrsList [
          {
            # docu: https://github.com/sodiboo/niri-flake/blob/main/docs.md
            # Lukas: https://github.com/lbuchli/nixos-config/blob/main/configs/niri/config.kdl
            # App settings von noctalia: https://docs.noctalia.dev/theming/program-specific/neovim/
            # screencast with zen https://github.com/niri-wm/niri/wiki/Application-Issues

            #Keys consist of modifiers separated by + signs, followed by an XKB key name
            #in the end. To find an XKB name for a particular key, you may use a program
            #like wev.
            #
            #"Mod" is a special modifier equal to Super when running on a TTY, and to Alt
            #when running as a winit window.
            #
            #Most actions that you can bind here can also be invoked programmatically with
            #`niri msg action do-something`.
            #
            #Mod-Shift-/, which is usually the same as Mod-?,
            #shows a list of important hotkeys.
            "Mod+Shift+Slash".action.show-hotkey-overlay = { };

            # Terminal öffnen
            "Mod+T".action.spawn = "ghostty";
            "Mod+B".action.spawn = "zen-beta";
            "Mod+P" = {
              repeat = false;
              action.spawn-sh = "wl-mirror $(niri msg --json focused-output | jq -r .name)";
            };

            # App-Launcher
            "Mod+D".action.spawn-sh = "noctalia-shell ipc call launcher toggle";
            "Ctrl+Alt+L".action.spawn-sh = "noctalia-shell ipc call lockScreen lock";

            # # Audio (Media-Tasten)
            "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
            "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
            "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
            };

            "XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action = spawn "brightnessctl" "--class=backlight" "set" "+10%";
            };
            "XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action = spawn "brightnessctl" "--class=backlight" "set" "10%-";
            };

            # Fenster
            #Open/close the Overview: a zoomed-out view of workspaces and windows.
            #You can also move the mouse into the top-left hot corner,
            #or do a four-finger swipe up on a touchpad.
            "Mod+O" = {
              repeat = false;
              action = toggle-overview;
            };
            "Mod+Q" = {
              repeat = false;
              action = close-window;
            };

            # Fokus bewegen
            "Mod+H".action.focus-column-left = { };
            "Mod+L".action.focus-column-right = { };
            "Mod+J".action.focus-window-down = { };
            "Mod+K".action.focus-window-up = { };
            "Mod+Home".action.focus-column-first = { };
            "Mod+End".action.focus-column-last = { };

            # Fenster verschieben
            "Mod+Shift+H".action.move-column-left = { };
            "Mod+Shift+L".action.move-column-right = { };
            "Mod+Shift+J".action.move-window-down = { };
            "Mod+Shift+K".action.move-window-up = { };
            "Mod+Shift+Home".action.move-column-to-first = { };
            "Mod+Shift+End".action.move-column-to-last = { };

            #Alternative commands that move across workspaces when reaching
            #the first or last window in a column.
            #Mod+J     { focus-window-or-workspace-down; }
            #Mod+K     { focus-window-or-workspace-up; }
            #Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
            #Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

            "Mod+Ctrl+H".action.focus-monitor-left = { };
            "Mod+Ctrl+J".action.focus-monitor-down = { };
            "Mod+Ctrl+K".action.focus-monitor-up = { };
            "Mod+Ctrl+L".action.focus-monitor-right = { };

            "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

            #Alternatively, there are commands to move just a single window:
            #Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
            #...

            #And you can also move a whole workspace to another monitor:
            #Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
            #...

            "Mod+I".action.focus-workspace-down = { };
            "Mod+U".action.focus-workspace-up = { };
            "Mod+Ctrl+I".action.move-column-to-workspace-down = { };
            "Mod+Ctrl+U".action.move-column-to-workspace-up = { };
            "Mod+Shift+U".action.move-workspace-down = { };
            "Mod+Shift+I".action.move-workspace-up = { };

            #Alternatively, there are commands to move just a single window:
            #Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
            #...

            # The following binds move the focused window in and out of a column.
            # If the window is alone, they will consume it into the nearby column to the side.
            # If the window is already in a column, they will expel it out.
            "Mod+odiaeresis".action.consume-or-expel-window-left = { };
            "Mod+udiaeresis".action.consume-or-expel-window-right = { };

            #Consume one window from the right to the bottom of the focused column.
            "Mod+Comma".action.consume-window-into-column = { };
            #Expel the bottom window from the focused column to the right.
            "Mod+Period".action.expel-window-from-column = { };

            "Mod+R".action.switch-preset-column-width = { };
            #Cycling through the presets in reverse order is also possible.
            #Mod+R { switch-preset-column-width-back; }
            "Mod+Shift+R".action.switch-preset-window-height = { };
            "Mod+Ctrl+R".action.reset-window-height = { };
            "Mod+F".action.maximize-column = { };
            "Mod+Shift+F".action.fullscreen-window = { };
            "Mod+Ctrl+Shift+F".action.toggle-windowed-fullscreen = { };

            #Expand the focused column to space not taken up by other fully visible columns.
            #Makes the column "fill the rest of the space".
            "Mod+Ctrl+F".action.expand-column-to-available-width = { };

            "Mod+C".action.center-column = { };

            #Center all fully visible columns on screen.
            "Mod+Ctrl+C".action.center-visible-columns = { };

            #Finer width adjustments.
            #This command can also:
            #* set width in pixels: "1000"
            #* adjust width in pixels: "-5" or "+5"
            #* set width as a percentage of screen width: "25%"
            #* adjust width as a percentage of screen width: "-10%" or "+10%"
            #Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
            #set-column-width "100" will make the column occupy 200 physical screen pixels.
            "Mod+Minus".action = set-column-width "-10%";
            "Mod+Less".action = set-column-width "+10%";

            #Finer height adjustments when in column with other windows.
            "Mod+Shift+Minus".action = set-window-height "-10%";
            "Mod+Shift+Less".action = set-window-height "+10%";

            #Move the focused window between the floating and the tiling layout.
            "Mod+V".action.toggle-window-floating = { };
            "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

            #Toggle tabbed column display mode.
            #Windows in this column will appear as vertical tabs,
            #rather than stacked on top of each other.
            "Mod+W".action.toggle-column-tabbed-display = { };

            #Actions to switch layouts.
            #Note: if you uncomment these, make sure you do NOT have
            #a matching layout switch hotkey configured in xkb options above.
            #Having both at once on the same hotkey will break the switching,
            #since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
            #Mod+Space       { switch-layout "next"; }
            #Mod+Shift+Space { switch-layout "prev"; }

            # Screenshot
            "Print".action.screenshot = { };
            "Ctrl+Print".action.screenshot-screen = { };
            "Alt+Print".action.screenshot-window = { };

            #Applications such as remote-desktop clients and software KVM switches may
            #request that niri stops processing the keyboard shortcuts defined here
            #so they may, for example, forward the key presses as-is to a remote machine.
            #It's a good idea to bind an escape hatch to toggle the inhibitor,
            #so a buggy application can't hold your session hostage.
            #
            #The allow-inhibiting=false property can be applied to other binds as well,
            #which ensures niri always processes them, even when an inhibitor is active.
            "Mod+Escape" = {
              action = toggle-keyboard-shortcuts-inhibit;
              allow-inhibiting = false;
            };

            #The quit action will show a confirmation dialog to avoid accidental exits.
            "Mod+Shift+E".action = spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle";
            "Ctrl+Alt+Delete".action = quit;

            #Powers off the monitors. To turn them back on, do any input like
            #moving the mouse or pressing any other key.
            "Mod+Shift+P".action = power-off-monitors;
          }
          (builtins.listToAttrs (
            map (n: {
              name = "Mod+${toString n}";
              value = {
                action.focus-workspace = n;
              };
            }) (lib.range 1 9)
          ))

          # Mod+Shift+1..9 move column to workspace
          (builtins.listToAttrs (
            map (n: {
              name = "Mod+Shift+${toString n}";
              value = {
                action.move-column-to-workspace = n;
              };
            }) (lib.range 1 9)
          ))
          #Alternatively, there are commands to move just a single window:
          #Mod+Ctrl+1 { move-window-to-workspace 1; }

          #Switches focus between the current and the previous workspace.
          #Mod+Tab { focus-workspace-previous; }
        ];
    };
  };
}
