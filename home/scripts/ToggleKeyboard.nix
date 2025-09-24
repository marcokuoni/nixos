{ pkgs, ... }:
{
  home.packages = [
    pkgs.kitty
    (pkgs.writeShellScriptBin "toggle-keyboard" ''
      #!/usr/bin/env bash
      set -euo pipefail

      DEV='*::kbd_backlight'
      ICON_DIR="$HOME/.config/mako/icons"

      caps_on_wayland() {
        command -v swaymsg >/dev/null 2>&1 && swaymsg -r -t get_inputs | grep -q '"capslock": true'
      }
      caps_on_x11() {
        command -v xset >/dev/null 2>&1 && xset q | grep -q 'Caps Lock:\s*on'
      }

      if caps_on_wayland || caps_on_x11; then
        brightnessctl -d "$DEV" set 100%
        state="on"
      else
        brightnessctl -d "$DEV" set 0%
        state="off"
      fi

      # ⬇️ Notify goes here (AFTER setting brightness)
      cur=$(brightnessctl -d "$DEV" g) || exit 0
      max=$(brightnessctl -d "$DEV" m) || exit 0
      pct=$(( 100 * cur / max ))

      # choose an icon (optional)
      if   [ "$pct" -le 33 ]; then icon="$ICON_DIR/brightness-20.png"
      elif [ "$pct" -le 66 ]; then icon="$ICON_DIR/brightness-60.png"
      else icon="$ICON_DIR/brightness-100.png"
      fi

      notify-send \
        -h string:x-canonical-private-synchronous:sys-notify \
        -u low \
        -i "$icon" \
        "Keyboard Brightness: ${pct}% (Caps ${state})"
    '')
  ];
}
