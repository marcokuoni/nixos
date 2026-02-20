{ pkgs, ... }:
{
  home.packages = [
    pkgs.kitty
    (pkgs.writeShellScriptBin "toggle-keyboard" ''
      #!/usr/bin/env bash
      set -euo pipefail

      DEV='*::kbd_backlight'                          # keyboard backlight device pattern
      CAPS_GLOB='/sys/class/leds/*::capslock/brightness'  # caps lock LED(s)

      caps_on_sysfs() {
        local f v any=0
        for f in $CAPS_GLOB; do
          [ -r "$f" ] || continue
          any=1
          v=$(cat "$f" 2>/dev/null || echo 0)
          if [ "$v" != "0" ]; then
            return 0   # caps is ON
          fi
        done
        # If we didn’t find any capslock LED files, return failure
        [ "$any" -eq 1 ] || return 2
        return 1       # caps is OFF
      }

      if caps_on_sysfs; then
        brightnessctl -d "$DEV" set 100%
        state="on"
      else
        brightnessctl -d "$DEV" set 0%
        state="off"
      fi

      cur=$(brightnessctl -d "$DEV" g)
      max=$(brightnessctl -d "$DEV" m)
      pct=$(( 100 * cur / max ))

      # swaync/mako both understand notify-send
      notify-send -u low "Keyboard Brightness: $pct% (Caps $state)"

    '')
  ];
}
