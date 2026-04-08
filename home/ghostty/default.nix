{
  programs.ghostty = {
    enable = true;
    settings = {
      # disable client-side decorations — niri handles window borders
      window-decoration = false;

      # Swiss layout friendly font size keys
      # Ctrl+Less (<) to increase, Ctrl+Minus (-) to decrease
      keybind = [
        "ctrl+<=increase_font_size:1"
        "ctrl+-=decrease_font_size:1"
        "ctrl+0=reset_font_size"
      ];
    };
  };
}
