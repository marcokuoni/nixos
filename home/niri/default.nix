{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.niri = {
    enable = true;
    # niri-unstable for latest features — change to niri-stable if breakage occurs
    package = pkgs.niri-unstable;
    settings = {
      # niri msg outputs, hier auf den anderen Screen wechseln
      outputs."DP-9" = {
        # rotated monitor (portrait mode)
        transform.rotation = 270;
      };

      outputs."DP-11" = {
        # rotated monitor (portrait mode)
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
          # show tab indicator inside the column rather than above it
          place-within-column = true;
        };
      };

      layer-rules = [
        {
          # hide notification overlays from screencasts for privacy
          matches = [ { namespace = "^notifications$"; } ];
          block-out-from = "screencast";
        }
      ];

      window-rules = [
        {
          # wl-mirror (beamer mirroring) always opens fullscreen on HDMI output
          matches = [ { app-id = "wl-mirror"; } ];
          open-fullscreen = true;
          open-on-output = "HDMI-A-1";
        }
        {
          # zen browser opens fullscreen on workspace 1
          matches = [ { app-id = "zen-beta"; } ];
          open-fullscreen = true;
          open-on-workspace = "1";
        }
        {
          # highlight windows that are being screencast
          matches = [ { is-window-cast-target = true; } ];
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
        # needed for some apps that send XDG activation tokens incorrectly
        honor-xdg-activation-with-invalid-serial = { };
      };

      # noctalia-shell is the bar + launcher — start it with niri
      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
      ];

      binds =
        with config.lib.niri.actions;
        lib.attrsets.mergeAttrsList [
          {
            # show hotkey overlay (like a cheatsheet)
            "Mod+Shift+Slash".action.show-hotkey-overlay = { };

            # ── App launchers ───────────────────────────────────────────────
            "Mod+Alt+T".action.spawn = "ghostty";
            "Mod+T" = {
              repeat = false;
              action.spawn-sh = "NVIM_FULL_TERMINAL=1 ghostty --command='nvim'";
            };
            "Mod+N" = {
              repeat = false;
              action.spawn-sh = "ghostty --command=nvim";
            };
            "Mod+B".action.spawn = "zen-beta";
            "Mod+D".action.spawn-sh = "noctalia-shell ipc call launcher toggle";

            # mirror current output to beamer (HDMI)
            "Mod+P" = {
              repeat = false;
              action.spawn-sh = "wl-mirror $(niri msg --json focused-output | jq -r .name)";
            };

            # lock screen
            "Ctrl+Alt+L".action.spawn-sh = "noctalia-shell ipc call lockScreen lock";

            # ── Audio ───────────────────────────────────────────────────────
            "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
            "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
            "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
            };

            # ── Brightness ─────────────────────────────────────────────────
            "XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action = spawn "brightnessctl" "--class=backlight" "set" "+10%";
            };
            "XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action = spawn "brightnessctl" "--class=backlight" "set" "10%-";
            };

            # ── Window management ───────────────────────────────────────────
            "Mod+O" = {
              repeat = false;
              action = toggle-overview;
            };
            "Mod+Q" = {
              repeat = false;
              action = close-window;
            };

            # ── Focus movement (vim-style) ──────────────────────────────────
            "Mod+H".action.focus-column-left = { };
            "Mod+L".action.focus-column-right = { };
            "Mod+J".action.focus-window-down = { };
            "Mod+K".action.focus-window-up = { };
            "Mod+Home".action.focus-column-first = { };
            "Mod+End".action.focus-column-last = { };

            # ── Window movement ─────────────────────────────────────────────
            "Mod+Shift+H".action.move-column-left = { };
            "Mod+Shift+L".action.move-column-right = { };
            "Mod+Shift+J".action.move-window-down = { };
            "Mod+Shift+K".action.move-window-up = { };
            "Mod+Shift+Home".action.move-column-to-first = { };
            "Mod+Shift+End".action.move-column-to-last = { };

            # ── Monitor focus/move ──────────────────────────────────────────
            "Mod+Ctrl+H".action.focus-monitor-left = { };
            "Mod+Ctrl+J".action.focus-monitor-down = { };
            "Mod+Ctrl+K".action.focus-monitor-up = { };
            "Mod+Ctrl+L".action.focus-monitor-right = { };

            "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

            # ── Workspace navigation ────────────────────────────────────────
            # I/U = down/up workspaces (avoids conflict with monitor hjkl)
            "Mod+I".action.focus-workspace-down = { };
            "Mod+U".action.focus-workspace-up = { };
            "Mod+Ctrl+I".action.move-column-to-workspace-down = { };
            "Mod+Ctrl+U".action.move-column-to-workspace-up = { };
            "Mod+Shift+U".action.move-workspace-down = { };
            "Mod+Shift+I".action.move-workspace-up = { };

            # ── Column stacking ─────────────────────────────────────────────
            # consume/expel moves windows in and out of columns (stacking)
            "Mod+odiaeresis".action.consume-or-expel-window-left = { };
            "Mod+udiaeresis".action.consume-or-expel-window-right = { };
            "Mod+Comma".action.consume-window-into-column = { };
            "Mod+Period".action.expel-window-from-column = { };

            # ── Column/window sizing ────────────────────────────────────────
            "Mod+R".action.switch-preset-column-width = { };
            "Mod+Shift+R".action.switch-preset-window-height = { };
            "Mod+Ctrl+R".action.reset-window-height = { };
            "Mod+F".action.maximize-column = { };
            "Mod+Shift+F".action.fullscreen-window = { };
            "Mod+Ctrl+Shift+F".action.toggle-windowed-fullscreen = { };
            "Mod+Ctrl+F".action.expand-column-to-available-width = { };

            # fine-grained width/height adjustments (-10% / +10%)
            "Mod+Minus".action = set-column-width "-10%";
            "Mod+Less".action = set-column-width "+10%";
            "Mod+Shift+Minus".action = set-window-height "-10%";
            "Mod+Shift+Less".action = set-window-height "+10%";

            # ── Centering ───────────────────────────────────────────────────
            "Mod+C".action.center-column = { };
            "Mod+Ctrl+C".action.center-visible-columns = { };

            # ── Floating / tiling ───────────────────────────────────────────
            "Mod+V".action.toggle-window-floating = { };
            "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

            # ── Tabbed columns ──────────────────────────────────────────────
            "Mod+W".action.toggle-column-tabbed-display = { };

            # ── Screenshots ─────────────────────────────────────────────────
            "Print".action.screenshot = { };
            "Ctrl+Print".action.screenshot-screen = { };
            "Alt+Print".action.screenshot-window = { };

            # ── Session ─────────────────────────────────────────────────────
            # toggle keyboard shortcut inhibitor (escape hatch for remote desktop apps)
            "Mod+Escape" = {
              action = toggle-keyboard-shortcuts-inhibit;
              allow-inhibiting = false;
            };
            # session menu (logout, reboot etc.) via noctalia
            "Mod+Shift+E".action = spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle";
            # hard quit with confirmation dialog
            "Ctrl+Alt+Delete".action = quit;
            # turn off monitors without locking
            "Mod+Shift+P".action = power-off-monitors;
          }

          # Mod+1..9 — switch to workspace N
          (builtins.listToAttrs (
            map (n: {
              name = "Mod+${toString n}";
              value = {
                action.focus-workspace = n;
              };
            }) (lib.range 1 9)
          ))

          # Mod+Shift+1..9 — move focused column to workspace N
          (builtins.listToAttrs (
            map (n: {
              name = "Mod+Shift+${toString n}";
              value = {
                action.move-column-to-workspace = n;
              };
            }) (lib.range 1 9)
          ))
        ];
    };
  };
}
