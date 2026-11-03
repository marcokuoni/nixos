# Home row modifiers on the built-in laptop keyboard, same as on the Dilemma:
#   A = Super  S = Alt  D = Ctrl  F = Shift    J = Shift  K = Ctrl  L = Alt  Ö = Super
#   X = AltGr  (for Swiss characters like @ # { })
# Tap a key for the letter, hold it for the modifier.
#
# Hold Space for the navigation layer (like layer 2 on the Dilemma):
#   H J K L      = Left Down Up Right
#   N M , . -    = Insert Home PgDn PgUp End
#   A S D F      = plain Super Alt Ctrl Shift, e.g. Space+F+L selects right
# Also: Caps Lock <-> Escape, only on this keyboard.
#
# Only the internal keyboard is grabbed — the Dilemma does all of this in its
# own firmware and must not be remapped a second time.
{
  services.kanata = {
    enable = true;
    keyboards.laptop = {
      # internal keyboard; check with `ls -l /dev/input/by-path/ | grep kbd`
      devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];

      # let keys not listed in defsrc pass through unchanged
      extraDefCfg = "process-unmapped-keys yes";

      config = ''
        (defsrc
          esc caps
          a s d f h j k l ;
          x n m , . /
          spc
        )

        ;; tap / hold time in ms (like QMK's TAPPING_TERM)
        (defvar
          tap-time 200
          hold-time 200
        )

        (defalias
          a (tap-hold $tap-time $hold-time a lmet)
          s (tap-hold $tap-time $hold-time s lalt)
          d (tap-hold $tap-time $hold-time d lctl)
          f (tap-hold $tap-time $hold-time f lsft)
          j (tap-hold $tap-time $hold-time j rsft)
          k (tap-hold $tap-time $hold-time k rctl)
          l (tap-hold $tap-time $hold-time l lalt)
          ;; ö on the Swiss layout sits on the US ; key
          oe (tap-hold $tap-time $hold-time ; rmet)
          x (tap-hold $tap-time $hold-time x ralt)
          ;; tap: space, hold: navigation layer
          spc (tap-hold $tap-time $hold-time spc (layer-while-held nav))
        )

        (deflayer base
          caps esc
          @a @s @d @f h @j @k @l @oe
          @x n m , . /
          @spc
        )

        ;; - on the Swiss layout sits on the US / key
        (deflayer nav
          _ _
          lmet lalt lctl lsft left down up rght _
          _ ins home pgdn pgup end
          _
        )
      '';
    };
  };
}
